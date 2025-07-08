import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider をインポート
import '../db/lecture_model.dart';
import '../components/schedule_state.dart'; // ScheduleState をインポート
import './current_lecture_card.dart';
import './today_lecture_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ScheduleState からデータを取得
    final scheduleState = context.watch<ScheduleState>(); // watch で変更を監視
    final schoolData = scheduleState.schoolData;

    // --- デモ用のデータ処理 (ScheduleStateのデータを使う) ---
    const String displayDayKey = "monday"; // 表示する曜日キー
    final Map<String, Map<String, Object>>? daySchedule = schoolData[displayDayKey];

    Lecture? currentLectureObj;
    List<Lecture> todayLecturesList = [];

    if (daySchedule != null) {
      const String currentPeriodKeyForDemo = "1"; // 現在の授業とする時限キー (デモ用)

      daySchedule.forEach((periodKey, lectureDetailsMap) {
        final lectureName = lectureDetailsMap['name'] as String? ?? '名称未定';
        final periodNum = int.tryParse(periodKey) ?? 0;
        final details = lectureDetailsMap; // as Map<String, Object>;

        bool isCurrent = (periodKey == currentPeriodKeyForDemo);

        final lecture = Lecture.fromDbMap(
          lectureName,
          periodNum,
          details,
          isCurrentLecture: isCurrent,
          checkedStatus: isCurrent, // デモでは現在の授業にチェック
        );

        if (isCurrent) {
          currentLectureObj = lecture;
        }
        todayLecturesList.add(lecture);
      });
      todayLecturesList.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    }
    // --- ここまでデモ用のデータ処理 ---

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
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
                periodKey: currentLectureObj!.periodNumber.toString(), // periodNumberからperiodKeyを生成
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('現在、授業はありません。', style: TextStyle(fontSize: 16)),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '本日の授業 (${displayDayKey == "monday" ? "月曜日" : displayDayKey})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ),
            if (todayLecturesList.isNotEmpty)
              Card(
                // ... (既存のCard設定)
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: todayLecturesList.length,
                    itemBuilder: (context, index) {
                      final lectureItem = todayLecturesList[index];
                      return TodayLectureListItem(
                        lecture: lectureItem,
                        dayKey: displayDayKey,
                        periodKey: lectureItem.periodNumber.toString(), // periodNumberからperiodKeyを生成
                      );
                    },
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('本日の授業はありません。', style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}