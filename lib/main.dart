import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_final/app.dart';
import 'package:provider/provider.dart';
import 'package:mobile_final/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final themeProvider = ThemeProvider();

  // ✅ Load preferences only if user is logged in
  if (FirebaseAuth.instance.currentUser != null) {
    await themeProvider.loadFromFirestore();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const StudySyncApp(),
    ),
  );
}
