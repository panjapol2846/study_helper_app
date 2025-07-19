import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_final/providers/theme_provider.dart';
import 'package:provider/provider.dart';

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
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _theme,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (value) => setState(() => _theme = value ?? 'light'),
              decoration: const InputDecoration(labelText: 'Theme'),
            ),
            DropdownButtonFormField<String>(
              value: _fontSize,
              items: const [
                DropdownMenuItem(value: 'small', child: Text('Small')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'large', child: Text('Large')),
              ],
              onChanged: (value) => setState(() => _fontSize = value ?? 'medium'),
              decoration: const InputDecoration(labelText: 'Font Size'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePreferences,
              child: const Text('Save Preferences'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
