import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../stores/observable_alarm/observable_alarm.dart';

class EditAlarmTime extends StatelessWidget {
  final ObservableAlarm alarm;

  const EditAlarmTime({Key? key, required this.alarm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 216,
        padding: EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: Colors.grey, // 배경색을 검은색으로 변경
        child: SafeArea(
          top: false,
          child: Observer(
            builder: (context) => CupertinoTheme(
              data: CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    color: Colors.white, // 글자색을 하얀색으로 변경
                    fontSize: 22,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  alarm.hour,
                  alarm.minute,
                ),
                onDateTimeChanged: (DateTime newDateTime) {
                  alarm.hour = newDateTime.hour;
                  alarm.minute = newDateTime.minute;
                },
                backgroundColor: Colors.grey, // 데이트 피커 배경색을 검은색으로 변경
              ),
            ),
          ),
        ),
      ),
    );
  }
}