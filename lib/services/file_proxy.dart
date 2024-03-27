import 'dart:convert';
import 'dart:io';

// import '../stores/observable_alarm/observable_alarm.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
import 'package:path_provider/path_provider.dart';

class JsonFileStorage {
  File? _file;

  JsonFileStorage();

  JsonFileStorage.toFile(this._file);

  Future<void> writeList(List<ObservableAlarm> alarms) async {
    await _ensureFileSet();
    _file!.writeAsString(jsonEncode(alarms));
    print('writeList completed');
  }

  Future<List<ObservableAlarm>> readList() async {
    await _ensureFileSet();
    if (_file!.existsSync()) {
      String content = await _file!.readAsString();
      List<dynamic> parsedList = jsonDecode(content) as List;
      return parsedList.map((map) => ObservableAlarm.fromJson(map)).toList();
    }
    return [];
  }

  // 파일 객체가 설정되어있는지 확인하고, 설정되어있지 않은 경우 파일 객체를 가져옴
  Future<void> _ensureFileSet() async {
    if (_file == null) {
      _file = await _getLocalFile();
    }
  }

  // 로컬파일 경로를 기반으로 파일 객체를 변환
  Future<File> _getLocalFile() async {
    return _getLocalPath().then((path) => File('$path/alarms.json'));
  }

  // 애플리케이션 문서 디렉토리의 경로를 반환
  Future<String> _getLocalPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
