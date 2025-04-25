import 'package:uuid/uuid.dart';

/// A model class representing a single reading session
class ReadingSession {
  final String id;
  final String bookId;
  final DateTime startTime;
  final DateTime endTime;
  final int pagesRead;
  final int startPage;
  final int endPage;
  
  /// The duration of the reading session in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;
  
  /// The reading speed in pages per hour
  double get pagesPerHour {
    final hours = endTime.difference(startTime).inMinutes / 60;
    if (hours <= 0) return 0;
    return pagesRead / hours;
  }
  
  /// The time of day as an hour (0-23)
  int get hourOfDay => startTime.hour;
  
  /// Get the weekday (1-7, where 1 is Monday)
  int get weekday => startTime.weekday;
  
  ReadingSession({
    String? id,
    required this.bookId,
    required this.startTime,
    required this.endTime,
    required this.startPage,
    required this.endPage,
  }) : 
    id = id ?? const Uuid().v4(),
    pagesRead = endPage - startPage > 0 ? endPage - startPage : 0;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'startPage': startPage,
      'endPage': endPage,
      'pagesRead': pagesRead,
    };
  }
  
  factory ReadingSession.fromMap(Map<String, dynamic> map) {
    return ReadingSession(
      id: map['id'],
      bookId: map['bookId'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      startPage: map['startPage'],
      endPage: map['endPage'],
    );
  }
}

/// A model class representing daily reading statistics
class DailyReadingStats {
  final DateTime date;
  final int totalMinutesRead;
  final int totalPagesRead;
  final int bookCount;
  final double averagePagesPerHour;
  
  DailyReadingStats({
    required this.date,
    required this.totalMinutesRead,
    required this.totalPagesRead,
    required this.bookCount,
    required this.averagePagesPerHour,
  });
  
  factory DailyReadingStats.fromSessions(DateTime date, List<ReadingSession> sessions) {
    if (sessions.isEmpty) {
      return DailyReadingStats(
        date: date,
        totalMinutesRead: 0,
        totalPagesRead: 0,
        bookCount: 0,
        averagePagesPerHour: 0,
      );
    }
    
    final totalMinutes = sessions.fold<int>(0, (sum, session) => sum + session.durationMinutes);
    final totalPages = sessions.fold<int>(0, (sum, session) => sum + session.pagesRead);
    final uniqueBooks = sessions.map((s) => s.bookId).toSet().length;
    
    // Calculate the weighted average pages per hour
    double weightedPagesPerHour = 0;
    if (totalMinutes > 0) {
      for (final session in sessions) {
        final weight = session.durationMinutes / totalMinutes;
        weightedPagesPerHour += session.pagesPerHour * weight;
      }
    }
    
    return DailyReadingStats(
      date: date,
      totalMinutesRead: totalMinutes,
      totalPagesRead: totalPages,
      bookCount: uniqueBooks,
      averagePagesPerHour: weightedPagesPerHour,
    );
  }
}

/// A model class representing reading streaks
class ReadingStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastReadDate;
  
  ReadingStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReadDate,
  });
  
  /// Checks if the streak is still active for the current day
  bool get isActiveToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(lastReadDate.year, lastReadDate.month, lastReadDate.day);
    return lastDate.isAtSameMomentAs(today);
  }
  
  /// Checks if the streak has been broken
  bool get isStreakBroken {
    if (isActiveToday) return false;
    
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    final lastDate = DateTime(lastReadDate.year, lastReadDate.month, lastReadDate.day);
    
    return !lastDate.isAtSameMomentAs(yesterday);
  }
  
  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReadDate': lastReadDate.millisecondsSinceEpoch,
    };
  }
  
  factory ReadingStreak.fromMap(Map<String, dynamic> map) {
    return ReadingStreak(
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastReadDate: map['lastReadDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReadDate']) 
          : DateTime(2000), // Default to a past date
    );
  }
  
  ReadingStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
  }) {
    return ReadingStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }
} 