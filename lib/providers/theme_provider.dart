import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  double _fontSize = 16.0;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;

  void setTheme(String theme) {
    _themeMode = (theme == 'dark') ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setFontSize(String size) {
    switch (size) {
      case 'small':
        _fontSize = 14.0;
        break;
      case 'large':
        _fontSize = 20.0;
        break;
      default:
        _fontSize = 16.0;
    }
    notifyListeners();
  }

  void loadPreferences(String theme, String fontSize) {
    setTheme(theme);
    setFontSize(fontSize);
  }


  Future<void> loadFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final prefs = doc.data()?['preferences'] ?? {};

      setTheme(prefs['theme'] ?? 'light');
      setFontSize(prefs['fontSize'] ?? 'medium');
    } catch (e) {
      print('Failed to load preferences: $e');
    }
  }
}
