import 'package:uuid/uuid.dart';

enum ReadingStatus {
  currentlyReading,
  read,
  wantToRead,
}

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String isbn;
  final String description;
  final int pageCount;
  final int currentPage;
  final ReadingStatus status;
  final DateTime addedDate;
  final DateTime? startedReading;
  final DateTime? finishedReading;
  final List<String> genres;
  final List<Note> notes;
  final String pdfUrl;
  
  Book({
    String? id,
    required this.title,
    required this.author,
    this.coverUrl = '',
    this.isbn = '',
    this.description = '',
    this.pageCount = 0,
    this.currentPage = 0,
    required this.status,
    DateTime? addedDate,
    this.startedReading,
    this.finishedReading,
    List<String>? genres,
    List<Note>? notes,
    this.pdfUrl = '',
  }) : 
    id = id ?? const Uuid().v4(),
    addedDate = addedDate ?? DateTime.now(),
    genres = genres ?? [],
    notes = notes ?? [];
  
  double get readingProgress {
    if (pageCount == 0) return 0.0;
    return currentPage / pageCount;
  }
  
  Book copyWith({
    String? title,
    String? author,
    String? coverUrl,
    String? isbn,
    String? description,
    int? pageCount,
    int? currentPage,
    ReadingStatus? status,
    DateTime? addedDate,
    DateTime? startedReading,
    DateTime? finishedReading,
    List<String>? genres,
    List<Note>? notes,
    String? pdfUrl,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      isbn: isbn ?? this.isbn,
      description: description ?? this.description,
      pageCount: pageCount ?? this.pageCount,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      addedDate: addedDate ?? this.addedDate,
      startedReading: startedReading ?? this.startedReading,
      finishedReading: finishedReading ?? this.finishedReading,
      genres: genres ?? this.genres,
      notes: notes ?? this.notes,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'isbn': isbn,
      'description': description,
      'pageCount': pageCount,
      'currentPage': currentPage,
      'status': status.index,
      'addedDate': addedDate.millisecondsSinceEpoch,
      'startedReading': startedReading?.millisecondsSinceEpoch,
      'finishedReading': finishedReading?.millisecondsSinceEpoch,
      'genres': genres.join(','),
      'notes': notes.map((note) => note.toMap()).toList(),
      'pdfUrl': pdfUrl,
    };
  }
  
  factory Book.fromMap(Map<String, dynamic> map) {
    List<Note> notesList = [];
    if (map['notes'] != null) {
      if (map['notes'] is String) {
        // Handle case where notes might be stored as a string in DB
        if ((map['notes'] as String).isNotEmpty) {
          // Parse the string if needed
        }
      } else if (map['notes'] is List) {
        notesList = (map['notes'] as List)
            .map((noteMap) => Note.fromMap(noteMap))
            .toList();
      }
    }
    
    List<String> genresList = [];
    if (map['genres'] != null && map['genres'] is String) {
      genresList = (map['genres'] as String).split(',')
          .where((genre) => genre.isNotEmpty)
          .toList();
    }
    
    return Book(
      id: map['id'],
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      isbn: map['isbn'] ?? '',
      description: map['description'] ?? '',
      pageCount: map['pageCount'] ?? 0,
      currentPage: map['currentPage'] ?? 0,
      status: ReadingStatus.values[map['status'] ?? 0],
      addedDate: DateTime.fromMillisecondsSinceEpoch(map['addedDate'] ?? DateTime.now().millisecondsSinceEpoch),
      startedReading: map['startedReading'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startedReading'])
          : null,
      finishedReading: map['finishedReading'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['finishedReading'])
          : null,
      genres: genresList,
      notes: notesList,
      pdfUrl: map['pdfUrl'] ?? '',
    );
  }
}

class Note {
  final String id;
  final String content;
  final DateTime createdAt;
  final int pageNumber;
  final bool isHighlight;
  
  Note({
    String? id,
    required this.content,
    DateTime? createdAt,
    this.pageNumber = 0,
    this.isHighlight = false,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'pageNumber': pageNumber,
      'isHighlight': isHighlight ? 1 : 0,
    };
  }
  
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      pageNumber: map['pageNumber'] ?? 0,
      isHighlight: map['isHighlight'] == 1,
    );
  }
} 