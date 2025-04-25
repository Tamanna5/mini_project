import 'package:flutter/foundation.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/services/database_service.dart';

class BookProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  // Book lists by reading status
  List<Book> _currentlyReading = [];
  List<Book> _read = [];
  List<Book> _wantToRead = [];
  
  // Search and filter
  String _searchQuery = '';
  String _filterGenre = '';
  
  // Getters
  List<Book> get currentlyReading => _currentlyReading;
  List<Book> get read => _read;
  List<Book> get wantToRead => _wantToRead;
  List<Book> get allBooks => [..._currentlyReading, ..._read, ..._wantToRead];
  
  String get searchQuery => _searchQuery;
  String get filterGenre => _filterGenre;
  
  // Filtered lists
  List<Book> get filteredCurrentlyReading {
    return _filterBooks(_currentlyReading);
  }
  
  List<Book> get filteredRead {
    return _filterBooks(_read);
  }
  
  List<Book> get filteredWantToRead {
    return _filterBooks(_wantToRead);
  }
  
  List<Book> get filteredAllBooks {
    return _filterBooks(allBooks);
  }
  
  // Initialize provider
  Future<void> init() async {
    await loadBooks();
  }
  
  // Load books from database
  Future<void> loadBooks() async {
    try {
      // Load books by status
      _currentlyReading = await _databaseService.getBooksByStatus(ReadingStatus.currentlyReading);
      _read = await _databaseService.getBooksByStatus(ReadingStatus.read);
      _wantToRead = await _databaseService.getBooksByStatus(ReadingStatus.wantToRead);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading books: $e');
      // Initialize with empty lists if there's an error
      _currentlyReading = [];
      _read = [];
      _wantToRead = [];
      notifyListeners();
    }
  }
  
  // Add a new book
  Future<void> addBook(Book book) async {
    try {
      await _databaseService.insertBook(book);
      // Update the appropriate list based on status
      switch (book.status) {
        case ReadingStatus.currentlyReading:
          _currentlyReading.add(book);
          break;
        case ReadingStatus.read:
          _read.add(book);
          break;
        case ReadingStatus.wantToRead:
          _wantToRead.add(book);
          break;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding book: $e');
      rethrow;
    }
  }
  
  // Update an existing book
  Future<void> updateBook(Book updatedBook) async {
    try {
      await _databaseService.updateBook(updatedBook);
      
      // Remove book from all lists and add to appropriate list
      _removeBookFromAllLists(updatedBook.id);
      
      // Add to appropriate list based on updated status
      switch (updatedBook.status) {
        case ReadingStatus.currentlyReading:
          _currentlyReading.add(updatedBook);
          break;
        case ReadingStatus.read:
          _read.add(updatedBook);
          break;
        case ReadingStatus.wantToRead:
          _wantToRead.add(updatedBook);
          break;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating book: $e');
      rethrow;
    }
  }
  
  // Delete a book
  Future<void> deleteBook(String bookId) async {
    try {
      await _databaseService.deleteBook(bookId);
      _removeBookFromAllLists(bookId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting book: $e');
      rethrow;
    }
  }
  
  // Change book status
  Future<void> changeBookStatus(String bookId, ReadingStatus newStatus) async {
    try {
      // Find book in any list
      Book? book = _findBookInAllLists(bookId);
      
      if (book != null) {
        // Create updated book with new status
        Book updatedBook = book.copyWith(
          status: newStatus,
          startedReading: newStatus == ReadingStatus.currentlyReading 
              ? DateTime.now() 
              : book.startedReading,
          finishedReading: newStatus == ReadingStatus.read 
              ? DateTime.now() 
              : book.finishedReading,
        );
        
        // Update in database
        await _databaseService.updateBook(updatedBook);
        
        // Update in memory
        _removeBookFromAllLists(bookId);
        
        // Add to appropriate list
        switch (newStatus) {
          case ReadingStatus.currentlyReading:
            _currentlyReading.add(updatedBook);
            break;
          case ReadingStatus.read:
            _read.add(updatedBook);
            break;
          case ReadingStatus.wantToRead:
            _wantToRead.add(updatedBook);
            break;
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error changing book status: $e');
      rethrow;
    }
  }
  
  // Update reading progress
  Future<void> updateReadingProgress(String bookId, int currentPage) async {
    try {
      // Find book in currently reading list
      final index = _currentlyReading.indexWhere((book) => book.id == bookId);
      
      if (index != -1) {
        Book book = _currentlyReading[index];
        Book updatedBook = book.copyWith(currentPage: currentPage);
        
        // Update in database
        await _databaseService.updateBook(updatedBook);
        
        // Update in memory
        _currentlyReading[index] = updatedBook;
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating reading progress: $e');
      rethrow;
    }
  }
  
  // Add a note to a book
  Future<void> addNoteToBook(String bookId, Note note) async {
    try {
      // Find book in any list
      Book? book = _findBookInAllLists(bookId);
      
      if (book != null) {
        List<Note> updatedNotes = [...book.notes, note];
        Book updatedBook = book.copyWith(notes: updatedNotes);
        
        // Update in database
        await _databaseService.updateBook(updatedBook);
        
        // Update in memory
        _updateBookInAllLists(updatedBook);
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding note to book: $e');
      rethrow;
    }
  }
  
  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // Set filter genre
  void setFilterGenre(String genre) {
    _filterGenre = genre;
    notifyListeners();
  }
  
  // Helper method to filter books based on search query and genre
  List<Book> _filterBooks(List<Book> books) {
    return books.where((book) {
      // Filter by search query
      final matchesQuery = _searchQuery.isEmpty || 
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by genre
      final matchesGenre = _filterGenre.isEmpty || 
          book.genres.contains(_filterGenre);
      
      return matchesQuery && matchesGenre;
    }).toList();
  }
  
  // Helper method to remove a book from all lists
  void _removeBookFromAllLists(String bookId) {
    _currentlyReading.removeWhere((book) => book.id == bookId);
    _read.removeWhere((book) => book.id == bookId);
    _wantToRead.removeWhere((book) => book.id == bookId);
  }
  
  // Helper method to find a book in any list
  Book? _findBookInAllLists(String bookId) {
    for (var book in _currentlyReading) {
      if (book.id == bookId) return book;
    }
    for (var book in _read) {
      if (book.id == bookId) return book;
    }
    for (var book in _wantToRead) {
      if (book.id == bookId) return book;
    }
    return null;
  }
  
  // Helper method to update a book in any list
  void _updateBookInAllLists(Book updatedBook) {
    switch (updatedBook.status) {
      case ReadingStatus.currentlyReading:
        final index = _currentlyReading.indexWhere((book) => book.id == updatedBook.id);
        if (index != -1) {
          _currentlyReading[index] = updatedBook;
        }
        break;
      case ReadingStatus.read:
        final index = _read.indexWhere((book) => book.id == updatedBook.id);
        if (index != -1) {
          _read[index] = updatedBook;
        }
        break;
      case ReadingStatus.wantToRead:
        final index = _wantToRead.indexWhere((book) => book.id == updatedBook.id);
        if (index != -1) {
          _wantToRead[index] = updatedBook;
        }
        break;
    }
  }
} 