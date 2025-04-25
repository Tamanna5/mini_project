import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/providers/book_provider.dart';
import 'package:book_tracker/screens/add_note_screen.dart';
import 'package:book_tracker/screens/update_progress_screen.dart';
import 'package:book_tracker/screens/add_book_screen.dart';
import 'package:book_tracker/widgets/note_card.dart';
import 'package:intl/intl.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver app bar with book cover as background
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred book cover as background
                  book.coverUrl.isNotEmpty
                      ? Image.network(
                          book.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: colorScheme.primaryContainer,
                          ),
                        )
                      : Container(color: colorScheme.primaryContainer),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Book info
                  Positioned(
                    bottom: 16,
                    left: 140,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${book.author}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Book cover (floating on top of background)
                  Positioned(
                    left: 16,
                    bottom: -30,
                    child: Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: book.coverUrl.isNotEmpty
                            ? Image.network(
                                book.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: colorScheme.primaryContainer,
                                    child: Center(
                                      child: Text(
                                        book.title.substring(0, book.title.length > 1 ? 2 : 1),
                                        style: textTheme.headlineMedium?.copyWith(
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: colorScheme.primaryContainer,
                                child: Center(
                                  child: Text(
                                    book.title.substring(0, book.title.length > 1 ? 2 : 1),
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        actions: [
          PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookScreen(book: book),
                  ),
                );
              } else if (value == 'delete') {
                _showDeleteConfirmation(context, bookProvider);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Reading status and progress
                Container(
                    padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusChip(context, book.status),
                            if (book.status == ReadingStatus.currentlyReading)
                              Text(
                                '${book.currentPage}/${book.pageCount} pages',
                                style: textTheme.bodyMedium,
                              ),
                          ],
                        ),
                        if (book.status == ReadingStatus.currentlyReading) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearPercentIndicator(
                              lineHeight: 12,
                              percent: book.readingProgress,
                              progressColor: colorScheme.primary,
                              backgroundColor: colorScheme.primaryContainer,
                              barRadius: const Radius.circular(8),
                              padding: EdgeInsets.zero,
                              center: Text(
                                '${(book.readingProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: book.readingProgress > 0.5 ? Colors.white : colorScheme.onBackground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description section
                  if (book.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        book.description,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Book details
                        Text(
                    'Book Details',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                ),
              ],
            ),
                child: Column(
                  children: [
                        _buildInfoRow('Pages', book.pageCount.toString(), Icons.menu_book),
                    if (book.isbn.isNotEmpty)
                          _buildInfoRow('ISBN', book.isbn, Icons.qr_code),
                        _buildInfoRow('Added on', DateFormat.yMMMd().format(book.addedDate), Icons.calendar_today),
                    if (book.startedReading != null)
                          _buildInfoRow('Started reading', DateFormat.yMMMd().format(book.startedReading!), Icons.play_circle_outline),
                    if (book.finishedReading != null)
                          _buildInfoRow('Finished reading', DateFormat.yMMMd().format(book.finishedReading!), Icons.done_all),
                    if (book.genres.isNotEmpty)
                          _buildInfoRow('Genres', book.genres.join(', '), Icons.category),
                        if (book.pdfUrl.isNotEmpty)
                          _buildInfoRow('PDF', 'Available', Icons.picture_as_pdf),
                  ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notes and highlights section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes & Highlights',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                ),
                      ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddNoteScreen(bookId: book.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            book.notes.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.note_alt_outlined,
                                  size: 48,
                                  color: colorScheme.onBackground.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                        'No notes or highlights yet',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onBackground.withOpacity(0.5),
                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add notes as you read to capture your thoughts',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onBackground.withOpacity(0.4),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: book.notes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(
                        note: book.notes[index],
                        onDelete: () {
                          // TODO: Implement delete note functionality
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: book.status == ReadingStatus.currentlyReading
          ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateProgressScreen(book: book),
                      ),
                    );
                  },
              icon: const Icon(Icons.update),
              label: const Text('Update Progress'),
            )
          : null,
    );
  }

  Widget _buildStatusChip(BuildContext context, ReadingStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color backgroundColor;
    Color textColor;
    IconData iconData;
    String text;
    
    switch (status) {
      case ReadingStatus.currentlyReading:
        backgroundColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue.shade700;
        iconData = Icons.auto_stories;
        text = 'Currently Reading';
        break;
      case ReadingStatus.read:
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green.shade700;
        iconData = Icons.check_circle_outline;
        text = 'Read';
        break;
      case ReadingStatus.wantToRead:
        backgroundColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange.shade700;
        iconData = Icons.bookmark_outline;
        text = 'Want to Read';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
        text,
        style: TextStyle(
          color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
        ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon, 
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BookProvider bookProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text(
          'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await bookProvider.deleteBook(book.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 
