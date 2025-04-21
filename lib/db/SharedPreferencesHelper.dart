

import 'package:shared_preferences/shared_preferences.dart';

class SheredPreferencesHelper{
  static const String _school_absence = "school_absence";

  static Future<String> getschool_absence() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_school_absence) ?? "{}";
  }

  static
}