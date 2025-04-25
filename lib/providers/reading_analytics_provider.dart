import 'package:flutter/foundation.dart';
import 'package:book_tracker/models/reading_session.dart';
import 'package:book_tracker/services/reading_analytics_service.dart';
import 'package:book_tracker/models/book.dart';

class ReadingAnalyticsProvider with ChangeNotifier {
  final ReadingAnalyticsService _analyticsService = ReadingAnalyticsService();
  
  // Reading sessions
  List<ReadingSession> _sessions = [];
  ReadingStreak _currentStreak = ReadingStreak(
    currentStreak: 0,
    longestStreak: 0,
    lastReadDate: DateTime(2000),
  );
  
  // Analytics data
  List<DailyReadingStats> _dailyStats = [];
  Map<String, double> _weekdayDistribution = {};
  Map<String, double> _timeOfDayDistribution = {};
  List<Map<String, dynamic>> _readingSpeedData = [];
  
  // Active reading session
  ReadingSession? _activeSession;
  Book? _activeBook;
  DateTime? _sessionStartTime;
  int? _sessionStartPage;
  
  // Getters
  List<ReadingSession> get sessions => _sessions;
  ReadingStreak get currentStreak => _currentStreak;
  List<DailyReadingStats> get dailyStats => _dailyStats;
  Map<String, double> get weekdayDistribution => _weekdayDistribution;
  Map<String, double> get timeOfDayDistribution => _timeOfDayDistribution;
  List<Map<String, dynamic>> get readingSpeedData => _readingSpeedData;
  bool get hasActiveSession => _activeSession != null;
  Book? get activeBook => _activeBook;
  
  // Initialize the provider
  Future<void> init() async {
    await loadAnalytics();
  }
  
  // Load all analytics data
  Future<void> loadAnalytics() async {
    try {
      _sessions = await _analyticsService.getAllSessions();
      _currentStreak = await _analyticsService.getCurrentStreak();
      _dailyStats = await _analyticsService.getDailyStatsForPastDays(30);
      _weekdayDistribution = await _analyticsService.getWeekdayDistribution();
      _timeOfDayDistribution = await _analyticsService.getTimeOfDayDistribution();
      _readingSpeedData = await _analyticsService.getReadingSpeedOverTime(14);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }
  }
  
  // Start a reading session
  void startReadingSession(Book book, int startPage) {
    if (_activeSession != null) {
      debugPrint('Warning: A reading session is already active. Ending previous session.');
      endReadingSession(startPage);
    }
    
    _activeBook = book;
    _sessionStartTime = DateTime.now();
    _sessionStartPage = startPage;
    
    notifyListeners();
  }
  
  // End the active reading session
  Future<void> endReadingSession(int endPage) async {
    if (_activeBook == null || _sessionStartTime == null || _sessionStartPage == null) {
      debugPrint('Warning: No active reading session to end.');
      return;
    }
    
    final now = DateTime.now();
    final session = ReadingSession(
      bookId: _activeBook!.id,
      startTime: _sessionStartTime!,
      endTime: now,
      startPage: _sessionStartPage!,
      endPage: endPage,
    );
    
    // Only record if the session is longer than 1 minute
    if (session.durationMinutes > 1) {
      await _analyticsService.recordSession(session);
      _sessions.add(session);
      _currentStreak = await _analyticsService.getCurrentStreak();
      
      // Update statistics
      await loadAnalytics();
    }
    
    // Clear the active session
    _activeSession = null;
    _activeBook = null;
    _sessionStartTime = null;
    _sessionStartPage = null;
    
    notifyListeners();
  }
  
  // Cancel the active reading session
  void cancelReadingSession() {
    _activeSession = null;
    _activeBook = null;
    _sessionStartTime = null;
    _sessionStartPage = null;
    
    notifyListeners();
  }
  
  // Get sessions for a specific book
  Future<List<ReadingSession>> getSessionsForBook(String bookId) async {
    return await _analyticsService.getSessionsForBook(bookId);
  }
  
  // Get average reading speed for a book
  Future<double> getAverageReadingSpeedForBook(String bookId) async {
    final sessions = await getSessionsForBook(bookId);
    if (sessions.isEmpty) return 0;
    
    double totalPagesPerHour = 0;
    int totalMinutes = 0;
    
    for (final session in sessions) {
      totalMinutes += session.durationMinutes;
      totalPagesPerHour += session.pagesPerHour * session.durationMinutes;
    }
    
    return totalMinutes > 0 ? totalPagesPerHour / totalMinutes : 0;
  }
  
  // Estimate time to finish a book
  Future<int> estimateTimeToFinish(Book book) async {
    if (book.status != ReadingStatus.currentlyReading) return 0;
    
    final pagesLeft = book.pageCount - book.currentPage;
    if (pagesLeft <= 0) return 0;
    
    final averageSpeed = await getAverageReadingSpeedForBook(book.id);
    if (averageSpeed <= 0) return 0;
    
    // Return estimated minutes
    return (pagesLeft / averageSpeed * 60).round();
  }
} 