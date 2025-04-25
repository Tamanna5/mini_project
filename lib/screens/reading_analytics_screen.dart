import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/providers/reading_analytics_provider.dart';
import 'package:book_tracker/models/reading_session.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReadingAnalyticsScreen extends StatefulWidget {
  const ReadingAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<ReadingAnalyticsScreen> createState() => _ReadingAnalyticsScreenState();
}

class _ReadingAnalyticsScreenState extends State<ReadingAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load analytics when screen is opened
    Future.microtask(() {
      Provider.of<ReadingAnalyticsProvider>(context, listen: false).loadAnalytics();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = Provider.of<ReadingAnalyticsProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Habits'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(analyticsProvider, theme),
          
          // Habits Tab
          _buildHabitsTab(analyticsProvider, theme),
          
          // Progress Tab
          _buildProgressTab(analyticsProvider, theme),
        ],
      ),
    );
  }
  
  Widget _buildOverviewTab(ReadingAnalyticsProvider provider, ThemeData theme) {
    final streak = provider.currentStreak;
    
    return RefreshIndicator(
      onRefresh: () => provider.loadAnalytics(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Reading Streak Card - Updated with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.secondary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Reading Streak',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${streak.currentStreak}',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'days',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${streak.longestStreak}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'longest streak',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (streak.isActiveToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Read today',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Not read today',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Stats Section
          Container(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Recent Statistics',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          if (provider.dailyStats.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reading data available yet',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start reading to see your statistics!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._buildRecentStatsCards(provider, theme),
          
          // Weekly Summary Card
          if (provider.dailyStats.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Weekly Summary',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildWeeklySummaryCard(provider, theme),
          ],
        ],
      ),
    );
  }
  
  Widget _buildWeeklySummaryCard(ReadingAnalyticsProvider provider, ThemeData theme) {
    // Get stats for past week
    final pastWeekStats = provider.dailyStats.length <= 7 
        ? provider.dailyStats 
        : provider.dailyStats.sublist(provider.dailyStats.length - 7);
    
    final daysRead = pastWeekStats.where((stats) => stats.totalMinutesRead > 0).length;
    final totalMinutesThisWeek = pastWeekStats.fold<int>(
      0, (sum, stats) => sum + stats.totalMinutesRead);
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${daysRead} out of 7 days',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: daysRead / 7,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              color: theme.colorScheme.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeekdayIndicator(0, pastWeekStats, theme),
              _buildWeekdayIndicator(1, pastWeekStats, theme),
              _buildWeekdayIndicator(2, pastWeekStats, theme),
              _buildWeekdayIndicator(3, pastWeekStats, theme),
              _buildWeekdayIndicator(4, pastWeekStats, theme),
              _buildWeekdayIndicator(5, pastWeekStats, theme),
              _buildWeekdayIndicator(6, pastWeekStats, theme),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${(totalMinutesThisWeek / 60).toStringAsFixed(1)} hours total reading time',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeekdayIndicator(int dayOffset, List<DailyReadingStats> stats, ThemeData theme) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: now.weekday - 1 - dayOffset));
    final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][dayOffset];
    
    // Check if we have reading data for this day
    final dayStats = stats.where((s) => 
      s.date.year == day.year && 
      s.date.month == day.month && 
      s.date.day == day.day
    );
    
    final hasReadingData = dayStats.isNotEmpty && dayStats.first.totalMinutesRead > 0;
    
    return Column(
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasReadingData 
                ? theme.colorScheme.primary 
                : theme.colorScheme.primary.withOpacity(0.1),
          ),
          child: hasReadingData
              ? Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
      ],
    );
  }
  
  List<Widget> _buildRecentStatsCards(ReadingAnalyticsProvider provider, ThemeData theme) {
    // Get stats for past week
    final pastWeekStats = provider.dailyStats.length <= 7 
        ? provider.dailyStats 
        : provider.dailyStats.sublist(provider.dailyStats.length - 7);
    
    // Calculate weekly totals
    final totalPagesThisWeek = pastWeekStats.fold<int>(
      0, (sum, stats) => sum + stats.totalPagesRead);
    final totalMinutesThisWeek = pastWeekStats.fold<int>(
      0, (sum, stats) => sum + stats.totalMinutesRead);
    final daysRead = pastWeekStats.where((stats) => stats.totalMinutesRead > 0).length;
    
    // Average reading speed
    double avgPagesPerHour = 0;
    if (totalMinutesThisWeek > 0) {
      for (final stats in pastWeekStats) {
        if (stats.totalMinutesRead > 0) {
          final weight = stats.totalMinutesRead / totalMinutesThisWeek;
          avgPagesPerHour += stats.averagePagesPerHour * weight;
        }
      }
    }
    
    return [
      Row(
        children: [
          Expanded(
            child: _statCard(
              theme,
              '$totalPagesThisWeek',
              'Pages Read',
              Icons.menu_book,
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _statCard(
              theme,
              '${(totalMinutesThisWeek / 60).toStringAsFixed(1)}',
              'Hours Read',
              Icons.access_time,
              theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _statCard(
              theme,
              '${avgPagesPerHour.toStringAsFixed(1)}',
              'Pages/Hour',
              Icons.speed,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _statCard(
              theme,
              '$daysRead/7',
              'Days Read',
              Icons.calendar_today,
              Colors.green,
            ),
          ),
        ],
      ),
    ];
  }
  
  Widget _statCard(ThemeData theme, String value, String label, IconData icon, Color color) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHabitsTab(ReadingAnalyticsProvider provider, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () => provider.loadAnalytics(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time of Day Distribution
          Container(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.access_time_filled, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'When You Read',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your peak reading times',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildTimeOfDayChart(provider, theme),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Day of Week Distribution
          Container(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_view_week, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Reading by Day of Week',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Which days you read most',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildWeekdayChart(provider, theme),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Reading Session History
          Container(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Recent Reading Sessions',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your latest sessions',
                      style: theme.textTheme.titleMedium,
                    ),
                    provider.sessions.isNotEmpty
                        ? TextButton.icon(
                            onPressed: () {
                              // Action to view all sessions could be added here
                            },
                            icon: Icon(Icons.arrow_forward, size: 16),
                            label: Text('View all'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSessionsList(provider.sessions, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeOfDayChart(ReadingAnalyticsProvider provider, ThemeData theme) {
    final Map<String, double> distribution = provider.timeOfDayDistribution;
    if (distribution.isEmpty || distribution.values.every((value) => value == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data available yet',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    
    final barColors = [
      Color(0xFF6750A4),  // Primary
      Color(0xFF9C27B0),  // Secondary
      Color(0xFF673AB7),  // Deep Purple
      Color(0xFF3F51B5),  // Indigo
    ];
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: distribution.values.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final key = distribution.keys.elementAt(groupIndex);
              return BarTooltipItem(
                '${key}\n${(rod.toY * 100).toStringAsFixed(1)}%',
                TextStyle(color: theme.colorScheme.onSurface),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final labels = ['Morning', 'Afternoon', 'Evening', 'Night'];
                if (value < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: List.generate(distribution.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: distribution.values.elementAt(index),
                color: barColors[index],
                width: 20,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildWeekdayChart(ReadingAnalyticsProvider provider, ThemeData theme) {
    final Map<String, double> distribution = provider.weekdayDistribution;
    if (distribution.isEmpty || distribution.values.every((value) => value == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data available yet',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: distribution.values.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final key = distribution.keys.elementAt(groupIndex);
              return BarTooltipItem(
                '${key}\n${(rod.toY * 100).toStringAsFixed(1)}%',
                TextStyle(color: theme.colorScheme.onSurface),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (value < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: List.generate(distribution.length, (index) {
          // Create a gradient that goes from light to darker blue
          final baseColor = theme.colorScheme.primary;
          final color = Color.lerp(
            baseColor.withOpacity(0.5),
            baseColor,
            distribution.values.elementAt(index) / 
                distribution.values.reduce((a, b) => a > b ? a : b),
          )!;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: distribution.values.elementAt(index),
                color: color,
                width: 20,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildSessionsList(List<ReadingSession> sessions, ThemeData theme) {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.auto_stories,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No reading sessions recorded yet',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Sort by most recent first
    final sortedSessions = [...sessions];
    sortedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    // Take only the 5 most recent
    final recentSessions = sortedSessions.take(5).toList();
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentSessions.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final session = recentSessions[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.auto_stories,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          title: Text(
            DateFormat('MMM d, yyyy - h:mm a').format(session.startTime),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${session.durationMinutes} minutes · ${session.pagesRead} pages',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${session.pagesPerHour.toStringAsFixed(1)} p/h',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProgressTab(ReadingAnalyticsProvider provider, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () => provider.loadAnalytics(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Reading Speed Chart
          Container(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.speed, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Reading Speed Trend',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your reading speed over time',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pages per hour',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildReadingSpeedChart(provider, theme),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Daily Pages Read
          Container(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Pages Read',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily reading volume',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pages read per day',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildDailyPagesChart(provider, theme),
                ),
              ],
            ),
          ),
          
          // Reading Performance Summary
          if (provider.dailyStats.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.analytics, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Reading Performance',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildPerformanceSummaryCard(provider, theme),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPerformanceSummaryCard(ReadingAnalyticsProvider provider, ThemeData theme) {
    // Calculate average reading speed
    final allStats = provider.dailyStats;
    
    if (allStats.isEmpty) return SizedBox();
    
    double totalWeightedPagesPerHour = 0;
    int totalMinutes = 0;
    
    for (final stat in allStats) {
      if (stat.totalMinutesRead > 0) {
        totalMinutes += stat.totalMinutesRead;
        totalWeightedPagesPerHour += stat.averagePagesPerHour * stat.totalMinutesRead;
      }
    }
    
    final avgReadingSpeed = totalMinutes > 0 ? totalWeightedPagesPerHour / totalMinutes : 0;
    
    // Find max pages read in a day
    final maxPages = allStats.fold<int>(0, 
      (max, stat) => stat.totalPagesRead > max ? stat.totalPagesRead : max);
    
    // Find max time read in a day (in minutes)
    final maxMinutes = allStats.fold<int>(0, 
      (max, stat) => stat.totalMinutesRead > max ? stat.totalMinutesRead : max);
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Performance Summary',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          
          // Average reading speed
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.speed,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Reading Speed',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${avgReadingSpeed.toStringAsFixed(1)} pages per hour',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Personal records
          Text(
            'Personal Records',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          
          // Most pages in a day
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: 20,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most Pages in a Day',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '$maxPages pages',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer,
                  size: 20,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Longest Reading Time',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${(maxMinutes / 60).toStringAsFixed(1)} hours',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildReadingSpeedChart(ReadingAnalyticsProvider provider, ThemeData theme) {
    final data = provider.readingSpeedData;
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data available yet',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    
    final spots = List.generate(data.length, (index) {
      final item = data[index];
      return FlSpot(
        index.toDouble(),
        double.parse(item['pagesPerHour'] as String),
      );
    });
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < data.length && index % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index]['date'] as String,
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.3),
                  theme.colorScheme.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailyPagesChart(ReadingAnalyticsProvider provider, ThemeData theme) {
    final stats = provider.dailyStats;
    if (stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data available yet',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    
    // Only show the last 14 days
    final recentStats = stats.length <= 14 
        ? stats 
        : stats.sublist(stats.length - 14);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: recentStats.map((stat) => stat.totalPagesRead.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final stat = recentStats[groupIndex];
              return BarTooltipItem(
                '${DateFormat('MMM d').format(stat.date)}\n${stat.totalPagesRead} pages',
                TextStyle(color: theme.colorScheme.onSurface),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < recentStats.length && index % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(recentStats[index].date),
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: List.generate(recentStats.length, (index) {
          final stat = recentStats[index];
          final isToday = stat.date.year == DateTime.now().year &&
                          stat.date.month == DateTime.now().month &&
                          stat.date.day == DateTime.now().day;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: stat.totalPagesRead.toDouble(),
                gradient: LinearGradient(
                  colors: isToday 
                      ? [theme.colorScheme.primary, theme.colorScheme.secondary] 
                      : [theme.colorScheme.secondary.withOpacity(0.7), theme.colorScheme.secondary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 12,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }
} 