import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

import 'screens/alarm_screen/alarm_screen.dart';
import 'screens/home_screen/home_screen.dart';
import 'services/alarm_polling_worker.dart';
import 'services/file_proxy.dart';
import 'services/life_cycle_listener.dart';
import 'services/media_handler.dart';
import 'stores/alarm_list/alarm_list.dart';
import 'stores/alarm_status/alarm_status.dart';

AlarmList list = AlarmList();

void main() async {
  // AndroidAlarmManager 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();

  // 권한 요청
  await requestPermissions();

  // 저장된 알람목록 read
  final alarms = await new JsonFileStorage().readList();
  list.setAlarms(alarms);

  // 각 알람에 대해 트랙과 재생목록 load
  list.alarms.forEach((alarm) {
    alarm.loadTracks();
    alarm.loadPlaylists();
  });

  // 앱 생명주기 감지
  WidgetsBinding.instance!.addObserver(LifeCycleListener(list));

  // 앱 실행
  runApp(MyApp());

  // AlarmPollingWorkder 생성
  AlarmPollingWorker().createPollingWorker();

  final externalPath = await getExternalStorageDirectory();
  if (externalPath == null) {
    return;
  }

  if (!externalPath.existsSync()) {
    externalPath.create(recursive: true);
  }
}

Future<void> requestPermissions() async {
  // 알림 권한 요청
  final notificationStatus = await Permission.notification.request();
  if (notificationStatus != PermissionStatus.granted) {
    // 알림 권한 요청이 거부된 경우 처리
    print('Notification permission denied!');
    // exit(0);
  }

  // 배터리 최적화 예외 권한 요청
  final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
  if (batteryStatus != PermissionStatus.granted) {
    // 배터리 최적화 예외 권한 요청이 거부된 경우 처리
    print('Battery optimization exception permission denied!');
    // exit(0);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color.fromRGBO(25, 12, 38, 1),
        ),
        // Observer를 통해 AlarmStatus 관찰
        home: Observer(builder: (context) {
          AlarmStatus status = AlarmStatus();

          // 현재 알람이 울리고 있는 경우
          if (status.isAlarm) {
            final id = status.alarmId;
            // 해당 알람 ID로 AlarmList에서 알람찾기
            final alarm =
            list.alarms.firstWhereOrNull((alarm) => alarm.id == id)!;

            MediaHandler mediaHandler = MediaHandler();
            // MediaHandler를 사용하여 볼륨 조절 및 음악 재생
            if (alarm.musicIds != null) {

              mediaHandler.changeVolume(alarm);
              mediaHandler.playMusic(alarm);
              Wakelock.enable();
            }

            return AlarmScreen(alarm: alarm, mediaHandler: mediaHandler);
          }
          // 알람이 울리고있지 않은 경우에는 홈화면 return
          return HomeScreen(alarms: list);
        }));
  }
}
