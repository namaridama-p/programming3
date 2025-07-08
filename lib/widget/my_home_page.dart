// lib/my_home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../apis/navigation_state.dart';
import './home_screen.dart';
import './search_screen.dart';
import './profile_screen.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // 各タブに対応する画面ウィジェットのリスト (変更なし)
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  // 各タブに対応するAppBarのタイトルのリストを追加
  static const List<String> _appBarTitles = <String>[
    'ホーム', // ホームタブのタイトル
    '検索',   // 検索タブのタイトル
    'プロフィール', // プロフィールタブのタイトル
  ];

  @override
  Widget build(BuildContext context) {
    final navigationState = context.watch<NavigationState>(); // watchで状態を監視
    final selectedIndex = navigationState.selectedIndex;

    return Scaffold(
      appBar: AppBar(
          title: Text(_appBarTitles[selectedIndex]), // ここでタイトルが設定される
          // 画像に合わせて AppBar の背景色や文字色も調整可能
          backgroundColor: Colors.lightBlue, // 例: AppBar の背景色
          foregroundColor: Colors.black, // 例: AppBar の文字色やアイコン色

      ),
      body: _widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム', // このラベルと _appBarTitles の内容を合わせる
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '検索', // このラベルと _appBarTitles の内容を合わせる
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール', // このラベルと _appBarTitles の内容を合わせる
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          // context.read を使って状態を更新 (build メソッド外のコールバックなので read を使用)
          context.read<NavigationState>().updateIndex(index);
        },
      ),
    );
  }
}