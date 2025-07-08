// lib/models/lecture_model.dart

class Lecture {
  final String name;
  final int periodNumber;
  final bool isCurrent;
  final int missCount;
  final int delayCount;
  final int officialMissCount;
  final bool isChecked;
  final String startTime;
  final String endTime;

  Lecture({
    required this.name,
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
    this.isCurrent = false,
    this.missCount = 0,
    this.delayCount = 0,
    this.officialMissCount = 0,
    this.isChecked = false,



  });

  String get periodDisplay => "$periodNumberコマ";

  List<String> get displayStatuses {
    final List<String> statuses = [];
    if (delayCount > 0) {
      statuses.add("遅刻 $delayCount回");
    }
    if (officialMissCount > 0) {
      statuses.add("公欠 $officialMissCount回");
    }
    if (missCount > 0) { // 通常の欠席も表示するように変更
      statuses.add("欠席 $missCount回");
    }
    return statuses;
  }

  // copyWith メソッドの追加
  Lecture copyWith({
    String? name,
    int? periodNumber,
    String? startTime,
    String? endTime,
    bool? isCurrent,
    int? missCount,
    int? delayCount,
    int? officialMissCount,
    bool? isChecked,
  }) {
    return Lecture(
      name: name ?? this.name,
      periodNumber: periodNumber ?? this.periodNumber,
      isCurrent: isCurrent ?? this.isCurrent,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      missCount: missCount ?? this.missCount,
      delayCount: delayCount ?? this.delayCount,
      officialMissCount: officialMissCount ?? this.officialMissCount,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  // fromDbMap は変更なし (ただし、呼び出し側で isCurrent や isChecked を渡すことを意識)
  factory Lecture.fromDbMap(
      String name,
      int periodNumber,
      Map<String, Object> details, {
        bool isCurrentLecture = false,
        bool checkedStatus = false,
      }) {
    return Lecture(
      name: name,
      periodNumber: periodNumber,
      startTime: details['startTime'] as String? ?? '00:00',
      endTime: details['endTime'] as String? ?? '00:00',
      missCount: details['miss'] as int? ?? 0,
      delayCount: details['Delay'] as int? ?? 0,
      officialMissCount: details['official_miss'] as int? ?? 0,
      isCurrent: isCurrentLecture,
      isChecked: checkedStatus,
    );
  }
}