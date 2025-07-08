// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/schedule_state.dart';

class ProfileScreen extends StatefulWidget { // StatelessWidget から StatefulWidget に変更
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> { // Stateクラスを作成
  // フォーム用のGlobalKey
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers
  final _lectureNameController = TextEditingController();
  final _periodController = TextEditingController(); // 時限用
  // カウント用のコントローラー (オプション)
  // final _missCountController = TextEditingController(text: '0');
  // final _delayCountController = TextEditingController(text: '0');
  // final _officialMissCountController = TextEditingController(text: '0');


  // 選択された曜日を保持する変数
  String? _selectedDayKey; // 例: "monday", "tuesday"
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  final List<Map<String, String>> _days = [ // 曜日の選択肢
    {"value": "monday", "display": "月曜日"},
    {"value": "tuesday", "display": "火曜日"},
    {"value": "wednesday", "display": "水曜日"},
    {"value": "thursday", "display": "木曜日"},
    {"value": "friday", "display": "金曜日"},
    // {"value": "saturday", "display": "土曜日"}, // 必要に応じて
    // {"value": "sunday", "display": "日曜日"},   // 必要に応じて
  ];

  @override
  void dispose() {
    // コントローラーを破棄
    _lectureNameController.dispose();
    _periodController.dispose();
    // _missCountController.dispose();
    // _delayCountController.dispose();
    // _officialMissCountController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset(); // フォームの状態をリセット
    _lectureNameController.clear();
    _periodController.clear();
    // _missCountController.text = '0';
    // _delayCountController.text = '0';
    // _officialMissCountController.text = '0';
    setState(() {
      _selectedDayKey = null; // 曜日の選択もリセット
      _selectedEndTime = null;
      _selectedStartTime = null;
    });
  }
  
  String _formatTimeOfDay(TimeOfDay tod){
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDayKey == null || _selectedStartTime == null || _selectedEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('曜日と時刻をすべて選択してください。')),
        );
        return;
      }

      // ... (lectureName, periodKey の取得)
      final String lectureName = _lectureNameController.text;
      final String periodKey = _periodController.text;

      try {
        await context.read<ScheduleState>().addOrUpdateLecture(
          dayKey: _selectedDayKey!,
          periodKey: periodKey,
          lectureName: lectureName,
          startTime: _formatTimeOfDay(_selectedStartTime!), // 時刻を文字列にして渡す
          endTime: _formatTimeOfDay(_selectedEndTime!),     // 時刻を文字列にして渡す
        );
        // ... (SnackBar表示とフォームクリア)
      } catch (e) {
        // ... (エラー表示)
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // 長くなる可能性があるので SingleChildScrollView でラップ
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- データリセットセクション (前回実装) ---
            const Text('データ管理', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed: () { /* ... 確認ダイアログ表示とリセット処理 ... */
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
                            }).catchError((error){
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
            const Divider(), // 区切り線
            const SizedBox(height: 20),

            // --- 授業追加フォームセクション ---
            Text('授業の追加・編集', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 曜日選択
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

                  // 時限入力
                  TextFormField(
                    controller: _periodController,
                    decoration: const InputDecoration(labelText: '時限 (例: 1, 2)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '時限を入力してください';
                      }
                      if (int.tryParse(value) == null) {
                        return '数値を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),



                  // 授業名入力
                  TextFormField(
                    controller: _lectureNameController,
                    decoration: const InputDecoration(labelText: '授業名', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '授業名を入力してください';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lectureNameController,
                    //...
                  ),
                  const SizedBox(height: 25),
                  // TODO: オプションで欠席・遅刻等の初期値入力フィールドを追加する場合はここに
                  Row(
                    children: [
                      // 開始時刻
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedStartTime ?? TimeOfDay.now(),
                            );
                            if (picked != null && picked != _selectedStartTime) {
                              setState(() {
                                _selectedStartTime = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: '開始時刻',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedStartTime != null
                                  ? _selectedStartTime!.format(context)
                                  : '選択してください',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 終了時刻
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedEndTime ?? TimeOfDay.now(),
                            );
                            if (picked != null && picked != _selectedEndTime) {
                              setState(() {
                                _selectedEndTime = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: '終了時刻',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedEndTime != null
                                  ? _selectedEndTime!.format(context)
                                  : '選択してください',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    onPressed: _submitForm,
                    child: const Text('授業を追加/更新する', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextButton( // フォームクリアボタン
                    onPressed: _clearForm,
                    child: const Text('フォームをクリア'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            // --- ここから授業一覧と削除機能の準備（次回） ---
            Text('登録済みの授業', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              '（ここに登録授業一覧と削除ボタンを実装予定です）',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            // --- ここまで授業一覧と削除機能の準備 ---
          ],
        ),
      ),
    );
  }
}