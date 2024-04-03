import 'package:flutter/material.dart';
import 'package:flutter_alarm_plus/components/default_container/default_container.dart';
import 'package:flutter_alarm_plus/services/alarm_list_manager.dart';
import 'package:flutter_alarm_plus/services/alarm_scheduler.dart';
import 'package:flutter_alarm_plus/stores/observable_alarm/observable_alarm.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'components/edit_alarm_days.dart';
import 'components/edit_alarm_head.dart';
import 'components/edit_alarm_music.dart';
import 'components/edit_alarm_slider.dart';
import 'components/edit_alarm_time.dart';

class EditAlarm extends StatelessWidget {
  final ObservableAlarm alarm;
  final AlarmListManager manager;
  final int alarmId;

  EditAlarm({required this.alarm, required this.manager, required this.alarmId});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기 버튼을 눌렀을 때 실행되는 코드
        // 해당 알람이 새로 생성된 알람인 경우 (id가 null인 경우)
        if (alarm.id == alarmId) {
          // 알람 목록에서 해당 알람을 제거
          manager.removeAlarm(alarm);
        }
        return true;
      },
      child: DefaultContainer(
        child: SingleChildScrollView(
          child: Column(children: [
            Card(
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    EditAlarmTime(alarm: this.alarm),
                    Divider(),
                    // 알람 반복 요일
                    EditAlarmDays(alarm: this.alarm),
                    Divider(),
                    EditAlarmHead(alarm: this.alarm),
                    Divider(),
                    // 알람 음악
                    EditAlarmMusic(alarm: this.alarm),
                    SizedBox(height: 20),
                    Divider(),
                    Observer(
                      builder: (_) => SwitchListTile(
                        title: Text('Notification'),
                        value: alarm.notificationEnabled,
                        onChanged: (value) {
                          alarm.notificationEnabled = value;
                        },
                      ),
                    ),
                    // 저장 버튼 추가
                    ElevatedButton(
                      onPressed: () async {
                        // 편집된 알람 설정 정의
                        await manager.saveAlarm(alarm);
                        // 알람 스케줄러 호출 및 알람 예약
                        await AlarmScheduler().scheduleAlarm(alarm);
                        // 화면 종료
                        Navigator.pop(context);
                      },
                      child: Text('Save'),
                    ),
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