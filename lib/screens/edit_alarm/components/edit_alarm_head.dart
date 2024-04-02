import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../stores/observable_alarm/observable_alarm.dart';

class EditAlarmHead extends StatelessWidget {
  final ObservableAlarm alarm;

  EditAlarmHead({required this.alarm});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('알림 이름'),
              TextField(
                // 테두리 없앰
                decoration: InputDecoration(border: InputBorder.none),
                // 기존 알람 이름 불러오기
                controller: TextEditingController(text: alarm.name),
                style: TextStyle(fontSize: 18),
                // 이름 값이 변경될때마다 갱신
                onChanged: (newName) => alarm.name = newName,
              )
            ],
          ),
        ),
        // 알람 활성화 아이콘
        Observer(
          builder: (context) => IconButton(
            icon: alarm.active
                ? Icon(Icons.alarm, color: Colors.deepOrange)
                : Icon(Icons.alarm_off),
            onPressed: () => alarm.active = !alarm.active,
          ),
        )
      ],
    );
  }
}
