import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final String key = 'theme_mode';
  late SharedPreferences _preferences;
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  ThemeProvider() {
    _loadFromPreferences();
  }
  
  _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  _loadFromPreferences() async {
    await _initPreferences();
    _isDarkMode = _preferences.getBool(key) ?? false;
    notifyListeners();
  }
  
  _saveToPreferences() async {
    await _initPreferences();
    _preferences.setBool(key, _isDarkMode);
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPreferences();
    notifyListeners();
  }
  
  void setDarkMode(bool value) {
    _isDarkMode = value;
    _saveToPreferences();
    notifyListeners();
  }
} 