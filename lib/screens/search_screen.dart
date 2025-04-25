import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/providers/book_provider.dart';
import 'package:book_tracker/screens/book_details_screen.dart';
import 'package:book_tracker/widgets/book_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _selectedGenre = '';
  List<String> _allGenres = [];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGenres();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
  
  void _loadGenres() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    Set<String> genresSet = {};
    
    // Collect all unique genres across all books
    for (var book in bookProvider.allBooks) {
      for (var genre in book.genres) {
        genresSet.add(genre);
      }
    }
    
    setState(() {
      _allGenres = genresSet.toList()..sort();
    });
  }
  
  void _search(String query) {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    bookProvider.setSearchQuery(query);
  }
  
  void _filterByGenre(String genre) {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    
    setState(() {
      if (_selectedGenre == genre) {
        // If same genre is selected, clear the filter
        _selectedGenre = '';
        bookProvider.setFilterGenre('');
      } else {
        // Set the new genre filter
        _selectedGenre = genre;
        bookProvider.setFilterGenre(genre);
      }
    });
  }
  
  void _clearFilters() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    
    setState(() {
      _selectedGenre = '';
      _searchController.clear();
      bookProvider.setFilterGenre('');
      bookProvider.setSearchQuery('');
      _searchFocus.unfocus();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final filteredBooks = bookProvider.filteredAllBooks;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Search by title, author, or description',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty || _selectedGenre.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilters,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              onChanged: _search,
            ),
          ),
          
          // Genre filters
          if (_allGenres.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Filter by: '),
                    const SizedBox(width: 8),
                    ..._allGenres.map((genre) {
                      final isSelected = _selectedGenre == genre;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (_) => _filterByGenre(genre),
                          backgroundColor: colorScheme.surfaceVariant,
                          selectedColor: colorScheme.primary.withOpacity(0.2),
                          checkmarkColor: colorScheme.primary,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          
          // Results
          Expanded(
            child: filteredBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colorScheme.onBackground.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bookProvider.allBooks.isEmpty
                              ? 'Your library is empty'
                              : 'No books match your search',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        if (bookProvider.allBooks.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Add books to get started',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onBackground.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
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
                  ),
          ),
        ],
      ),
    );
  }
} 