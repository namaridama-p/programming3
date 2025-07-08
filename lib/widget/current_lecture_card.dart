import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider をインポート
import '../db/lecture_model.dart';
import '../components/schedule_state.dart'; // ScheduleState をインポート

class CurrentLectureCard extends StatelessWidget {
  final Lecture lecture;
  final String dayKey;    // "monday", "tuesday" など
  final String periodKey; // "1", "2" など (Lecture.periodNumber.toString() から取得)

  const CurrentLectureCard({
    super.key,
    required this.lecture,
    required this.dayKey,
    required this.periodKey,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleState = context.read<ScheduleState>(); // read で ScheduleState を取得

    return Card(
      // ... (既存のCard設定は省略)
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lecture.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: lecture.displayStatuses.map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(status, style: TextStyle(color: Colors.green[700], fontSize: 14)),
                    );
                  }).toList(),
                ),
                if (lecture.isChecked)
                  Icon(Icons.check_circle_outline, color: Colors.green[700], size: 28),
              ],
            ),
            const SizedBox(height: 15), // ボタンとのスペース
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // ボタンを右寄せ
              children: [
                TextButton(
                  onPressed: () {
                    scheduleState.incrementMiss(dayKey, periodKey);
                  },
                  child: const Text("欠席"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    scheduleState.incrementDelay(dayKey, periodKey);
                  },
                  child: const Text("遅刻"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}