import 'dart:io';
import 'dart:typed_data';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_alarm_plus/main.dart';
import 'package:flutter_alarm_plus/services/media_handler.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'file_proxy.dart';
// import '../stores/observable_alarm/observable_alarm.dart';

class AlarmScheduler {
  // 모든 알람 취소
  clearAlarm(ObservableAlarm alarm) {
    for (var i = 0; i < 7; i++) {
      // 일주일의 각 요일에 해당하는 모든 알람을 취소
      AndroidAlarmManager.cancel(alarm.id * 7 + i);
    }
  }

  /*
    To wake up the device and run something on top of the lockscreen,
    this currently requires the hack from here to be implemented:
    https://github.com/flutter/flutter/issues/30555#issuecomment-501597824
  */
  Future<void> scheduleAlarm(ObservableAlarm alarm) async {
    final days = alarm.days;

    final scheduleId = alarm.id * 7;
    for (var i = 0; i < 7; i++) {
      await AndroidAlarmManager.cancel(scheduleId + i);
      if (alarm.active && days[i]) {
        final targetDateTime = nextWeekday(i + 1, alarm.hour, alarm.minute);
        await AndroidAlarmManager.oneShotAt(
          targetDateTime,
          scheduleId + i,
          callback,
          alarmClock: true,
          wakeup: true,
          rescheduleOnReboot: true,
        );
      }
    }
  }

  DateTime nextWeekday(int weekday, alarmHour, alarmMinute) {
    var checkedDay = DateTime.now();

    // 현재 날짜가 주어진 요일과 일치하면, 오늘의 알람시간 계산
    if (checkedDay.weekday == weekday) {
      final todayAlarm = DateTime(checkedDay.year, checkedDay.month,
          checkedDay.day, alarmHour, alarmMinute);

      // 현재 시간이 알람 시간 이전이면
      if (checkedDay.isBefore(todayAlarm)) {
        // 오늘 알람이 울리도록 설정
        return todayAlarm;
      }
      // 그렇지 않을 경우 일주일 뒤 알람
      return todayAlarm.add(Duration(days: 7));
    }

    // 현재 날짜가 알람 요일과 일치하지 않으면
    while (checkedDay.weekday != weekday) {
      // 주어진 요일이 될 때까지 하루씩 증가시킨다
      checkedDay = checkedDay.add(Duration(days: 1));
    }

    return DateTime(checkedDay.year, checkedDay.month, checkedDay.day,
        alarmHour, alarmMinute);
  }

  // 알람이 실행될때 호출되는 콜백함수
  static void callback(int id) async {
    // 콜백 ID를 실제 알람 ID로 변환
    final alarmId = callbackToAlarmId(id);

    // 알람 플래그 파일 생성
    createAlarmFlag(alarmId);
  }

  /// Because each alarm might need to be able to schedule up to 7 android alarms (for each weekday)
  /// a means is required to convert from the actual callback ID to the ID of the alarm saved
  /// in internal storage. To do so, we can assign a range of 7 per alarm and use ceil to get to
  /// get the alarm ID to access the list of songs that could be played
  static int callbackToAlarmId(int callbackId) {
    return (callbackId / 7).floor();
  }

  /// Creates a flag file that the main isolate can find on life cycle change
  /// For now just abusing the FileProxy class for testing
  // 알람 플래그 파일 생성
  static void createAlarmFlag(int id) async {
    print('Creating a new alarm flag for ID $id');
    final dir = await getApplicationDocumentsDirectory();
    JsonFileStorage.toFile(File(dir.path + "/$id.alarm")).writeList([]);

    // 알람 시간에 알림 표시
    await showAlarmNotification(id);
  }



  static Future<void> showAlarmNotification(int alarmId) async {
    final alarms = await new JsonFileStorage().readList();
    list.setAlarms(alarms);
    final alarm = list.alarms.firstWhereOrNull((alarm) => alarm.id == alarmId);
    if (alarm != null) {
      final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_notification_channel',
        'Alarm Notifications',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        ongoing: true,
        vibrationPattern: vibrationPattern,
      );
      final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        alarmId,
        'Alarm',
        alarm.name, // ObservableAlarm의 name 속성 사용
        platformChannelSpecifics,
        payload: alarmId.toString(),
      );
    }
  }
}
