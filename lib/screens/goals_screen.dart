import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:book_tracker/models/reading_goal.dart';
import 'package:book_tracker/providers/reading_goal_provider.dart';
import 'package:intl/intl.dart';
import 'package:book_tracker/screens/add_goal_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<ReadingGoalProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Goals'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await goalProvider.loadGoals();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active goals section
              Text(
                'Active Goals',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              if (goalProvider.activeGoals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active goals yet',
                          style: textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set a reading goal to track your progress',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goalProvider.activeGoals.length,
                  itemBuilder: (context, index) {
                    final goal = goalProvider.activeGoals[index];
                    return GoalCard(goal: goal);
                  },
                ),
              
              const SizedBox(height: 32),
              
              // Completed goals section
              Text(
                'Completed Goals',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              if (goalProvider.completedGoals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No completed goals yet',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goalProvider.completedGoals.length,
                  itemBuilder: (context, index) {
                    final goal = goalProvider.completedGoals[index];
                    return GoalCard(goal: goal);
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Goal',
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final ReadingGoal goal;

  const GoalCard({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Format goal period
    String goalPeriod;
    switch (goal.period) {
      case GoalPeriod.daily:
        goalPeriod = 'Daily';
        break;
      case GoalPeriod.weekly:
        goalPeriod = 'Weekly';
        break;
      case GoalPeriod.monthly:
        goalPeriod = 'Monthly';
        break;
      case GoalPeriod.yearly:
        goalPeriod = 'Yearly';
        break;
      case GoalPeriod.custom:
        goalPeriod = 'Custom';
        break;
    }

    // Format goal type
    String goalType;
    switch (goal.type) {
      case GoalType.booksCount:
        goalType = goal.target == 1 ? 'book' : 'books';
        break;
      case GoalType.pagesCount:
        goalType = goal.target == 1 ? 'page' : 'pages';
        break;
      case GoalType.minutesRead:
        goalType = goal.target == 1 ? 'minute' : 'minutes';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal title and completion status
            Row(
              children: [
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Goal type and period
            Text(
              '$goalPeriod goal: ${goal.target} $goalType',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            
            // Goal period dates
            Text(
              '${DateFormat.yMMMd().format(goal.startDate)} - ${DateFormat.yMMMd().format(goal.endDate)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            LinearPercentIndicator(
              percent: goal.progressPercentage,
              lineHeight: 10,
              backgroundColor: colorScheme.primaryContainer,
              progressColor: goal.isCompleted ? Colors.green : colorScheme.primary,
              barRadius: const Radius.circular(5),
              animation: true,
              animationDuration: 1000,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            
            // Progress text
            Text(
              '${goal.progress} / ${goal.target} (${(goal.progressPercentage * 100).toInt()}%)',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
} 