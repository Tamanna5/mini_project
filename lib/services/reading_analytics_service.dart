import 'package:book_tracker/models/reading_session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:book_tracker/services/database_service.dart';
import 'package:intl/intl.dart';

class ReadingAnalyticsService {
  final DatabaseService _databaseService = DatabaseService();
  
  // Table and column names
  static const String _tableReadingSessions = 'reading_sessions';
  static const String _tableStreaks = 'reading_streaks';
  
  // Initialize the database tables
  Future<void> initTables(Database db) async {
    // Reading sessions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableReadingSessions(
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        startPage INTEGER NOT NULL,
        endPage INTEGER NOT NULL,
        pagesRead INTEGER NOT NULL
      )
    ''');
    
    // Reading streaks table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableStreaks(
        id TEXT PRIMARY KEY,
        currentStreak INTEGER NOT NULL,
        longestStreak INTEGER NOT NULL,
        lastReadDate INTEGER NOT NULL
      )
    ''');
  }
  
  // CRUD operations for reading sessions
  
  /// Record a new reading session
  Future<ReadingSession> recordSession(ReadingSession session) async {
    final db = await _databaseService.database;
    
    await db.insert(
      _tableReadingSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Update streaks
    await _updateReadingStreak();
    
    return session;
  }
  
  /// Get all reading sessions
  Future<List<ReadingSession>> getAllSessions() async {
    final db = await _databaseService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(_tableReadingSessions);
    
    return List.generate(maps.length, (i) {
      return ReadingSession.fromMap(maps[i]);
    });
  }
  
  /// Get sessions for a specific book
  Future<List<ReadingSession>> getSessionsForBook(String bookId) async {
    final db = await _databaseService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableReadingSessions,
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
    
    return List.generate(maps.length, (i) {
      return ReadingSession.fromMap(maps[i]);
    });
  }
  
  /// Get sessions for a specific day
  Future<List<ReadingSession>> getSessionsForDay(DateTime date) async {
    final db = await _databaseService.database;
    
    final dayStart = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableReadingSessions,
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [dayStart, dayEnd],
    );
    
    return List.generate(maps.length, (i) {
      return ReadingSession.fromMap(maps[i]);
    });
  }
  
  /// Delete a reading session
  Future<void> deleteSession(String id) async {
    final db = await _databaseService.database;
    
    await db.delete(
      _tableReadingSessions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Analytics methods
  
  /// Get daily stats for the past N days
  Future<List<DailyReadingStats>> getDailyStatsForPastDays(int days) async {
    final List<DailyReadingStats> stats = [];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final sessions = await getSessionsForDay(date);
      stats.add(DailyReadingStats.fromSessions(date, sessions));
    }
    
    return stats.reversed.toList(); // Return in chronological order
  }
  
  /// Get weekly reading stats
  Future<Map<String, double>> getWeekdayDistribution() async {
    final Map<String, double> distribution = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };
    
    final allSessions = await getAllSessions();
    if (allSessions.isEmpty) return distribution;
    
    // Count minutes per weekday
    final Map<int, int> minutesByWeekday = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (final session in allSessions) {
      minutesByWeekday[session.weekday] = (minutesByWeekday[session.weekday] ?? 0) + session.durationMinutes;
    }
    
    // Calculate percentages
    final totalMinutes = minutesByWeekday.values.fold<int>(0, (sum, minutes) => sum + minutes);
    if (totalMinutes > 0) {
      distribution['Monday'] = (minutesByWeekday[1] ?? 0) / totalMinutes;
      distribution['Tuesday'] = (minutesByWeekday[2] ?? 0) / totalMinutes;
      distribution['Wednesday'] = (minutesByWeekday[3] ?? 0) / totalMinutes;
      distribution['Thursday'] = (minutesByWeekday[4] ?? 0) / totalMinutes;
      distribution['Friday'] = (minutesByWeekday[5] ?? 0) / totalMinutes;
      distribution['Saturday'] = (minutesByWeekday[6] ?? 0) / totalMinutes;
      distribution['Sunday'] = (minutesByWeekday[7] ?? 0) / totalMinutes;
    }
    
    return distribution;
  }
  
  /// Get time of day distribution
  Future<Map<String, double>> getTimeOfDayDistribution() async {
    final Map<String, double> distribution = {
      'Morning (5-11)': 0,
      'Afternoon (12-17)': 0,
      'Evening (18-21)': 0,
      'Night (22-4)': 0,
    };
    
    final allSessions = await getAllSessions();
    if (allSessions.isEmpty) return distribution;
    
    // Group hours into time periods
    final Map<String, int> minutesByTimePeriod = {
      'Morning (5-11)': 0,
      'Afternoon (12-17)': 0,
      'Evening (18-21)': 0,
      'Night (22-4)': 0,
    };
    
    for (final session in allSessions) {
      final hour = session.hourOfDay;
      String timePeriod;
      
      if (hour >= 5 && hour <= 11) {
        timePeriod = 'Morning (5-11)';
      } else if (hour >= 12 && hour <= 17) {
        timePeriod = 'Afternoon (12-17)';
      } else if (hour >= 18 && hour <= 21) {
        timePeriod = 'Evening (18-21)';
      } else {
        timePeriod = 'Night (22-4)';
      }
      
      minutesByTimePeriod[timePeriod] = (minutesByTimePeriod[timePeriod] ?? 0) + session.durationMinutes;
    }
    
    // Calculate percentages
    final totalMinutes = minutesByTimePeriod.values.fold<int>(0, (sum, minutes) => sum + minutes);
    if (totalMinutes > 0) {
      distribution.forEach((key, value) {
        distribution[key] = minutesByTimePeriod[key]! / totalMinutes;
      });
    }
    
    return distribution;
  }
  
  /// Get reading speed over time
  Future<List<Map<String, dynamic>>> getReadingSpeedOverTime(int days) async {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final sessions = await getSessionsForDay(date);
      
      if (sessions.isNotEmpty) {
        final dailyStats = DailyReadingStats.fromSessions(date, sessions);
        data.add({
          'date': DateFormat('MM/dd').format(date),
          'pagesPerHour': dailyStats.averagePagesPerHour.toStringAsFixed(1),
        });
      } else {
        data.add({
          'date': DateFormat('MM/dd').format(date),
          'pagesPerHour': '0',
        });
      }
    }
    
    return data;
  }
  
  // Reading streak methods
  
  /// Initialize or get the current reading streak
  Future<ReadingStreak> getCurrentStreak() async {
    final db = await _databaseService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(_tableStreaks);
    
    if (maps.isEmpty) {
      // Initialize with a new streak
      final streak = ReadingStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastReadDate: DateTime(2000), // A date in the past
      );
      
      await db.insert(
        _tableStreaks,
        {
          'id': 'streak',
          ...streak.toMap(),
        },
      );
      
      return streak;
    }
    
    return ReadingStreak.fromMap(maps.first);
  }
  
  /// Update the reading streak based on today's activity
  Future<ReadingStreak> _updateReadingStreak() async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get the current streak
    ReadingStreak streak = await getCurrentStreak();
    
    // Check if we already read today
    if (streak.isActiveToday) {
      return streak; // Already updated for today
    }
    
    // Check if the streak is broken
    if (streak.isStreakBroken) {
      // Reset the streak and start a new one
      streak = ReadingStreak(
        currentStreak: 1, // Today counts as 1
        longestStreak: streak.longestStreak,
        lastReadDate: today,
      );
    } else {
      // Continue the streak
      final newCurrentStreak = streak.currentStreak + 1;
      final newLongestStreak = newCurrentStreak > streak.longestStreak 
          ? newCurrentStreak 
          : streak.longestStreak;
          
      streak = ReadingStreak(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        lastReadDate: today,
      );
    }
    
    // Update in the database
    await db.update(
      _tableStreaks,
      {
        ...streak.toMap(),
      },
      where: 'id = ?',
      whereArgs: ['streak'],
    );
    
    return streak;
  }
} 