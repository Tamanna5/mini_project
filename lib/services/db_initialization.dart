import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

// Use conditional imports to handle platform-specific implementations
import 'dart:io' if (dart.library.html) 'package:flutter/foundation.dart';

// For non-web platforms
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.html) 'db_initialization_web.dart';

/// Initialize database configuration based on platform
Future<void> initializeDatabaseConfig() async {
  if (kIsWeb) {
    // On web, we don't need to initialize sqflite since we'll use Firestore instead
    debugPrint('Running on web platform, using Firestore for storage');
    return;
  } 
  
  // On non-web platforms
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Set global factory
    databaseFactory = databaseFactoryFfi;
  }
  
  debugPrint('SQLite initialized for platform: $defaultTargetPlatform');
}
