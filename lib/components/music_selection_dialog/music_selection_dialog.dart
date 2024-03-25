import 'package:flutter/material.dart';
import 'package:flutter_alarm_plus/stores/music_selection/searchable_selection.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
import 'package:flutter_alarm_plus/stores/music_selection/searchable_selection.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dialog_base.dart';
//import '../../stores/music_selection/searchable_selection.dart';
//import '../../stores/observable_alarm/observable_alarm.dart';

bool songFilter(SongModel info, String currentSearch) {
  final filter = RegExp(currentSearch, caseSensitive: false);
  return info.title.contains(filter) || info.displayName.contains(filter);
}

class MusicSelectionDialog extends StatelessWidget {
  final List<SongModel> titles;
  final ObservableAlarm alarm;

  final SearchableSelectionStore<SongModel> store;

  MusicSelectionDialog({Key? key, required this.titles, required this.alarm})
      : store = SearchableSelectionStore<SongModel>(
      titles,
      alarm.trackInfo.map((info) => info.id.toString()).toList(),
          (info) => (info as SongModel).id.toString(),
      songFilter),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final onDone = () {
      final newSelected = store.itemSelected.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key);
      alarm.musicIds = ObservableList.of(newSelected);
      alarm.loadTracks();
    };

    return DialogBase(
      onDone: onDone,
      child: MusicList(store: store),
      onSearchChange: (newValue) => store.currentSearch = newValue,
      onSearchClear: () => store.clearSearch(),
    );
  }
}

class MusicList extends StatelessWidget {
  final SearchableSelectionStore<SongModel> store;

  const MusicList({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => ListView(
        shrinkWrap: true,
        children: store.filteredIds.map(widgetForSongId).toList(),
      ),
    );
  }

  Widget widgetForSongId(String id) {
    final List<SongModel> titles = store.availableItems;
    final title = titles.firstWhere((info) => info?.id.toString() == id);

    return Observer(
        builder: (context) => CheckboxListTile(
          value: store.itemSelected[title?.id.toString() ?? ''] ?? false,
          title: Text(title?.title ?? ''),
          onChanged: (newValue) {
            store.itemSelected[title?.id.toString() ?? ''] = newValue!;
          },
        ));
  }
}
