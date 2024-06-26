import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
import 'package:mobx/mobx.dart';
// import '../observable_alarm/observable_alarm.dart';

part 'alarm_list.g.dart';

class AlarmList = _AlarmList with _$AlarmList;

abstract class _AlarmList with Store {
  _AlarmList();

  @observable
  ObservableList<ObservableAlarm> alarms = ObservableList();

  @action
  void setAlarms(List<ObservableAlarm> alarms) {
    this.alarms.clear();
    this.alarms.addAll(alarms);
  }
}
