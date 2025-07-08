// ignore: file_names
  import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyCount = 'count';

  static Future<int> getCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCount) ?? 0;
  }

  static Future<void> setCount(int count) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCount, count);
  }

  static Future<void> clearCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCount);
  }
}