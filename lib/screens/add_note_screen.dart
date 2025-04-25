import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/providers/book_provider.dart';

class AddNoteScreen extends StatefulWidget {
  final String bookId;

  const AddNoteScreen({super.key, required this.bookId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _contentController = TextEditingController();
  final _pageNumberController = TextEditingController();
  
  bool _isHighlight = false;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _contentController.dispose();
    _pageNumberController.dispose();
    super.dispose();
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        
        // Parse page number
        final pageNumber = int.tryParse(_pageNumberController.text) ?? 0;
        
        // Create note object
        final note = Note(
          content: _contentController.text.trim(),
          pageNumber: pageNumber,
          isHighlight: _isHighlight,
        );
        
        // Add note to book
        await bookProvider.addNoteToBook(widget.bookId, note);
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding note: $e'),
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
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isHighlight ? 'Add Highlight' : 'Add Note'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type selector (Note or Highlight)
                    SwitchListTile(
                      title: const Text('This is a highlight'),
                      subtitle: const Text('Select this if you\'re quoting text from the book'),
                      value: _isHighlight,
                      onChanged: (value) {
                        setState(() {
                          _isHighlight = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Content field
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: _isHighlight ? 'Highlighted Text' : 'Note',
                        hintText: _isHighlight ? 'Enter the text you highlighted' : 'Enter your note',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _isHighlight ? 'Please enter highlighted text' : 'Please enter a note';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Page number field
                    TextFormField(
                      controller: _pageNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Page Number',
                        hintText: 'Enter page number (optional)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(_isHighlight ? 'Add Highlight' : 'Add Note'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 