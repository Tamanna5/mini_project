import 'package:flutter/material.dart';
import 'package:book_tracker/models/book.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final Function()? onTap;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2, // Add subtle elevation
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover with enhanced shadow and shine effect
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Cover image or placeholder
                      book.coverUrl.isNotEmpty
                          ? Image.network(
                              book.coverUrl,
                              fit: BoxFit.cover,
                              height: 120,
                              width: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colorScheme.primaryContainer,
                                  child: Center(
                                    child: Text(
                                      book.title.substring(0, book.title.length > 1 ? 2 : 1),
                                      style: textTheme.headlineSmall?.copyWith(
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
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                      // Subtle shine effect
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Book details with improved typography
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    _buildStatusChip(context, book.status),
                    if (book.status == ReadingStatus.currentlyReading) ...[
                      const SizedBox(height: 12),
                      // Enhanced progress indicator
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: book.readingProgress,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${book.currentPage}/${book.pageCount} pages',
                            style: textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            '${(book.readingProgress * 100).toInt()}%',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ReadingStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;
    String text;
    
    switch (status) {
      case ReadingStatus.currentlyReading:
        backgroundColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue.shade700;
        iconData = Icons.auto_stories;
        text = 'Reading';
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
