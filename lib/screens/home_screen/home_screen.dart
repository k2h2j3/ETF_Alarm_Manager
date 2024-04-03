import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import '../../components/alarm_item/alarm_item.dart';
import '../../components/bottom_add_button/bottom_add_button.dart';
import '../../components/default_container/default_container.dart';
import '../edit_alarm/edit_alarm.dart';
import '../../services/alarm_list_manager.dart';
import '../../services/alarm_scheduler.dart';
import '../../stores/alarm_list/alarm_list.dart';
import '../../stores/observable_alarm/observable_alarm.dart';

class HomeScreen extends StatelessWidget {
  final AlarmList alarms;

  const HomeScreen({Key? key, required this.alarms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ALarmListManager를 사용하여 알람목록을 관리
    final AlarmListManager _manager = AlarmListManager(alarms);

    return DefaultContainer(
      child: Column(
        children: <Widget>[
          Text(
            'Your alarms',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
          Flexible(
            child: Observer(
              builder: (context) => ListView.separated(
                // 알람목록이 많지 않을 것으로 예상하여 위젯 크기 최소화
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final alarm = alarms.alarms[index];

                  // 좌우로 스와이프하여 알람을 삭제할 수 있음
                  return Dismissible(
                    key: Key(alarm.id.toString()),
                    child: AlarmItem(alarm: alarm, manager: _manager),
                    // 알람항목이 스와이프로 삭제되면
                    onDismissed: (_) {
                      // 삭제된 알람 취소
                      AlarmScheduler().clearAlarm(alarm);
                      // 해당 알람 제거
                      alarms.alarms.removeAt(index);
                    },
                  );
                },
                itemCount: alarms.alarms.length,
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ),
          // 알람을 추가하는 버튼
          BottomAddButton(
            onPressed: () {
              //현재 시간을 객체로 불러옴. 새로운 알람 초기시간설정
              TimeOfDay tod = TimeOfDay.fromDateTime(DateTime.now());
              final newAlarm = ObservableAlarm.dayList(
                  alarms.alarms.length,
                  'New Alarm',
                  tod.hour,
                  tod.minute,
                  // 볼륨
                  0.3,
                  // 알람 활성화 여부
                  true,
                  // 주 7일동안의 알람 반복여부 초기에는 모두 false
                  List.filled(7, false),
                  // 알람에 연결된 음악 플레이리스트. 초기에는 빈 리스트
                  ObservableList<String>.of([]),
                  <String>[],
                  true,
              );
              alarms.alarms.add(newAlarm);
              // 편집 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAlarm(
                    alarm: newAlarm,
                    manager: _manager,
                    alarmId: newAlarm.id,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
