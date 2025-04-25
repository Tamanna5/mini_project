import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/providers/book_provider.dart';
import 'package:book_tracker/providers/reading_goal_provider.dart';
import 'package:book_tracker/providers/theme_provider.dart';
import 'package:book_tracker/providers/user_auth_provider.dart';
import 'package:book_tracker/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_tracker/models/reading_goal.dart';
import 'package:book_tracker/models/book.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _displayName = 'Book Lover';
  String _bio = 'Joined April 2025';
  int _avatarIndex = 0;
  
  // Predefined avatars (same as settings screen)
  final List<IconData> _avatarIcons = [
    Icons.person,
    Icons.face,
    Icons.sentiment_satisfied,
    Icons.emoji_emotions,
    Icons.psychology,
    Icons.self_improvement,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('user_display_name') ?? 'Book Lover';
      _bio = prefs.getString('user_bio') ?? 'Avid reader and book enthusiast';
      _avatarIndex = prefs.getInt('user_avatar_index') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final goalProvider = Provider.of<ReadingGoalProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    // Calculate statistics
    final totalBooks = bookProvider.allBooks.length;
    final booksRead = bookProvider.read.length;
    final currentlyReading = bookProvider.currentlyReading.length;
    final wantToRead = bookProvider.wantToRead.length;
    
    final totalPages = bookProvider.allBooks.fold<int>(
      0, (sum, book) => sum + book.pageCount);
    
    // Calculate actual pages read: sum of completed books' page counts plus current pages in books being read
    final pagesRead = bookProvider.read.fold<int>(
      0, (sum, book) => sum + book.pageCount) + 
      bookProvider.currentlyReading.fold<int>(
      0, (sum, book) => sum + book.currentPage);
      
    final currentProgress = bookProvider.currentlyReading.fold<int>(
      0, (sum, book) => sum + book.currentPage);
    
    final activeGoals = goalProvider.activeGoals.length;
    final completedGoals = goalProvider.completedGoals.length;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await bookProvider.loadBooks();
          await goalProvider.loadGoals();
          await _loadUserData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar with Profile Info
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              _avatarIcons[_avatarIndex],
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _displayName,
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bio,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                titlePadding: EdgeInsets.zero,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ).then((_) => _loadUserData());
                  },
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary cards at the top
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickStat('Books', totalBooks.toString(), Icons.auto_stories, colorScheme.primary),
                          Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3)),
                          _buildQuickStat('Pages', pagesRead.toString(), Icons.description, colorScheme.secondary),
                          Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3)),
                          _buildQuickStat('Goals', completedGoals.toString(), Icons.emoji_events, Colors.amber),
                        ],
                      ),
                    ),
                    
                    // Reading statistics
                    Row(
                      children: [
                        Icon(Icons.bar_chart, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Reading Statistics',
                          style: textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Statistics cards
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          context,
                          'Total Books',
                          totalBooks.toString(),
                          Icons.menu_book,
                          colorScheme.primary,
                        ),
                        _buildStatCard(
                          context,
                          'Books Completed',
                          booksRead.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatCard(
                          context,
                          'Currently Reading',
                          currentlyReading.toString(),
                          Icons.auto_stories,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          'Want to Read',
                          wantToRead.toString(),
                          Icons.bookmark,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          'Pages Read',
                          pagesRead.toString(),
                          Icons.description,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          context,
                          'Current Progress',
                          '$currentProgress pages',
                          Icons.trending_up,
                          Colors.teal,
                        ),
                      ],
                    ),
                    
                    // Book Achievements Section (if has completed books)
                    if (booksRead > 0) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Reading Achievements',
                            style: textTheme.titleLarge,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // Navigate to a detailed view of completed books
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildCompletedBooksSection(context, bookProvider.read),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Goals section
                    Row(
                      children: [
                        Icon(Icons.flag, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Reading Goals',
                          style: textTheme.titleLarge,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/goals');
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (activeGoals == 0)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                size: 48,
                                color: colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No active goals',
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Set a reading goal to track your progress',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/goals');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Goal'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < goalProvider.activeGoals.length; i++) 
                              _buildActiveGoalItem(context, goalProvider.activeGoals[i], i < goalProvider.activeGoals.length - 1),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Settings section
                    Row(
                      children: [
                        Icon(Icons.settings, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Settings',
                          style: textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Dark mode toggle
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            secondary: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                            ),
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.setDarkMode(value);
                            },
                          ),
                          
                          const Divider(height: 1),
                          
                          // App info
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('About'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: 'Book Tracker',
                                applicationVersion: '1.0.0',
                                applicationIcon: FlutterLogo(
                                  size: 50,
                                  style: FlutterLogoStyle.stacked,
                                ),
                                children: [
                                  const Text(
                                    'A book tracking application that allows users to manage their reading journey.',
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const Divider(height: 1),
                          
                          // Export data
                          ListTile(
                            leading: const Icon(Icons.data_object),
                            title: const Text('Export Reading Data'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/settings').then((_) => _loadUserData());
                            },
                          ),
                          
                          const Divider(height: 1),
                          
                          // Privacy policy
                          ListTile(
                            leading: const Icon(Icons.privacy_tip_outlined),
                            title: const Text('Privacy Policy'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/privacy_policy');
                            },
                          ),
                          
                          const Divider(height: 1),
                          
                          // Sign out
                          ListTile(
                            leading: Icon(Icons.logout, color: Colors.red.shade300),
                            title: Text('Sign Out', style: TextStyle(color: Colors.red.shade300)),
                            onTap: () async {
                              final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text('Are you sure you want to sign out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Sign Out'),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirm == true) {
                                await authProvider.signOut();
                                if (mounted) {
                                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveGoalItem(BuildContext context, ReadingGoal goal, bool showDivider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    // Format goal type
    String goalTypeText = 'items'; // Default value
    IconData goalIcon = Icons.flag;
    Color goalColor = colorScheme.primary;
    
    switch (goal.type) {
      case GoalType.booksCount:
        goalTypeText = goal.target == 1 ? 'book' : 'books';
        goalIcon = Icons.menu_book;
        goalColor = Colors.blue;
        break;
      case GoalType.pagesCount:
        goalTypeText = goal.target == 1 ? 'page' : 'pages';
        goalIcon = Icons.description;
        goalColor = Colors.purple;
        break;
      case GoalType.minutesRead:
        goalTypeText = goal.target == 1 ? 'minute' : 'minutes';
        goalIcon = Icons.timer;
        goalColor = Colors.orange;
        break;
    }
    
    // Calculate days remaining
    final daysRemaining = goal.endDate.difference(DateTime.now()).inDays;
    final isNearDeadline = daysRemaining <= 3 && !goal.isCompleted;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: goalColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  goalIcon,
                  color: goalColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${goal.target} $goalTypeText',
                style: textTheme.bodyMedium,
              ),
              if (!goal.isCompleted && daysRemaining >= 0)
                Text(
                  '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} left',
                  style: textTheme.bodySmall?.copyWith(
                    color: isNearDeadline ? Colors.red : null,
                    fontWeight: isNearDeadline ? FontWeight.bold : null,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Stack(
            children: [
              LinearProgressIndicator(
                value: goal.progressPercentage > 1.0 ? 1.0 : goal.progressPercentage,
                backgroundColor: colorScheme.primaryContainer,
                color: goal.isCompleted ? Colors.green : goalColor,
                borderRadius: BorderRadius.circular(4),
                minHeight: 10,
              ),
              if (goal.progressPercentage >= 0.1)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${(goal.progressPercentage * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.progress} of ${goal.target}',
                style: textTheme.bodySmall,
              ),
              if (goal.type == GoalType.booksCount && goal.progress > 0)
                Row(
                  children: [
                    Icon(Icons.auto_stories, size: 14, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.progress} completed',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
            ],
          ),
          
          if (showDivider) 
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(height: 1, color: theme.dividerColor),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedBooksSection(BuildContext context, List<Book> completedBooks) {
    final theme = Theme.of(context);
    
    // Take only the 3 most recently completed books
    final recentlyCompleted = completedBooks.length > 3 
        ? completedBooks.sublist(0, 3) 
        : completedBooks;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Achievement Stats
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Total completed 
                Column(
                  children: [
                    Text(
                      '${completedBooks.length}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Books Completed'),
                  ],
                ),
                
                // Total pages read
                Column(
                  children: [
                    Text(
                      '${completedBooks.fold<int>(0, (sum, book) => sum + book.pageCount)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const Text('Pages Read'),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Recently completed books
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recently Completed',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (var book in recentlyCompleted)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: book.coverUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    book.coverUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.book,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.book,
                                  color: theme.colorScheme.primary,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                book.author,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${book.pageCount} pages',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 