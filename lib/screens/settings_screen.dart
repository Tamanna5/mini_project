import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/providers/user_auth_provider.dart';
import 'package:book_tracker/providers/theme_provider.dart';
import 'package:book_tracker/providers/book_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/screens/add_book_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:book_tracker/screens/privacy_policy_screen.dart';

enum ExportType { all, completed, currentlyReading, wantToRead }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isDailyReminderEnabled = true;
  bool _isWeeklyReportEnabled = true;
  bool _isPrivateProfile = false;
  int _selectedAvatarIndex = 0;
  
  // Predefined avatars
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
    _loadUserPreferences();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_display_name') ?? 'Book Lover';
      _bioController.text = prefs.getString('user_bio') ?? 'Avid reader and book enthusiast';
      _selectedAvatarIndex = prefs.getInt('user_avatar_index') ?? 0;
      _isDailyReminderEnabled = prefs.getBool('pref_daily_reminder') ?? true;
      _isWeeklyReportEnabled = prefs.getBool('pref_weekly_report') ?? true;
      _isPrivateProfile = prefs.getBool('pref_private_profile') ?? false;
    });
  }
  
  Future<void> _saveUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_display_name', _nameController.text);
    await prefs.setString('user_bio', _bioController.text);
    await prefs.setInt('user_avatar_index', _selectedAvatarIndex);
    await prefs.setBool('pref_daily_reminder', _isDailyReminderEnabled);
    await prefs.setBool('pref_weekly_report', _isWeeklyReportEnabled);
    await prefs.setBool('pref_private_profile', _isPrivateProfile);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  Widget _buildAvatarSelector() {
    final theme = Theme.of(context);
    final double avatarSize = 80.0;
    
    return Column(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 3,
            ),
          ),
          child: Icon(
            _avatarIcons[_selectedAvatarIndex],
            size: 50,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Choose your avatar:'),
        const SizedBox(height: 8),
        Container(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _avatarIcons.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedAvatarIndex;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatarIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor:
                        isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.1),
                    radius: 24,
                    child: Icon(
                      _avatarIcons[index],
                      color: isSelected ? Colors.white : theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<UserAuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _saveUserPreferences();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Section
            Text(
              'Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildAvatarSelector(),
            const SizedBox(height: 24),
            
            // Display Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a display name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Tell others about yourself and your reading preferences',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Private Profile
            SwitchListTile(
              title: const Text('Private Profile'),
              subtitle: const Text('Only you can see your reading activity'),
              value: _isPrivateProfile,
              onChanged: (value) {
                setState(() {
                  _isPrivateProfile = value;
                });
              },
              secondary: Icon(
                _isPrivateProfile ? Icons.lock : Icons.lock_open,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const Divider(height: 32),
            
            // Appearance Section
            Text(
              'Appearance',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dark Mode
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme for better reading at night'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setDarkMode(value);
              },
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const Divider(height: 32),
            
            // Notifications Section
            Text(
              'Notifications',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Daily Reading Reminder
            SwitchListTile(
              title: const Text('Daily Reading Reminder'),
              subtitle: const Text('Get reminded to read every day'),
              value: _isDailyReminderEnabled,
              onChanged: (value) {
                setState(() {
                  _isDailyReminderEnabled = value;
                });
              },
              secondary: Icon(
                Icons.notifications_active,
                color: theme.colorScheme.primary,
              ),
            ),
            
            // Weekly Progress Report
            SwitchListTile(
              title: const Text('Weekly Progress Report'),
              subtitle: const Text('Receive a weekly summary of your reading progress'),
              value: _isWeeklyReportEnabled,
              onChanged: (value) {
                setState(() {
                  _isWeeklyReportEnabled = value;
                });
              },
              secondary: Icon(
                Icons.summarize,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const Divider(height: 32),
            
            // Library Management Section
            Text(
              'Library Management',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Import PDF
            ListTile(
              leading: Icon(
                Icons.upload_file,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Import PDF Books'),
              subtitle: const Text('Add PDFs to your library'),
              onTap: () => _pickAndImportPdf(context),
            ),
            
            // Export Reading Data
            ListTile(
              leading: Icon(
                Icons.data_object,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Export Reading Data'),
              subtitle: const Text('Download all your reading data as CSV'),
              onTap: () {
                // Export reading data functionality
                _showExportOptionsDialog(context, bookProvider);
              },
            ),
            
            const Divider(height: 32),
            
            // Account Section
            Text(
              'Account',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: Icon(
                Icons.email,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Email'),
              subtitle: Text(authProvider.user?.email ?? 'Not signed in'),
            ),
            
            ListTile(
              leading: Icon(
                Icons.password,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Change Password'),
              onTap: () {
                // Show password change dialog
                if (authProvider.user?.email != null) {
                  _showChangePasswordDialog(context, authProvider);
                }
              },
            ),
            
            const Divider(height: 32),
            
            // Legal Section
            Text(
              'Legal',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: Icon(
                Icons.policy,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read how we handle your data'),
              onTap: () {
                Navigator.pushNamed(context, '/privacy_policy');
              },
            ),
            
            const SizedBox(height: 16),
            
            ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () async {
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
    );
  }
  
  void _showChangePasswordDialog(BuildContext context, UserAuthProvider authProvider) {
    final _emailController = TextEditingController(text: authProvider.user?.email);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We will send a password reset link to your email'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await authProvider.resetPassword(_emailController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent. Check your inbox.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }
  
  void _showExportOptionsDialog(BuildContext context, BookProvider bookProvider) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Reading Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.book, color: theme.colorScheme.primary),
              title: const Text('All Books'),
              subtitle: Text('${bookProvider.allBooks.length} books'),
              onTap: () {
                Navigator.pop(context);
                _exportReadingData(context, bookProvider, exportType: ExportType.all);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Completed Books'),
              subtitle: Text('${bookProvider.read.length} books'),
              onTap: () {
                Navigator.pop(context);
                _exportReadingData(context, bookProvider, exportType: ExportType.completed);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.auto_stories, color: Colors.blue),
              title: const Text('Currently Reading'),
              subtitle: Text('${bookProvider.currentlyReading.length} books'),
              onTap: () {
                Navigator.pop(context);
                _exportReadingData(context, bookProvider, exportType: ExportType.currentlyReading);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.bookmark, color: Colors.orange),
              title: const Text('Want to Read'),
              subtitle: Text('${bookProvider.wantToRead.length} books'),
              onTap: () {
                Navigator.pop(context);
                _exportReadingData(context, bookProvider, exportType: ExportType.wantToRead);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportReadingData(
    BuildContext context, 
    BookProvider bookProvider, 
    {ExportType exportType = ExportType.all}
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Handle web platform differently
      if (kIsWeb) {
        await _exportReadingDataWeb(context, bookProvider, exportType: exportType);
        return;
      }
      
      // Check and request storage permission on Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to export data'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyyMMdd_HHmmss');
      
      // Determine export type for filename
      String exportTypeStr;
      List<dynamic> booksToExport;
      
      switch (exportType) {
        case ExportType.completed:
          exportTypeStr = 'completed';
          booksToExport = bookProvider.read;
          break;
        case ExportType.currentlyReading:
          exportTypeStr = 'current';
          booksToExport = bookProvider.currentlyReading;
          break;
        case ExportType.wantToRead:
          exportTypeStr = 'wanted';
          booksToExport = bookProvider.wantToRead;
          break;
        case ExportType.all:
        default:
          exportTypeStr = 'all';
          booksToExport = bookProvider.allBooks;
          break;
      }
      
      final fileName = 'book_tracker_${exportTypeStr}_${dateFormat.format(now)}.csv';
      final filePath = '${directory.path}/$fileName';
      
      // Create CSV content
      final csvContent = _generateCsvContent(booksToExport);
      
      // Write to file
      final file = File(filePath);
      await file.writeAsString(csvContent);
      
      // Show success dialog with more details and options
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exported ${booksToExport.length} books to CSV file.'),
                const SizedBox(height: 8),
                const Text('File location:'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    filePath,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Share the file
                  Share.shareXFiles(
                    [XFile(filePath)],
                    subject: 'Book Tracker - Exported Reading Data',
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share, size: 16),
                    const SizedBox(width: 4),
                    const Text('Share'),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to export data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Export for Web platform using browser download
  Future<void> _exportReadingDataWeb(
    BuildContext context, 
    BookProvider bookProvider,
    {ExportType exportType = ExportType.all}
  ) async {
    try {
      // Determine export type for filename
      String exportTypeStr;
      List<dynamic> booksToExport;
      
      switch (exportType) {
        case ExportType.completed:
          exportTypeStr = 'completed';
          booksToExport = bookProvider.read;
          break;
        case ExportType.currentlyReading:
          exportTypeStr = 'current';
          booksToExport = bookProvider.currentlyReading;
          break;
        case ExportType.wantToRead:
          exportTypeStr = 'wanted';
          booksToExport = bookProvider.wantToRead;
          break;
        case ExportType.all:
        default:
          exportTypeStr = 'all';
          booksToExport = bookProvider.allBooks;
          break;
      }
      
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyyMMdd_HHmmss');
      final fileName = 'book_tracker_${exportTypeStr}_${dateFormat.format(now)}.csv';
      
      // Generate CSV content
      final csvContent = _generateCsvContent(booksToExport);
      
      // For web platform, use a simpler approach - show a success message
      // with instructions to copy-paste the data
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Ready'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exported ${booksToExport.length} books to CSV.'),
                const SizedBox(height: 16),
                const Text('Web export: Select all text below, copy it, and paste into a .csv file:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  height: 150,
                  child: SingleChildScrollView(
                    child: SelectableText(
                      csvContent,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Helper method to generate CSV content
  String _generateCsvContent(List<dynamic> books) {
    final buffer = StringBuffer();
    
    // Header row
    buffer.writeln('Title,Author,ISBN,Status,Total Pages,Current Page,Date Added,Started Reading,Finished Reading,Genres');
    
    // Data rows
    for (final book in books) {
      final status = book.status.toString().split('.').last;
      final dateAdded = DateFormat('yyyy-MM-dd').format(book.addedDate);
      final startedReading = book.startedReading != null 
          ? DateFormat('yyyy-MM-dd').format(book.startedReading!) 
          : '';
      final finishedReading = book.finishedReading != null 
          ? DateFormat('yyyy-MM-dd').format(book.finishedReading!) 
          : '';
      final genres = book.genres.join('; ');
      
      // Escape commas and quotes in text fields
      final escapedTitle = _escapeCsvField(book.title);
      final escapedAuthor = _escapeCsvField(book.author);
      final escapedIsbn = _escapeCsvField(book.isbn);
      final escapedGenres = _escapeCsvField(genres);
      
      buffer.writeln(
        '$escapedTitle,$escapedAuthor,$escapedIsbn,$status,${book.pageCount},${book.currentPage},$dateAdded,$startedReading,$finishedReading,$escapedGenres'
      );
    }
    
    return buffer.toString();
  }
  
  String _escapeCsvField(String field) {
    // If the field contains commas, quotes, or newlines, wrap it in quotes
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Replace quotes with double quotes
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  Future<void> _pickAndImportPdf(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // For web platform, show a message that PDF import isn't fully supported
      if (kIsWeb) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('PDF import is limited on web platform. Use desktop or mobile app for full functionality.'),
            duration: Duration(seconds: 5),
          ),
        );
        
        // Still allow picking, but with limited functionality
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
          withData: true,
        );
        
        if (result == null || result.files.isEmpty) {
          return;
        }
        
        final file = result.files.first;
        if (file.name.isEmpty) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Could not access file information'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        // On web, we can navigate to AddBookScreen with placeholder path
        if (context.mounted) {
          final book = Book(
            title: _extractTitleFromFilename(file.name),
            author: '',
            status: ReadingStatus.wantToRead,
            pdfUrl: 'web_pdf_${DateTime.now().millisecondsSinceEpoch}',
          );
          
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookScreen(book: book),
            ),
          );
        }
        return;
      }
      
      // Request storage permission on Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to import PDFs'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      // Pick PDF file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        // User canceled the picker
        return;
      }
      
      final file = result.files.first;
      final path = file.path;
      
      if (path == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Could not access the selected file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Copy the file to app documents directory for persistence
      final savedPath = await _copyPdfToAppDirectory(path, file.name);
      
      // Navigate to the AddBookScreen with the PDF path
      if (context.mounted) {
        // Create a temporary book with the PDF path
        final book = Book(
          title: _extractTitleFromFilename(file.name),
          author: '',
          status: ReadingStatus.wantToRead,
          pdfUrl: savedPath,
        );
        
        // Navigate to the add book screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddBookScreen(book: book),
          ),
        );
      }
      
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to import PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<String> _copyPdfToAppDirectory(String sourcePath, String fileName) async {
    // Get the app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory('${directory.path}/pdfs');
    
    // Create the pdfs directory if it doesn't exist
    if (!await pdfDirectory.exists()) {
      await pdfDirectory.create(recursive: true);
    }
    
    // Generate a unique filename to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = '${timestamp}_$fileName';
    final destinationPath = '${pdfDirectory.path}/$uniqueFileName';
    
    // Copy the file to the app directory
    final File sourceFile = File(sourcePath);
    final File destinationFile = await sourceFile.copy(destinationPath);
    
    return destinationFile.path;
  }
  
  String _extractTitleFromFilename(String fileName) {
    // Remove file extension
    final nameWithoutExtension = fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
    
    // Replace underscores and hyphens with spaces
    final nameWithSpaces = nameWithoutExtension.replaceAll(RegExp(r'[_-]'), ' ');
    
    // Capitalize each word
    final words = nameWithSpaces.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : '');
    });
    
    return capitalizedWords.join(' ');
  }
} 