// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/schedule_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  // 曜日の英語キーを日本語に変換するヘルパー関数
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
      default:
        return dayKey; // 土日など他のキーが来た場合もそのまま表示
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. ScheduleStateから授業データを取得し、変更を監視する
    final scheduleState = context.watch<ScheduleState>();
    final schoolData = scheduleState.schoolData;

    int totalMisses = 0;
    int totalDelays = 0;
    final List<Map<String, dynamic>> allLecturesWithCounts = [];

    // 2. 全ての授業をループして、合計値と詳細リストを作成する
    schoolData.forEach((dayKey, daySchedule) {
      daySchedule.forEach((periodKey, lectureDetails) {
        final missCount = lectureDetails['miss'] as int? ?? 0;
        final delayCount = lectureDetails['Delay'] as int? ?? 0;

        totalMisses += missCount;
        totalDelays += delayCount;

        // 欠席か遅刻が1回以上ある授業だけをリストに追加する
        if (missCount > 0 || delayCount > 0) {
          allLecturesWithCounts.add({
            'day': _getJapaneseDay(dayKey),
            'period': periodKey,
            'name': lectureDetails['name'] as String? ?? '名称未定',
            'miss': missCount,
            'delay': delayCount,
          });
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.blue[50], // 背景色を設定
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3. 総合サマリーを表示するカード
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      '総合出席状況',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCountIndicator('欠席合計', totalMisses, Colors.red.shade600),
                        _buildCountIndicator('遅刻合計', totalDelays, Colors.orange.shade700),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. 授業ごとの詳細リスト
            const Text(
              '授業ごとの詳細',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            if (allLecturesWithCounts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(
                    '欠席や遅刻はありません。素晴らしい！✨',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Card(
                clipBehavior: Clip.antiAlias, // 角丸を適用するため
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: allLecturesWithCounts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lecture = allLecturesWithCounts[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        '${lecture['name']}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${lecture['day']} ${lecture['period']}時限'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (lecture['miss'] > 0)
                            Text('欠席: ${lecture['miss']}回', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold)),
                          if (lecture['miss'] > 0 && lecture['delay'] > 0)
                            const SizedBox(width: 12),
                          if (lecture['delay'] > 0)
                            Text('遅刻: ${lecture['delay']}回', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // サマリー表示用のウィジェットを切り出したヘルパー関数
  Widget _buildCountIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Text(
          '回',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}