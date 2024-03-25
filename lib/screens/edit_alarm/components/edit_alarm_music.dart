import 'package:flutter/material.dart';
import 'package:flutter_alarm_plus/components/music_selection_dialog/music_selection_dialog.dart';
import 'package:flutter_alarm_plus/components/music_selection_dialog/playlist_selection_dialog.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
//import '../../../components/music_selection_dialog/music_selection_dialog.dart';
//import '../../../components/music_selection_dialog/playlist_selection_dialog.dart';
import 'music_list_item.dart';
import 'playlist_list_item.dart';
//import '../../../stores/observable_alarm/observable_alarm.dart';

enum SelectionMode { SINGLE, PLAYLIST }

class EditAlarmMusic extends StatelessWidget {
  final ObservableAlarm alarm;

  const EditAlarmMusic({Key? key, required this.alarm}) : super(key: key);

  Future<void> requestPermission() async {
    final status = await Permission.audio.request();
    if (status != PermissionStatus.granted) {
      print('Audio permission denied');
    }
  }

  // 단일 음악 선택 다이얼로그를 열기위한 함수
  void openSingleSelectionDialog(context) async {
    await requestPermission();
    // 기기에 저장된 음악 파일 목록을 가져옴.
    final audioQuery = OnAudioQuery();
    final songs = await audioQuery.querySongs();

    // 음악 선택 다이얼로그 표시
    showDialog(
        context: context,
        builder: (context) =>
            MusicSelectionDialog(alarm: alarm, titles: songs));
  }

  // 재생 목록 선택 다이얼로그를 열기위한 함수
  void openPlaylistSelectionDialog(context) async {
    await requestPermission();
    // 기기에 저장된 재생목록을 가져옴
    final audioQuery = OnAudioQuery();
    final playlists = await audioQuery.queryPlaylists();

    showDialog(
      context: context,
      builder: (context) =>
          PlaylistSelectionDialog(alarm: alarm, playlists: playlists!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Selection',
              style: TextStyle(fontSize: 20),
            ),
            // 음악 추가 버튼
            PopupMenuButton<SelectionMode>(
              icon: Icon(
                Icons.add,
                color: Colors.deepPurple,
              ),
              itemBuilder: (_) {
                return [
                  {"text": "Single selection", "value": SelectionMode.SINGLE},
                  {"text": "Playlist", "value": SelectionMode.PLAYLIST},
                ]
                    .map((item) => PopupMenuItem<SelectionMode>(
                        value: item["value"] as SelectionMode?, child: Text(item["text"] as String)))
                    .toList();
              },
              onSelected: (selection) {
                switch (selection) {
                  case SelectionMode.SINGLE:
                    openSingleSelectionDialog(context);
                    break;
                  case SelectionMode.PLAYLIST:
                    openPlaylistSelectionDialog(context);
                    break;
                }
              },
            )
          ],
        ),
        SizedBox.fromSize(
          size: Size.fromHeight(300),
          // 음악 목록
          child: Observer(
            builder: (context) {
              final musicListItems = alarm.trackInfo
                  .map((info) => MusicListItem(
                        alarm: alarm,
                        musicInfo: info,
                        key: Key(info.id.toString()),
                      ))
                  .toList();

              final playlistListItems =
                  alarm.playlistInfo.map((info) => PlaylistListItem(
                        alarm: alarm,
                        playlistInfo: info,
                        key: Key(info.id.toString()),
                      ));

              // 음악 목록 표시 및 재정렬 기능
              return ReorderableListView(
                children: [...musicListItems, ...playlistListItems],
                onReorder: this.alarm.reorder,
              );
            },
          ),
        ),
      ],
    );
  }
}
