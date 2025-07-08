// lib/states/schedule_state.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleState with ChangeNotifier {
  // ... (既存の _schoolDataKey, _schoolData, _isInitialized, isInitialized, schoolData ゲッター, コンストラクタ, _loadDataFromPrefs, _saveDataToPrefs, _getDefaultSchoolData は変更なし) ...
  static const String _schoolDataKey = 'school_data_key';



  Map<String, Map<String, Map<String, Object>>> _schoolData = {};
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Map<String, Map<String, Map<String, Object>>> get schoolData {
    if (!_isInitialized) {
      print("Warning: schoolData accessed before initialization completed.");
      return {};
    }
    return _schoolData;
  }

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
        print("Data loaded from SharedPreferences.");
      } catch (e) {
        print("Error decoding school data from SharedPreferences: $e");
        _schoolData = _getDefaultSchoolData();
      }
    } else {
      print("No data found in SharedPreferences, using default.");
      _schoolData = _getDefaultSchoolData();
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveDataToPrefs() async {
    if (!_isInitialized && _schoolData.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_schoolDataKey);
      print("School data key removed from SharedPreferences (reset).");
      return;
    }
    if (!_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    try {
      String jsonData = jsonEncode(_schoolData);
      await prefs.setString(_schoolDataKey, jsonData);
      print("Data saved to SharedPreferences.");
    } catch (e) {
      print("Error encoding school data to JSON: $e");
    }
  }

  Map<String, Map<String, Map<String, Object>>> _getDefaultSchoolData() {
    return {
      "monday": {
        "1": {"name": "情報工学実験3", "miss": 0, "Delay": 0, "official_miss": 0},
        "2": {"name": "情報理論", "miss": 0, "Delay": 0, "official_miss": 0},
      },
    };
  }

  void incrementMiss(String day, String periodKey) {
    if (!_isInitialized) return;
    if (_schoolData.containsKey(day) && _schoolData[day]!.containsKey(periodKey)) {
      final currentMisses = _schoolData[day]![periodKey]!['miss'] as int? ?? 0;
      _schoolData[day]![periodKey]!['miss'] = currentMisses + 1;
      notifyListeners();
      _saveDataToPrefs();
    }
  }

  void incrementDelay(String day, String periodKey) {
    if (!_isInitialized) return;
    if (_schoolData.containsKey(day) && _schoolData[day]!.containsKey(periodKey)) {
      final currentDelays = _schoolData[day]![periodKey]!['Delay'] as int? ?? 0;
      _schoolData[day]![periodKey]!['Delay'] = currentDelays + 1;
      notifyListeners();
      _saveDataToPrefs();
    }
  }

  Future<void> resetSchoolData() async {
    _schoolData = _getDefaultSchoolData();
    notifyListeners();
    await _saveDataToPrefs();
    print("School data has been reset to default.");
  }

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
    if (!_isInitialized) {
      print("Cannot add lecture: State not initialized.");
      return;
    }
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
    print("Lecture added/updated for $dayKey, period $periodKey: $lectureName");
  }

  // --- ここから追加 ---
  /// 指定された曜日の指定された時限の授業を削除します。
  Future<void> deleteLecture(String dayKey, String periodKey) async {
    if (!_isInitialized) {
      print("Cannot delete lecture: State not initialized.");
      return;
    }

    if (_schoolData.containsKey(dayKey) && _schoolData[dayKey]!.containsKey(periodKey)) {
      _schoolData[dayKey]!.remove(periodKey); // 指定された時限の授業を削除

      // もしその曜日の授業がすべてなくなったら、曜日のエントリ自体を削除する (任意)
      if (_schoolData[dayKey]!.isEmpty) {
        _schoolData.remove(dayKey);
      }

      notifyListeners(); // UIに変更を通知
      await _saveDataToPrefs(); // 変更を SharedPreferences に保存
      print("Lecture deleted for $dayKey, period $periodKey.");
    } else {
      print("Lecture not found for deletion: $dayKey, period $periodKey.");
    }
  }
// --- ここまで追加 ---
}