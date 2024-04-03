import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

  // flutter_local_notifications 초기화
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('clockicon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 알림 탭 이벤트 처리
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse = notificationAppLaunchDetails!.notificationResponse;
    if (notificationResponse != null) {
      final payload = notificationResponse.payload;
      if (payload != null) {
        final alarmId = int.parse(payload);
        final alarm = list.alarms.firstWhereOrNull((alarm) => alarm.id == alarmId);
        if (alarm != null) {
          AlarmStatus().isAlarm = true;
          AlarmStatus().alarmId = alarmId;
        }
      }
    }
  }

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
        home: Observer(builder: (context) {
          AlarmStatus status = AlarmStatus();

          if (status.isAlarm) {
            final id = status.alarmId;
            final alarm = list.alarms.firstWhereOrNull((alarm) => alarm.id == id)!;

            MediaHandler mediaHandler = MediaHandler();
            mediaHandler.changeVolume(alarm);
            mediaHandler.playDefaultAlarmSound();
            Wakelock.enable();

            return AlarmScreen(alarm: alarm, mediaHandler: mediaHandler);
          }
          return HomeScreen(alarms: list);
        }));
  }
}