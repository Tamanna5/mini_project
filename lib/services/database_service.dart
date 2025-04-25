import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/models/reading_goal.dart';
import 'package:book_tracker/services/reading_analytics_service.dart';

// Import web implementation
import 'package:book_tracker/services/database_service_web.dart' if (dart.library.io) 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static final DatabaseServiceWeb? _webDatabase = kIsWeb ? DatabaseServiceWeb() : null;
  
  // Singleton pattern
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  Future<Database> get database async {
    if (kIsWeb) {
      throw Exception('SQLite database not available on web platform. Web platform uses Firestore instead.');
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw Exception('SQLite database not available on web platform.');
    }
    
    String path = join(await getDatabasesPath(), 'book_tracker.db');
    return await openDatabase(
      path,
      version: 2, // Increment version for schema changes
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }
  
  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Initialize analytics tables if upgrading from version 1 to 2
      final analyticsService = ReadingAnalyticsService();
      await analyticsService.initTables(db);
    }
  }
  
  Future<void> _createDb(Database db, int version) async {
    // Books table
    await db.execute('''
      CREATE TABLE books(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        coverUrl TEXT,
        isbn TEXT,
        description TEXT,
        pageCount INTEGER,
        currentPage INTEGER,
        status INTEGER,
        addedDate INTEGER,
        startedReading INTEGER,
        finishedReading INTEGER,
        genres TEXT,
        pdfUrl TEXT
      )
    ''');
    
    // Notes table with foreign key to books
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        bookId TEXT,
        content TEXT NOT NULL,
        createdAt INTEGER,
        pageNumber INTEGER,
        isHighlight INTEGER,
        FOREIGN KEY(bookId) REFERENCES books(id) ON DELETE CASCADE
      )
    ''');
    
    // Reading goals table
    await db.execute('''
      CREATE TABLE reading_goals(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type INTEGER,
        period INTEGER,
        target INTEGER,
        progress INTEGER,
        startDate INTEGER,
        endDate INTEGER,
        isCompleted INTEGER
      )
    ''');
    
    // Initialize analytics tables
    final analyticsService = ReadingAnalyticsService();
    await analyticsService.initTables(db);
  }
  
  // Book CRUD operations
  Future<int> insertBook(Book book) async {
    if (kIsWeb) {
      return _webDatabase!.insertBook(book);
    }
    
    final db = await database;
    final bookMap = book.toMap();
    
    // Remove notes from map to insert them separately
    final notes = book.notes;
    bookMap.remove('notes');
    
    // Start a transaction
    return await db.transaction((txn) async {
      // Insert the book
      final bookId = await txn.insert(
        'books',
        bookMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Insert each note with the book's ID
      for (var note in notes) {
        final noteMap = note.toMap();
        noteMap['bookId'] = book.id;
        await txn.insert(
          'notes',
          noteMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      return bookId;
    });
  }
  
  Future<Book> getBook(String id) async {
    if (kIsWeb) {
      return _webDatabase!.getBook(id);
    }
    
    final db = await database;
    
    // Get book
    final List<Map<String, dynamic>> bookMaps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (bookMaps.isEmpty) {
      throw Exception('Book not found: $id');
    }
    
    // Get notes for this book
    final List<Map<String, dynamic>> noteMaps = await db.query(
      'notes',
      where: 'bookId = ?',
      whereArgs: [id],
    );
    
    // Create book with its notes
    final book = Book.fromMap(bookMaps.first);
    final notes = noteMaps.map((noteMap) => Note.fromMap(noteMap)).toList();
    
    return book.copyWith(notes: notes);
  }
  
  Future<List<Book>> getAllBooks() async {
    if (kIsWeb) {
      return _webDatabase!.getAllBooks();
    }
    
    final db = await database;
    final List<Map<String, dynamic>> bookMaps = await db.query('books');
    
    return Future.wait(bookMaps.map((bookMap) async {
      final bookId = bookMap['id'];
      final List<Map<String, dynamic>> noteMaps = await db.query(
        'notes',
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
      
      final book = Book.fromMap(bookMap);
      final notes = noteMaps.map((noteMap) => Note.fromMap(noteMap)).toList();
      
      return book.copyWith(notes: notes);
    }).toList());
  }
  
  Future<List<Book>> getBooksByStatus(ReadingStatus status) async {
    if (kIsWeb) {
      return _webDatabase!.getBooksByStatus(status);
    }
    
    final db = await database;
    final List<Map<String, dynamic>> bookMaps = await db.query(
      'books',
      where: 'status = ?',
      whereArgs: [status.index],
    );
    
    return Future.wait(bookMaps.map((bookMap) async {
      final bookId = bookMap['id'];
      final List<Map<String, dynamic>> noteMaps = await db.query(
        'notes',
        where: 'bookId = ?',
        whereArgs: [bookId],
      );
      
      final book = Book.fromMap(bookMap);
      final notes = noteMaps.map((noteMap) => Note.fromMap(noteMap)).toList();
      
      return book.copyWith(notes: notes);
    }).toList());
  }
  
  Future<int> updateBook(Book book) async {
    if (kIsWeb) {
      return _webDatabase!.updateBook(book);
    }
    
    final db = await database;
    final bookMap = book.toMap();
    
    // Remove notes from map to update them separately
    final notes = book.notes;
    bookMap.remove('notes');
    
    // Start a transaction
    return await db.transaction((txn) async {
      // Update the book
      await txn.update(
        'books',
        bookMap,
        where: 'id = ?',
        whereArgs: [book.id],
      );
      
      // Delete existing notes for this book
      await txn.delete(
        'notes',
        where: 'bookId = ?',
        whereArgs: [book.id],
      );
      
      // Insert each note with the book's ID
      for (var note in notes) {
        final noteMap = note.toMap();
        noteMap['bookId'] = book.id;
        await txn.insert(
          'notes',
          noteMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      return 1;
    });
  }
  
  Future<int> deleteBook(String id) async {
    if (kIsWeb) {
      return _webDatabase!.deleteBook(id);
    }
    
    final db = await database;
    
    // Delete book (cascade will delete related notes)
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Reading Goal CRUD operations
  Future<int> insertReadingGoal(ReadingGoal goal) async {
    if (kIsWeb) {
      return _webDatabase!.insertReadingGoal(goal);
    }
    
    final db = await database;
    return await db.insert(
      'reading_goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<ReadingGoal> getReadingGoal(String id) async {
    if (kIsWeb) {
      return _webDatabase!.getReadingGoal(id);
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      throw Exception('Reading goal not found: $id');
    }
    
    return ReadingGoal.fromMap(maps.first);
  }
  
  Future<List<ReadingGoal>> getAllReadingGoals() async {
    if (kIsWeb) {
      return _webDatabase!.getAllReadingGoals();
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reading_goals');
    
    return maps.map((map) => ReadingGoal.fromMap(map)).toList();
  }
  
  Future<List<ReadingGoal>> getActiveReadingGoals() async {
    if (kIsWeb) {
      return _webDatabase!.getActiveReadingGoals();
    }
    
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_goals',
      where: 'startDate <= ? AND endDate >= ? AND isCompleted = 0',
      whereArgs: [now, now],
    );
    
    return maps.map((map) => ReadingGoal.fromMap(map)).toList();
  }
  
  Future<int> updateReadingGoal(ReadingGoal goal) async {
    if (kIsWeb) {
      return _webDatabase!.updateReadingGoal(goal);
    }
    
    final db = await database;
    return await db.update(
      'reading_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }
  
  Future<int> deleteReadingGoal(String id) async {
    if (kIsWeb) {
      return _webDatabase!.deleteReadingGoal(id);
    }
    
    final db = await database;
    return await db.delete(
      'reading_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}