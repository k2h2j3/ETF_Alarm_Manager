import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../stores/observable_alarm/observable_alarm.dart';

class EditAlarmTime extends StatelessWidget {
  final ObservableAlarm alarm;

  const EditAlarmTime({Key? key, required this.alarm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // 알람시간 터치하는 위젯
      child: GestureDetector(
        child: Observer(builder: (context) {
          // 시,분 형식화. 시간과 분을 두 자리로 표시 하고 빈 부분을 0으로 채움.
          final hours = alarm.hour.toString().padLeft(2, '0');
          final minutes = alarm.minute.toString().padLeft(2, '0');
          return Text(
            '$hours:$minutes',
            style: TextStyle(fontSize: 48),
          );
        }),
        //시간 선택
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: alarm.hour, minute: alarm.minute),
          );

          // 시간이 선택되었을 경우
          if (time == null) {
            return;
          }
          // 그 시간으로 업데이트
          alarm.hour = time.hour;
          alarm.minute = time.minute;
        },
      ),
    );
  }
}
