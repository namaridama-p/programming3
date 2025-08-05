// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/lecture_model.dart'; // パスを修正
import '../components/schedule_state.dart';
import './current_lecture_card.dart';
import './today_lecture_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 曜日の番号(int)からデータ保存用のキー(String)に変換
  String _getDayKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return ''; // 該当なし
    }
  }

  // 曜日のキー(String)から日本語表記に変換
  String _getJapaneseDay(String dayKey) {
    switch (dayKey) {
      case 'monday':
        return '月曜日';
      case 'tuesday':
        return '火曜日';
      case 'wednesday':
        return '水曜日';
      case 'thursday':
        return '木曜日';
      case 'friday':
        return '金曜日';
      case 'saturday':
        return '土曜日';
      case 'sunday':
        return '日曜日';
      default:
        return '不明';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = context.watch<ScheduleState>();
    final schoolData = scheduleState.schoolData;

    // --- ここから動的処理 ---

    // 1. 現在の日時と曜日キーを取得
    final now = DateTime.now();
    final String displayDayKey = _getDayKey(now.weekday);
    final String displayDayJapanese = _getJapaneseDay(displayDayKey);

    // 2. 今日の授業データを取得
    final Map<String, Map<String, Object>>? daySchedule = schoolData[displayDayKey];

    Lecture? currentLectureObj;
    String? currentPeriodKey; // 現在の授業の時限キーを保持
    List<Lecture> todayLecturesList = [];

    if (daySchedule != null) {
      // 現在の時刻を時・分で表現
      final currentTime = TimeOfDay.fromDateTime(now);
      // 比較のために現在の時刻を「その日の0時0分からの経過分」に変換
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;

      daySchedule.forEach((periodKey, lectureDetails) {
        // "09:00" のような文字列からTimeOfDayオブジェクトを生成
        TimeOfDay parseTime(String timeStr) {
          try {
            final parts = timeStr.split(':');
            return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          } catch (e) {
            return const TimeOfDay(hour: 0, minute: 0); // 不正な形式の場合は0時0分とする
          }
        }

        final startTime = parseTime(lectureDetails['startTime'] as String? ?? '00:00');
        final endTime = parseTime(lectureDetails['endTime'] as String? ?? '00:00');

        // 開始・終了時刻も同様に経過分に変換して比較
        final startMinutes = startTime.hour * 60 + startTime.minute;
        final endMinutes = endTime.hour * 60 + endTime.minute;

        // 3. 現在時刻が授業時間内か判定 (開始時刻 <= 現在時刻 < 終了時刻)
        final bool isCurrent = (currentMinutes >= startMinutes && currentMinutes < endMinutes);

        final lecture = Lecture.fromDbMap(
          lectureDetails['name'] as String? ?? '名称未定',
          int.tryParse(periodKey) ?? 0,
          lectureDetails,
          isCurrentLecture: isCurrent,
          checkedStatus: isCurrent,
        );

        if (isCurrent) {
          currentLectureObj = lecture;
          currentPeriodKey = periodKey; // 現在の授業のキーを保存
        }
        todayLecturesList.add(lecture);
      });
      // 授業を時限順に並び替え
      todayLecturesList.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    }
    // --- ここまで動的処理 ---

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '現在授業中 (${currentLectureObj != null ? "1" : "0"}コマ)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ),
            if (currentLectureObj != null)
              CurrentLectureCard(
                lecture: currentLectureObj!,
                dayKey: displayDayKey,
                periodKey: currentPeriodKey!, // 保存しておいたキーを渡す
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Center(child: Text('現在、授業はありません。', style: TextStyle(fontSize: 16))),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '本日の授業 ($displayDayJapanese)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ),
            if (todayLecturesList.isNotEmpty)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: todayLecturesList.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lectureItem = todayLecturesList[index];
                    return TodayLectureListItem(
                      lecture: lectureItem,
                      dayKey: displayDayKey,
                      periodKey: lectureItem.periodNumber.toString(),
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Center(child: Text('本日の授業はありません。', style: TextStyle(fontSize: 16))),
              ),
          ],
        ),
      ),
    );
  }
}