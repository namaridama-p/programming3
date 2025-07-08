import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider をインポート
import '../db/lecture_model.dart';
import '../components/schedule_state.dart'; // ScheduleState をインポート

class TodayLectureListItem extends StatelessWidget {
  final Lecture lecture;
  final String dayKey;
  final String periodKey;

  const TodayLectureListItem({
    super.key,
    required this.lecture,
    required this.dayKey,
    required this.periodKey,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleState = context.read<ScheduleState>();

    return Column( // ボタン追加のために Column でラップ
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 2.0),
              child: Text(lecture.periodDisplay, style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lecture.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  if (lecture.displayStatuses.isNotEmpty) const SizedBox(height: 6),
                  Row(
                    children: lecture.displayStatuses.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(status, style: TextStyle(color: Colors.green[700], fontSize: 13)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // ボタンとのスペース
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)), // 少し小さく
              onPressed: () {
                scheduleState.incrementMiss(dayKey, periodKey);
              },
              child: const Text("欠席", style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)), // 少し小さく
              onPressed: () {
                scheduleState.incrementDelay(dayKey, periodKey);
              },
              child: const Text("遅刻", style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }
}