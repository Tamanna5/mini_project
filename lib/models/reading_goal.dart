import 'package:uuid/uuid.dart';

enum GoalType {
  booksCount,
  pagesCount,
  minutesRead
}

enum GoalPeriod {
  daily,
  weekly,
  monthly,
  yearly,
  custom
}

class ReadingGoal {
  final String id;
  final String title;
  final GoalType type;
  final GoalPeriod period;
  final int target;
  final int progress;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  
  ReadingGoal({
    String? id,
    required this.title,
    required this.type,
    required this.period,
    required this.target,
    this.progress = 0,
    DateTime? startDate,
    DateTime? endDate,
    this.isCompleted = false,
  }) : 
    id = id ?? const Uuid().v4(),
    startDate = startDate ?? DateTime.now(),
    endDate = endDate ?? _calculateEndDate(period, startDate ?? DateTime.now());
  
  static DateTime _calculateEndDate(GoalPeriod period, DateTime startDate) {
    switch (period) {
      case GoalPeriod.daily:
        return DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);
      case GoalPeriod.weekly:
        // End of the week (Sunday)
        return startDate.add(Duration(days: 7 - startDate.weekday));
      case GoalPeriod.monthly:
        // End of the month
        final nextMonth = startDate.month < 12 
            ? DateTime(startDate.year, startDate.month + 1, 1)
            : DateTime(startDate.year + 1, 1, 1);
        return nextMonth.subtract(const Duration(days: 1));
      case GoalPeriod.yearly:
        // End of the year
        return DateTime(startDate.year, 12, 31);
      case GoalPeriod.custom:
        // Default to 30 days if custom and no end date specified
        return startDate.add(const Duration(days: 30));
    }
  }
  
  double get progressPercentage {
    if (target == 0) return 0.0;
    return progress / target;
  }
  
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && !isCompleted;
  }
  
  ReadingGoal copyWith({
    String? title,
    GoalType? type,
    GoalPeriod? period,
    int? target,
    int? progress,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
  }) {
    return ReadingGoal(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      period: period ?? this.period,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.index,
      'period': period.index,
      'target': target,
      'progress': progress,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
  
  factory ReadingGoal.fromMap(Map<String, dynamic> map) {
    return ReadingGoal(
      id: map['id'],
      title: map['title'] ?? '',
      type: GoalType.values[map['type'] ?? 0],
      period: GoalPeriod.values[map['period'] ?? 0],
      target: map['target'] ?? 0,
      progress: map['progress'] ?? 0,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? DateTime.now().millisecondsSinceEpoch),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch),
      isCompleted: map['isCompleted'] == 1,
    );
  }
} 