import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

// import '../stores/observable_alarm/observable_alarm.dart';

class MediaHandler {
  late AudioPlayer _currentPlayer;
  late double _originalVolume;

  // 볼륨조절
  changeVolume(ObservableAlarm alarm) async {
    _originalVolume = await PerfectVolumeControl.volume;
    PerfectVolumeControl.setVolume(alarm.volume);
  }

  // 무작위 음악 경로
  getRandomPath(ObservableAlarm alarm) async {
    // 모든 재생목록 가져오기
    final OnAudioQuery query = OnAudioQuery();
    final allPlaylists = await query.queryPlaylists(
      sortType: PlaylistSortType.PLAYLIST,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    ) ?? [];

    final filteredPlaylists = allPlaylists.where((playlist) => alarm.playlistIds.contains(playlist.id.toString())).toList();

    final playlistSongIdChunks = allPlaylists
        .where((playlist) => alarm.playlistIds.contains(playlist.id.toString()))
        .map((info) => info.numOfSongs);

    var playlistSongIds = <String>[];
    for (var playlist in filteredPlaylists) {
      final songs = await query.queryAudiosFrom(
        AudiosFromType.PLAYLIST,
        playlist.id,
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        ignoreCase: true,
      );
      playlistSongIds.addAll(songs.map((song) => song.id.toString()));
    }

    // Workaround for the case of a single playlist that has just one song
    // https://github.com/sc4v3ng3r/flutter_audio_query/issues/16
    // Adding hack after hack; good times
    final Iterable<String> playlistPaths = playlistSongIds.isNotEmpty
        ? (await query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    ))
        .where((song) => playlistSongIds.contains(song.id.toString()))
        .map((info) => info.data)
        .whereType<String>()
        : [];

    final paths = [...alarm.musicPaths, ...playlistPaths];
    print('Paths: $paths');

    if (paths.isEmpty) {
      throw ArgumentError("Empty path array found");
    }

    final entry = Random().nextInt(paths.length);
    return paths[entry];
  }

  // 주어진 경로의 음악 파일을 재생
  playMusicFromPath(String path, alarm) async {
    bool subscribed = false;
    _currentPlayer = AudioPlayer();

    late StreamSubscription subscription;
    subscription = _currentPlayer.onDurationChanged.listen((duration) {
      final seconds = duration.inSeconds;
      // 음악 파일의 재생 시간이 30초 미만인경우 반복 재생
      if (seconds < 30) {
        _currentPlayer.setReleaseMode(ReleaseMode.loop);
        subscription.cancel();
      } else {
        if (subscribed) return;
        _currentPlayer.onPlayerComplete.listen((_) async {
          playMusic(alarm);
          subscription.cancel();
        });
        subscribed = true;
      }
    });

    final fixedPath = File(path).absolute.path;
    await _currentPlayer.play(UrlSource(fixedPath), volume: 1.0);
  }

  // 알람에 설정된 음악을 무작위로 선택하여 재생
  playMusic(ObservableAlarm alarm) async {
    final path = await getRandomPath(alarm);
    playMusicFromPath(path, alarm);
  }

  // 알람 소리 중지 및 볼륨을 원래대로 되돌림
  stopAlarm() {
    PerfectVolumeControl.setVolume(_originalVolume);

    _currentPlayer.stop();
    _currentPlayer.release();
  }
}
