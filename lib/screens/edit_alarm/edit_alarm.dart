import 'package:flutter/material.dart';
import 'package:flutter_alarm_plus/components/default_container/default_container.dart';
import 'package:flutter_alarm_plus/services/alarm_list_manager.dart';
import 'package:flutter_alarm_plus/services/alarm_scheduler.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
// import '../../components/default_container/default_container.dart';
import 'components/edit_alarm_days.dart';
import 'components/edit_alarm_head.dart';
import 'components/edit_alarm_music.dart';
import 'components/edit_alarm_slider.dart';
import 'components/edit_alarm_time.dart';
// import '../../services/alarm_list_manager.dart';
// import '../../services/alarm_scheduler.dart';
// import '../../stores/observable_alarm/observable_alarm.dart';

class EditAlarm extends StatelessWidget {
  final ObservableAlarm alarm;
  final AlarmListManager manager;

  EditAlarm({required this.alarm, required this.manager});

  @override
  Widget build(BuildContext context) {
    // 화면이 종료될때 동작을 정의
    return WillPopScope(
      onWillPop: () async {
        // 편집된 알람 설정 정의
        await manager.saveAlarm(alarm);
        // 알람 스케줄러 호출 및 알람 예약
        await AlarmScheduler().scheduleAlarm(alarm);
        return true;
      },
      child: DefaultContainer(
        child: SingleChildScrollView(
          child: Column(children: [
            Text(
              'Alarm',
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    // 알람 헤더(제목 및 알람 활성화)
                    EditAlarmHead(alarm: this.alarm),
                    Divider(),
                    // 알람 시간
                    EditAlarmTime(alarm: this.alarm),
                    Divider(),
                    // 알람 반복 요일
                    EditAlarmDays(alarm: this.alarm),
                    Divider(),
                    // 알람 음악
                    EditAlarmMusic(alarm: this.alarm),
                    Divider(),
                    // 알람 볼륨
                    EditAlarmSlider(alarm: this.alarm)
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
