import 'package:flutter/material.dart';
import 'package:flutter_alarm_plus/stores/music_selection/searchable_selection.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'dialog_base.dart';
//import '../../stores/music_selection/searchable_selection.dart';
//import '../../stores/observable_alarm/observable_alarm.dart';

class PlaylistSelectionDialog extends StatelessWidget {
  final ObservableAlarm alarm;
  final List<PlaylistModel> playlists;

  final SearchableSelectionStore<PlaylistModel> store;

  PlaylistSelectionDialog(
      {Key? key, required this.alarm, required this.playlists})
      : store = SearchableSelectionStore(
            playlists,
      alarm.playlistInfo.map((info) => info.id.toString()).toList(),
          (info) => info.id.toString(), (info, search) {
          final filter = RegExp(search, caseSensitive: false);
          return info.playlist.contains(filter);
        }),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final onDone = () {
      final newSelected = store.itemSelected.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key);
      alarm.playlistIds = ObservableList.of(newSelected);
      alarm.loadPlaylists();
    };

    return DialogBase(
      child: PlaylistList(
        store: store,
      ),
      onDone: onDone,
      onSearchClear: () => store.clearSearch(),
      onSearchChange: (newValue) => store.currentSearch = newValue,
    );
  }
}

class PlaylistList extends StatelessWidget {
  final SearchableSelectionStore<PlaylistModel> store;

  const PlaylistList({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => ListView(
        shrinkWrap: true,
        children: store.filteredIds.map(widgetForPlaylistId).toList(),
      ),
    );
  }

  Widget widgetForPlaylistId(String id) {
    final List<PlaylistModel> playlists = store.availableItems;
    final playlist = playlists.firstWhere((info) => info.id == id);

    return Observer(
      builder: (context) => CheckboxListTile(
        value: store.itemSelected[playlist.id] ?? false,
        title: Text(playlist.data!),
        onChanged: (newValue) {
          store.itemSelected[playlist.id.toString()] = newValue!;
        },
      ),
    );
  }
}
