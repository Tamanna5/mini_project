import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/providers/book_provider.dart';

class UpdateProgressScreen extends StatefulWidget {
  final Book book;

  const UpdateProgressScreen({
    super.key,
    required this.book,
  });

  @override
  State<UpdateProgressScreen> createState() => _UpdateProgressScreenState();
}

class _UpdateProgressScreenState extends State<UpdateProgressScreen> {
  late TextEditingController _currentPageController;
  late double _progress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPageController = TextEditingController(text: widget.book.currentPage.toString());
    _updateProgress();
  }

  @override
  void dispose() {
    _currentPageController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final currentPage = int.tryParse(_currentPageController.text) ?? 0;
    setState(() {
      if (widget.book.pageCount > 0) {
        _progress = currentPage / widget.book.pageCount;
      } else {
        _progress = 0;
      }
      // Ensure progress is within valid range
      if (_progress < 0) _progress = 0;
      if (_progress > 1) _progress = 1;
    });
  }

  void _saveProgress() async {
    // Validate
    final currentPage = int.tryParse(_currentPageController.text) ?? 0;
    if (currentPage < 0 || (widget.book.pageCount > 0 && currentPage > widget.book.pageCount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid page number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      await bookProvider.updateReadingProgress(widget.book.id, currentPage);
      
      // If the user finishes the book, ask if they want to mark it as read
      if (currentPage == widget.book.pageCount && currentPage > 0) {
        if (mounted) {
          _showMarkAsReadDialog();
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating progress: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMarkAsReadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finished Reading?'),
        content: const Text(
          'Congratulations! You\'ve reached the end of the book. Would you like to mark it as read?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to book details
            },
            child: const Text('Not Yet'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              final bookProvider = Provider.of<BookProvider>(context, listen: false);
              await bookProvider.changeBookStatus(widget.book.id, ReadingStatus.read);
              
              if (mounted) {
                Navigator.pop(context); // Go back to book details
              }
            },
            child: const Text('Yes, Mark as Read'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Progress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Book title
                  Text(
                    widget.book.title,
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${widget.book.author}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Circular progress indicator
                  CircularPercentIndicator(
                    radius: 80,
                    lineWidth: 10,
                    percent: _progress,
                    center: Text(
                      '${(_progress * 100).toInt()}%',
                      style: textTheme.headlineMedium,
                    ),
                    progressColor: colorScheme.primary,
                    backgroundColor: colorScheme.primaryContainer,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 500,
                  ),
                  const SizedBox(height: 32),
                  
                  // Current page / Total pages
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _currentPageController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            _updateProgress();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'of',
                          style: textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          widget.book.pageCount.toString(),
                          style: textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProgress,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Save Progress'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 