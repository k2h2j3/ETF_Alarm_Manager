import 'dart:async';

import 'package:flutter_alarm_plus/stores/alarm_status/alarm_status.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// import '../stores/alarm_status/alarm_status.dart';

class AlarmPollingWorker {
  static AlarmPollingWorker _instance = AlarmPollingWorker._();

  factory AlarmPollingWorker() {
    return _instance;
  }

  AlarmPollingWorker._();

  bool running = false;

  void createPollingWorker() {
    if (running) {
      //TODO Might be intended to run it again with 60 more iterations?
      // Probably have to figure out a way to address that.
      print('Worker is already running, not creating another one!');
      return;
    }

    running = true;
    poller().then((alarmId) {
      running = false;
      // 알람파일이 발견될경우
      if (alarmId != null && AlarmStatus().alarmId == null) {
        // 알람 파일 정리
        AlarmStatus().isAlarm = true;
        AlarmStatus().alarmId = int.parse(alarmId);
        cleanUpAlarmFiles();
      }
    });
  }

  /// Polling function checking for .alarm files in getApplicationDocumentsDirectory()
  /// every 10th of a for #iterations iterations.
  Future<String?> poller() async {
    while (true) {
      final foundFiles = await findFiles();
      if (foundFiles.isNotEmpty) {
        return foundFiles.first;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<List<String>> findFiles() async {
    final extension = ".alarm";
    final dir = await getApplicationDocumentsDirectory();
    return dir
        .list()
        .map((entry) => entry.path)
        .where((path) => path.endsWith(extension))
        .map((path) => basename(path))
        .map((path) => path.substring(0, path.length - extension.length))
        .toList();
  }

  void cleanUpAlarmFiles() async {
    print('Cleaning up generated .alarm files!');
    final dir = await getApplicationDocumentsDirectory();
    dir
        .list()
        .where((entry) => entry.path.endsWith(".alarm"))
        .forEach((entry) => entry.delete());
  }
}