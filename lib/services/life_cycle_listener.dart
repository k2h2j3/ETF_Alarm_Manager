import 'package:flutter/material.dart';
import 'package:flutter_alarm_plus/stores/alarm_list/alarm_list.dart';
import 'alarm_polling_worker.dart';
import 'file_proxy.dart';
// import '../stores/alarm_list/alarm_list.dart';

class LifeCycleListener extends WidgetsBindingObserver {
  final AlarmList alarms;

  LifeCycleListener(this.alarms);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      // 앱이 중지되거나 비활성화 상태인 경우
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // 알람을 저장
        saveAlarms();
        break;
      case AppLifecycleState.resumed:
        createAlarmPollingIsolate();
        break;
      default:
        print("Updated lifecycle state: $state");
    }
  }

  void saveAlarms() {
    // 음악경로 업데이트
    alarms.alarms.forEach((alarm) => alarm.updateMusicPaths());
    // 업데이트된 알람 리스트를 JSON형식으로 파일에 저장
    JsonFileStorage().writeList(alarms.alarms);
  }

  // 새로운 알람 폴링 작업자 생성
  // 이유
  // 1. 앱이 다시 시작상태가 되었을 때, 알람 폴링 작업을 재개하기 위함
  // 2. 이전에 생성된 알람 플래그 파일을 검사하고 처리하기 위함
  // 3. 알람 폴링 작업을 통해 알람 실행 여부를 확인하고 알람 동작을 트리거하기 위함
  void createAlarmPollingIsolate() {
    print('Creating a new worker to check for alarm files!');
    AlarmPollingWorker().createPollingWorker();
  }
}
