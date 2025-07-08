// lib/navigation_state.dart
import 'package:flutter/foundation.dart'; // ChangeNotifier のために必要

class NavigationState with ChangeNotifier {
  int _selectedIndex = 0; // プライベート変数としてインデックスを保持

  // 現在のインデックスを取得するためのゲッター
  int get selectedIndex => _selectedIndex;

  // インデックスを更新し、リスナーに変更を通知するメソッド
  void updateIndex(int newIndex) {
    if (_selectedIndex != newIndex) {
      _selectedIndex = newIndex;
      notifyListeners(); // 変更をリスナー（UIなど）に通知
    }
  }
}