import 'package:flutter/foundation.dart';
import 'package:book_tracker/models/reading_goal.dart';
import 'package:book_tracker/services/database_service.dart';

class ReadingGoalProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<ReadingGoal> _goals = [];
  
  List<ReadingGoal> get goals => _goals;
  List<ReadingGoal> get activeGoals => _goals.where((goal) => goal.isActive).toList();
  List<ReadingGoal> get completedGoals => _goals.where((goal) => goal.isCompleted).toList();
  
  // Initialize provider
  Future<void> init() async {
    await loadGoals();
  }
  
  // Load goals from database
  Future<void> loadGoals() async {
    try {
      _goals = await _databaseService.getAllReadingGoals();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reading goals: $e');
      _goals = [];
      notifyListeners();
    }
  }
  
  // Add a new reading goal
  Future<void> addGoal(ReadingGoal goal) async {
    try {
      await _databaseService.insertReadingGoal(goal);
      _goals.add(goal);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding reading goal: $e');
      rethrow;
    }
  }
  
  // Update progress of a goal
  Future<void> updateGoalProgress(String goalId, int newProgress) async {
    try {
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      
      if (index != -1) {
        ReadingGoal goal = _goals[index];
        bool isCompleted = newProgress >= goal.target;
        
        ReadingGoal updatedGoal = goal.copyWith(
          progress: newProgress,
          isCompleted: isCompleted,
        );
        
        await _databaseService.updateReadingGoal(updatedGoal);
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating goal progress: $e');
      rethrow;
    }
  }
  
  // Mark a goal as completed
  Future<void> completeGoal(String goalId) async {
    try {
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      
      if (index != -1) {
        ReadingGoal goal = _goals[index];
        ReadingGoal updatedGoal = goal.copyWith(isCompleted: true);
        
        await _databaseService.updateReadingGoal(updatedGoal);
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error completing goal: $e');
      rethrow;
    }
  }
  
  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await _databaseService.deleteReadingGoal(goalId);
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
      rethrow;
    }
  }
  
  // Get goal by ID
  ReadingGoal? getGoalById(String goalId) {
    try {
      return _goals.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      return null;
    }
  }
  
  // Update a goal
  Future<void> updateGoal(ReadingGoal updatedGoal) async {
    try {
      await _databaseService.updateReadingGoal(updatedGoal);
      
      final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating goal: $e');
      rethrow;
    }
  }
} 