import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/models/reading_goal.dart';
import 'package:book_tracker/providers/reading_goal_provider.dart';
import 'package:intl/intl.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  GoalType _selectedType = GoalType.booksCount;
  GoalPeriod _selectedPeriod = GoalPeriod.yearly;
  int _target = 1;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = isStart ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 365 * 5));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ReadingGoalProvider>(context, listen: false);
      final goal = ReadingGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        type: _selectedType,
        period: _selectedPeriod,
        target: _target,
        progress: 0,
        startDate: _startDate,
        endDate: _endDate,
        isCompleted: false,
      );
      await provider.addGoal(goal);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding goal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Goal')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Goal Title'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter a goal title' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<GoalType>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'Goal Type'),
                      items: const [
                        DropdownMenuItem(value: GoalType.booksCount, child: Text('Books Count')),
                        DropdownMenuItem(value: GoalType.pagesCount, child: Text('Pages Read')),
                        DropdownMenuItem(value: GoalType.minutesRead, child: Text('Minutes Read')),
                      ],
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<GoalPeriod>(
                      value: _selectedPeriod,
                      decoration: const InputDecoration(labelText: 'Goal Period'),
                      items: const [
                        DropdownMenuItem(value: GoalPeriod.daily, child: Text('Daily')),
                        DropdownMenuItem(value: GoalPeriod.weekly, child: Text('Weekly')),
                        DropdownMenuItem(value: GoalPeriod.monthly, child: Text('Monthly')),
                        DropdownMenuItem(value: GoalPeriod.yearly, child: Text('Yearly')),
                        DropdownMenuItem(value: GoalPeriod.custom, child: Text('Custom')),
                      ],
                      onChanged: (v) => setState(() => _selectedPeriod = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _target.toString(),
                      decoration: const InputDecoration(labelText: 'Target'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final val = int.tryParse(v ?? '');
                        if (val == null || val < 1) return 'Enter a valid target';
                        return null;
                      },
                      onChanged: (v) => setState(() => _target = int.tryParse(v) ?? 1),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Start Date'),
                            subtitle: Text(DateFormat.yMMMd().format(_startDate)),
                            onTap: () => _pickDate(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('End Date'),
                            subtitle: Text(DateFormat.yMMMd().format(_endDate)),
                            onTap: () => _pickDate(isStart: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Add Goal'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
