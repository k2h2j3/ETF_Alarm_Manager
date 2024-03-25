import 'package:flutter_alarm_plus/stores/alarm_list/alarm_list.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';

import 'file_proxy.dart';
// import '../stores/alarm_list/alarm_list.dart';
// import '../stores/observable_alarm/observable_alarm.dart';

class AlarmListManager {
  // 알람 목록 및 파일 저장 기능 초기화
  final AlarmList _alarms;
  final JsonFileStorage _storage = JsonFileStorage();

  AlarmListManager(this._alarms);

  // 개별 알람 저장
  saveAlarm(ObservableAlarm alarm) async {
    // 연결된 음악 파일 경로를 업데이트
    await alarm.updateMusicPaths();
    // 알람목록에서 해당 알람의 인덱스를 찾음.
    final index =
        _alarms.alarms.indexWhere((findAlarm) => alarm.id == findAlarm.id);
    _alarms.alarms[index] = alarm;
    // 업데이트된 알람을 파일에 저장
    await _storage.writeList(_alarms.alarms);
  }
}
