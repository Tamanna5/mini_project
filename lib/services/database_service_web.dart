import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/models/reading_goal.dart';

/// Local storage implementation for web using shared_preferences.
class DatabaseServiceWeb {
  static final DatabaseServiceWeb _instance = DatabaseServiceWeb._internal();
  factory DatabaseServiceWeb() => _instance;
  DatabaseServiceWeb._internal();

  static const String _booksKey = 'books';
  static const String _goalsKey = 'reading_goals';

  // BOOKS
  Future<List<Book>> getAllBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getStringList(_booksKey) ?? [];
    return booksJson.map((str) => Book.fromMap(jsonDecode(str))).toList();
  }

  Future<List<Book>> getBooksByStatus(ReadingStatus status) async {
    final allBooks = await getAllBooks();
    return allBooks.where((book) => book.status == status).toList();
  }

  Future<Book> getBook(String id) async {
    final allBooks = await getAllBooks();
    final book = allBooks.firstWhere(
      (book) => book.id == id, 
      orElse: () => Book(
        id: id,
        title: 'Not Found',
        author: 'Unknown',
        status: ReadingStatus.wantToRead,
      ),
    );
    return book;
  }

  Future<int> insertBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final allBooks = await getAllBooks();
    allBooks.add(book);
    final booksJson = allBooks.map((b) => jsonEncode(b.toMap())).toList();
    await prefs.setStringList(_booksKey, booksJson);
    return 1;
  }

  Future<int> updateBook(Book updatedBook) async {
    final prefs = await SharedPreferences.getInstance();
    final allBooks = await getAllBooks();
    final idx = allBooks.indexWhere((b) => b.id == updatedBook.id);
    if (idx != -1) {
      allBooks[idx] = updatedBook;
      final booksJson = allBooks.map((b) => jsonEncode(b.toMap())).toList();
      await prefs.setStringList(_booksKey, booksJson);
      return 1;
    }
    return 0;
  }

  Future<int> deleteBook(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final allBooks = await getAllBooks();
    allBooks.removeWhere((b) => b.id == id);
    final booksJson = allBooks.map((b) => jsonEncode(b.toMap())).toList();
    await prefs.setStringList(_booksKey, booksJson);
    return 1;
  }

  // READING GOALS
  Future<List<ReadingGoal>> getAllReadingGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getStringList(_goalsKey) ?? [];
    return goalsJson.map((str) => ReadingGoal.fromMap(jsonDecode(str))).toList();
  }

  Future<ReadingGoal> getReadingGoal(String id) async {
    final allGoals = await getAllReadingGoals();
    final goal = allGoals.firstWhere(
      (goal) => goal.id == id, 
      orElse: () => ReadingGoal(
        id: id,
        title: 'Not Found',
        type: GoalType.booksCount,
        period: GoalPeriod.yearly,
        target: 0,
        progress: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)),
        isCompleted: false,
      ),
    );
    return goal;
  }

  Future<List<ReadingGoal>> getActiveReadingGoals() async {
    final allGoals = await getAllReadingGoals();
    final now = DateTime.now();
    return allGoals.where((goal) => 
      goal.startDate.isBefore(now) && 
      goal.endDate.isAfter(now) && 
      !goal.isCompleted
    ).toList();
  }

  Future<int> insertReadingGoal(ReadingGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final allGoals = await getAllReadingGoals();
    allGoals.add(goal);
    final goalsJson = allGoals.map((g) => jsonEncode(g.toMap())).toList();
    await prefs.setStringList(_goalsKey, goalsJson);
    return 1;
  }

  Future<int> updateReadingGoal(ReadingGoal updatedGoal) async {
    final prefs = await SharedPreferences.getInstance();
    final allGoals = await getAllReadingGoals();
    final idx = allGoals.indexWhere((g) => g.id == updatedGoal.id);
    if (idx != -1) {
      allGoals[idx] = updatedGoal;
      final goalsJson = allGoals.map((g) => jsonEncode(g.toMap())).toList();
      await prefs.setStringList(_goalsKey, goalsJson);
      return 1;
    }
    return 0;
  }

  Future<int> deleteReadingGoal(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final allGoals = await getAllReadingGoals();
    allGoals.removeWhere((g) => g.id == id);
    final goalsJson = allGoals.map((g) => jsonEncode(g.toMap())).toList();
    await prefs.setStringList(_goalsKey, goalsJson);
    return 1;
  }
}
