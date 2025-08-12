// lib/components/schedule_state.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // 追加

class ScheduleState with ChangeNotifier {
  static const String _schoolDataKey = 'school_data_key';
  Map<String, Map<String, Map<String, Object>>> _schoolData = {};
  bool _isInitialized = false;

  // --- ここから追加 ---
  // 今日の出欠を記録した授業のキー（例: "monday-1"）を保持するSet
  Set<String> _todaysActions = {};

  // 今日の日付を 'yyyy-MM-dd' 形式の文字列で取得するゲッター
  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());
  // --- ここまで追加 ---


  bool get isInitialized => _isInitialized;
  Map<String, Map<String, Map<String, Object>>> get schoolData => _schoolData;

  ScheduleState() {
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_schoolDataKey);

    if (jsonData != null) {
      try {
        Map<String, dynamic> decodedOuterMap = jsonDecode(jsonData);
        Map<String, Map<String, Map<String, Object>>> tempSchoolData = {};
        decodedOuterMap.forEach((dayKey, dayValue) {
          if (dayValue is Map<String, dynamic>) {
            Map<String, Map<String, Object>> tempDaySchedule = {};
            dayValue.forEach((periodKey, periodValue) {
              if (periodValue is Map<String, dynamic>) {
                tempDaySchedule[periodKey] = periodValue.cast<String, Object>();
              }
            });
            tempSchoolData[dayKey] = tempDaySchedule;
          }
        });
        _schoolData = tempSchoolData;
      } catch (e) {
        _schoolData = _getDefaultSchoolData();
      }
    } else {
      _schoolData = _getDefaultSchoolData();
    }

    // --- ここから追加 ---
    // 今日のアクションログをロード
    final List<String>? savedActions = prefs.getStringList('actions_$_todayKey');
    if (savedActions != null) {
      _todaysActions = Set<String>.from(savedActions);
    } else {
      // 日付が変わっていた場合、古いキーのログは不要なのでクリアする
      _todaysActions.clear();
    }
    // --- ここまで追加 ---

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveDataToPrefs() async {
    if (!_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(_schoolData);
    await prefs.setString(_schoolDataKey, jsonData);
  }

  // --- ここから追加 ---
  // 今日のアクションログをSharedPreferencesに保存するメソッド
  Future<void> _saveTodaysActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('actions_$_todayKey', _todaysActions.toList());
  }

  // 指定された授業のボタンが今日すでに押されたかチェックするメソッド
  bool hasActionBeenTakenToday(String day, String periodKey) {
    return _todaysActions.contains('$day-$periodKey');
  }
  // --- ここまで追加 ---

  Map<String, Map<String, Map<String, Object>>> _getDefaultSchoolData() {
    return {
      "monday": {
        "1": {"name": "情報工学実験3", "miss": 0, "Delay": 0, "official_miss": 0, "startTime": "09:00", "endTime": "10:30"},
        "2": {"name": "情報理論", "miss": 0, "Delay": 0, "official_miss": 0, "startTime": "10:40", "endTime": "12:10"},
      },
    };
  }

  // --- incrementMiss メソッドを修正 ---
  Future<void> incrementMiss(String day, String periodKey) async {
    if (!_isInitialized) return;
    final actionKey = '$day-$periodKey';
    // すでにアクション済みなら何もしない
    if (_todaysActions.contains(actionKey)) return;

    if (_schoolData.containsKey(day) && _schoolData[day]!.containsKey(periodKey)) {
      final currentMisses = _schoolData[day]![periodKey]!['miss'] as int? ?? 0;
      _schoolData[day]![periodKey]!['miss'] = currentMisses + 1;
      _todaysActions.add(actionKey); // アクションを記録

      await _saveDataToPrefs();
      await _saveTodaysActions(); // アクションログも保存
      notifyListeners();
    }
  }

  // --- incrementDelay メソッドを修正 ---
  Future<void> incrementDelay(String day, String periodKey) async {
    if (!_isInitialized) return;
    final actionKey = '$day-$periodKey';
    // すでにアクション済みなら何もしない
    if (_todaysActions.contains(actionKey)) return;

    if (_schoolData.containsKey(day) && _schoolData[day]!.containsKey(periodKey)) {
      final currentDelays = _schoolData[day]![periodKey]!['Delay'] as int? ?? 0;
      _schoolData[day]![periodKey]!['Delay'] = currentDelays + 1;
      _todaysActions.add(actionKey); // アクションを記録

      await _saveDataToPrefs();
      await _saveTodaysActions();
      notifyListeners();
    }
  }

  // データリセット時にもアクションログをクリアするように修正
  Future<void> resetSchoolData() async {
    _schoolData = _getDefaultSchoolData();
    _todaysActions.clear(); // アクションログもクリア

    notifyListeners();
    await _saveDataToPrefs();
    await _saveTodaysActions(); // クリアした状態を保存
  }

  // 他のメソッド (addOrUpdateLecture, deleteLecture) は変更なし
  Future<void> addOrUpdateLecture({
    required String dayKey,
    required String periodKey,
    required String lectureName,
    required String startTime,
    required String endTime,
    int initialMiss = 0,
    int initialDelay = 0,
    int initialOfficialMiss = 0,
  }) async {
    if (!_isInitialized) return;
    if (!_schoolData.containsKey(dayKey)) {
      _schoolData[dayKey] = {};
    }
    final Map<String, Object> lectureDetails = {
      "name": lectureName,
      "startTime": startTime,
      "endTime": endTime,
      "miss": initialMiss,
      "Delay": initialDelay,
      "official_miss": initialOfficialMiss,
    };
    _schoolData[dayKey]![periodKey] = lectureDetails;
    notifyListeners();
    await _saveDataToPrefs();
  }

  Future<void> deleteLecture(String dayKey, String periodKey) async {
    if (!_isInitialized) return;
    if (_schoolData.containsKey(dayKey) && _schoolData[dayKey]!.containsKey(periodKey)) {
      _schoolData[dayKey]!.remove(periodKey);
      if (_schoolData[dayKey]!.isEmpty) {
        _schoolData.remove(dayKey);
      }
      notifyListeners();
      await _saveDataToPrefs();
    }
  }
}