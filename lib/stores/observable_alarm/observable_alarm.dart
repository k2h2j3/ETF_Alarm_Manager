import 'dart:async';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'observable_alarm.g.dart';

@JsonSerializable()
class ObservableAlarm extends ObservableAlarmBase with _$ObservableAlarm {
  ObservableAlarm(
      {required id,
      required name,
      required hour,
      required minute,
      required monday,
      required tuesday,
      required wednesday,
      required thursday,
      required friday,
      required saturday,
      required sunday,
      required volume,
      required active,
      required notificationEnabled})
      : super(
          id: id,
          name: name,
          hour: hour,
          minute: minute,
          monday: monday,
          tuesday: tuesday,
          wednesday: wednesday,
          thursday: thursday,
          friday: friday,
          saturday: saturday,
          sunday: sunday,
          volume: volume,
          active: active,
          notificationEnabled: notificationEnabled,
          musicIds: [],
          musicPaths: [],
        );

  ObservableAlarm.dayList(
      id, name, hour, minute, volume, active, weekdays, musicIds, musicPaths, notificationEnabled)
      : super(
            id: id,
            name: name,
            hour: hour,
            minute: minute,
            volume: volume,
            active: active,
            notificationEnabled: notificationEnabled,
            musicIds: musicIds,
            monday: weekdays[0],
            tuesday: weekdays[1],
            wednesday: weekdays[2],
            thursday: weekdays[3],
            friday: weekdays[4],
            saturday: weekdays[5],
            sunday: weekdays[6],
            musicPaths: musicPaths,);

  factory ObservableAlarm.fromJson(Map<String, dynamic> json) =>
      _$ObservableAlarmFromJson(json);

  Map<String, dynamic> toJson() => _$ObservableAlarmToJson(this);
}

abstract class ObservableAlarmBase with Store {
  int id;

  @observable
  String name;

  @observable
  int hour;

  @observable
  int minute;

  @observable
  bool monday;

  @observable
  bool tuesday;

  @observable
  bool wednesday;

  @observable
  bool thursday;

  @observable
  bool friday;

  @observable
  bool saturday;

  @observable
  bool sunday;

  @observable
  double volume;

  @observable
  bool active;

  @observable
  bool notificationEnabled;

  /// Field holding the IDs of the playlists that were added to the alarm
  /// This is used for JSON serialization as well as retrieving the music from
  /// the playlist when the alarm goes off
  List<String> playlistIds = [];

  /// Field holding the IDs of the soundfiles that should be loaded
  /// This is exclusively used for JSON serialization
  List<String> musicIds;

  /// Field holding the paths of the soundfiles that should be loaded.
  /// musicIds cannot be used in the alarm callback because of a weird
  /// interaction between flutter_audio_query and android_alarm_manager
  /// See Stack Overflow post here: https://stackoverflow.com/q/60203223/6707985
  List<String> musicPaths;

  @observable
  @JsonKey(ignore: true)
  ObservableList<SongModel> trackInfo = ObservableList();

  @observable
  @JsonKey(ignore: true)
  ObservableList<PlaylistModel> playlistInfo = ObservableList();

  ObservableAlarmBase(
      {required this.id,
        required this.name,
        required this.hour,
        required this.minute,
        required this.monday,
        required this.tuesday,
        required this.wednesday,
        required this.thursday,
        required this.friday,
        required this.saturday,
        required this.sunday,
        required this.volume,
        required this.active,
        required this.notificationEnabled,
        required this.musicIds,
        required this.musicPaths});

  @action
  void removeItem(SongModel info) {
    trackInfo.remove(info);
    trackInfo = trackInfo;
  }

  @action
  void removePlaylist(PlaylistModel info) {
    playlistInfo.remove(info);
    playlistInfo = playlistInfo;
  }

  @action
  void reorder(int oldIndex, int newIndex) {
    final path = trackInfo[oldIndex];
    trackInfo.removeAt(oldIndex);
    trackInfo.insert(newIndex, path);
    trackInfo = trackInfo;
  }

  @action
  loadTracks() async {
    if (musicIds.length == 0) {
      trackInfo = ObservableList();
      return;
    }

    final songs = await OnAudioQuery().querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final filteredSongs = songs.where((song) => musicIds.contains(song.id.toString())).toList();
    trackInfo = ObservableList.of(filteredSongs);
  }

  @action
  loadPlaylists() async {
    if (playlistIds.length == 0) {
      playlistInfo = ObservableList();
      return;
    }

    final playlists = await OnAudioQuery().queryPlaylists(
      sortType: PlaylistSortType.PLAYLIST,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final filteredPlaylists = playlists.where((playlist) => playlistIds.contains(playlist.id.toString())).toList();
    playlistInfo = ObservableList.of(filteredPlaylists);
  }

  @action
  void toggleNotification() {
    notificationEnabled = !notificationEnabled;
    // Update observable with a new value
    this.notificationEnabled = notificationEnabled;
  }

  updateMusicPaths() {
    musicIds = trackInfo.map((SongModel info) => info.id.toString()).toList();
    musicPaths = trackInfo
        .map((SongModel info) => info.data)
        .whereType<String>()
        .toList();
    playlistIds = playlistInfo.map((info) => info.id.toString()).toList();
  }

  List<bool> get days {
    return [monday, tuesday, wednesday, thursday, friday, saturday, sunday];
  }

  // Good enough for debugging for now
  toString() {
    return "active: $active, music: $musicPaths";
  }
}
