import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/providers/book_provider.dart';
import 'package:book_tracker/providers/reading_goal_provider.dart';
import 'package:book_tracker/providers/theme_provider.dart';
import 'package:book_tracker/screens/book_list_screen.dart';
import 'package:book_tracker/screens/goals_screen.dart';
import 'package:book_tracker/screens/search_screen.dart';
import 'package:book_tracker/screens/profile_screen.dart';
import 'package:book_tracker/screens/add_book_screen.dart';
import 'package:book_tracker/models/book.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    BookshelfTab(),
    GoalsScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBookScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class BookshelfTab extends StatefulWidget {
  const BookshelfTab({super.key});

  @override
  State<BookshelfTab> createState() => _BookshelfTabState();
}

class _BookshelfTabState extends State<BookshelfTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookshelf'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Reading'),
            Tab(text: 'Read'),
            Tab(text: 'Want to Read'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BookListScreen(
            books: bookProvider.currentlyReading,
            emptyMessage: 'You\'re not reading any books right now',
            onRefresh: () async {
              await bookProvider.loadBooks();
            },
          ),
          BookListScreen(
            books: bookProvider.read,
            emptyMessage: 'You haven\'t finished any books yet',
            onRefresh: () async {
              await bookProvider.loadBooks();
            },
          ),
          BookListScreen(
            books: bookProvider.wantToRead,
            emptyMessage: 'Add books you want to read in the future',
            onRefresh: () async {
              await bookProvider.loadBooks();
            },
          ),
        ],
      ),
    );
  }
} 