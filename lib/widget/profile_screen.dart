// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/schedule_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lectureNameController = TextEditingController();
  final _periodController = TextEditingController();

  String? _selectedDayKey;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  final List<Map<String, String>> _days = [
    {"value": "monday", "display": "月曜日"},
    {"value": "tuesday", "display": "火曜日"},
    {"value": "wednesday", "display": "水曜日"},
    {"value": "thursday", "display": "木曜日"},
    {"value": "friday", "display": "金曜日"},
  ];

  @override
  void dispose() {
    _lectureNameController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _lectureNameController.clear();
    _periodController.clear();
    setState(() {
      _selectedDayKey = null;
      _selectedStartTime = null;
      _selectedEndTime = null;
    });
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDayKey == null || _selectedStartTime == null || _selectedEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('曜日と時刻をすべて選択してください。')),
        );
        return;
      }

      final String lectureName = _lectureNameController.text;
      final String periodKey = _periodController.text;
      final scheduleState = context.read<ScheduleState>();

      try {
        await scheduleState.addOrUpdateLecture(
          dayKey: _selectedDayKey!,
          periodKey: periodKey,
          lectureName: lectureName,
          startTime: _formatTimeOfDay(_selectedStartTime!),
          endTime: _formatTimeOfDay(_selectedEndTime!),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「$lectureName」を追加/更新しました。')),
        );
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  // --- ここから追加 ---
  /// 授業削除の確認ダイアログを表示するメソッド
  void _showDeleteConfirmationDialog(BuildContext context, String dayKey, String periodKey, String lectureName) {
    final scheduleState = context.read<ScheduleState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('授業の削除'),
          content: Text('「$lectureName」を本当に削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('削除', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                scheduleState.deleteLecture(dayKey, periodKey).then((_) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('「$lectureName」を削除しました。')),
                  );
                }).catchError((error) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('削除エラー: $error')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
  // --- ここまで追加 ---

  @override
  Widget build(BuildContext context) {
    // --- 授業一覧表示のために watch を使用 ---
    final scheduleState = context.watch<ScheduleState>();
    final schoolData = scheduleState.schoolData;

    // 曜日を月->金でソートするためのキーリスト
    final sortedDayKeys = schoolData.keys.toList()
      ..sort((a, b) {
        final dayOrder = {for (var i = 0; i < _days.length; i++) _days[i]['value']!: i};
        return (dayOrder[a] ?? 99).compareTo(dayOrder[b] ?? 99);
      });

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- データリセットセクション (変更なし) ---
            const Text('データ管理', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('データリセットの確認'),
                      content: const Text('本当にすべての授業データをリセットしますか？この操作は元に戻せません。'),
                      actions: <Widget>[
                        TextButton(child: const Text('キャンセル'), onPressed: () => Navigator.of(dialogContext).pop()),
                        TextButton(
                          child: const Text('リセットする', style: TextStyle(color: Colors.redAccent)),
                          onPressed: () {
                            context.read<ScheduleState>().resetSchoolData().then((_) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('データがリセットされました。')));
                            }).catchError((error) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('リセットエラー: $error')));
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('授業データをリセットする', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // --- 授業追加フォームセクション (変更なし) ---
            const Text('授業の追加・編集', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '曜日', border: OutlineInputBorder()),
                    value: _selectedDayKey,
                    hint: const Text('曜日を選択'),
                    items: _days.map((Map<String, String> day) {
                      return DropdownMenuItem<String>(
                        value: day['value'],
                        child: Text(day['display']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDayKey = newValue;
                      });
                    },
                    validator: (value) => value == null ? '曜日を選択してください' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _periodController,
                    decoration: const InputDecoration(labelText: '時限 (例: 1, 2)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '時限を入力してください';
                      if (int.tryParse(value) == null) return '数値を入力してください';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _lectureNameController,
                    decoration: const InputDecoration(labelText: '授業名', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '授業名を入力してください';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedStartTime ?? TimeOfDay.now());
                            if (picked != null) setState(() => _selectedStartTime = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: '開始時刻', border: OutlineInputBorder()),
                            child: Text(_selectedStartTime?.format(context) ?? '選択してください'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedEndTime ?? TimeOfDay.now());
                            if (picked != null) setState(() => _selectedEndTime = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: '終了時刻', border: OutlineInputBorder()),
                            child: Text(_selectedEndTime?.format(context) ?? '選択してください'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    onPressed: _submitForm,
                    child: const Text('授業を追加/更新する', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _clearForm,
                    child: const Text('フォームをクリア'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            // --- ここから授業一覧と削除機能（実装後） ---
            const Text('登録済みの授業', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),

            if (schoolData.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text('登録されている授業はありません。', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              )
            else
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: sortedDayKeys.length,
                itemBuilder: (context, index) {
                  final dayKey = sortedDayKeys[index];
                  final daySchedule = schoolData[dayKey]!;
                  final dayDisplay = _days.firstWhere((d) => d['value'] == dayKey, orElse: () => {'display': dayKey})['display']!;

                  // 時限でソート
                  final sortedPeriodKeys = daySchedule.keys.toList()..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

                  return Card(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      title: Text(dayDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      children: sortedPeriodKeys.map((periodKey) {
                        final lectureDetails = daySchedule[periodKey]!;
                        final lectureName = lectureDetails['name'] as String? ?? '名称未定';
                        final startTime = lectureDetails['startTime'] as String? ?? '--:--';
                        final endTime = lectureDetails['endTime'] as String? ?? '--:--';

                        return ListTile(
                          title: Text('$periodKey時限: $lectureName'),
                          subtitle: Text('時刻: $startTime - $endTime'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.redAccent[400]),
                            tooltip: '削除',
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, dayKey, periodKey, lectureName);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            // --- ここまで授業一覧と削除機能 ---
          ],
        ),
      ),
    );
  }
}