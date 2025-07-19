import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_final/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  String _theme = 'light';
  String _fontSize = 'medium';
  String _language = 'en';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final prefs = doc.data()?['preferences'] ?? {};
        _theme = prefs['theme'] ?? 'light';
        _fontSize = prefs['fontSize'] ?? 'medium';
        _language = prefs['language'] ?? 'en';
        _displayNameController.text = doc.data()?['displayName'] ?? '';
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'displayName': _displayNameController.text.trim(),
        'preferences': {
          'theme': _theme,
          'fontSize': _fontSize,
          'language': _language,
        }
      });

      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.loadFromFirestore();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final textStyle = TextStyle(fontSize: 18, color: textColor);
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _displayNameController,
              style: textStyle,
              decoration: inputDecoration.copyWith(labelText: 'Display Name'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _theme,
              style: textStyle,
              dropdownColor: theme.cardColor,
              decoration: inputDecoration.copyWith(labelText: 'Theme'),
              items: [
                DropdownMenuItem(
                  value: 'light',
                  child: Text('Light', style: TextStyle(color: textColor)),
                ),
                DropdownMenuItem(
                  value: 'dark',
                  child: Text('Dark', style: TextStyle(color: textColor)),
                ),
              ],
              onChanged: (value) => setState(() => _theme = value ?? 'light'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _fontSize,
              style: textStyle,
              dropdownColor: theme.cardColor,
              decoration: inputDecoration.copyWith(labelText: 'Font Size'),
              items: [
                DropdownMenuItem(
                  value: 'small',
                  child: Text('Small', style: TextStyle(color: textColor)),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium', style: TextStyle(color: textColor)),
                ),
                DropdownMenuItem(
                  value: 'large',
                  child: Text('Large', style: TextStyle(color: textColor)),
                ),
              ],
              onChanged: (value) => setState(() => _fontSize = value ?? 'medium'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD964),
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Preferences'),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Log Out"),
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
