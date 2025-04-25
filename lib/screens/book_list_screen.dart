import 'package:flutter/material.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/screens/book_details_screen.dart';
import 'package:book_tracker/widgets/book_card.dart';

class BookListScreen extends StatelessWidget {
  final List<Book> books;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  const BookListScreen({
    super.key,
    required this.books,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: books.isEmpty
          ? _buildEmptyState(context)
          : _buildBookList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: BookCard(
            book: book,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailsScreen(book: book),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 