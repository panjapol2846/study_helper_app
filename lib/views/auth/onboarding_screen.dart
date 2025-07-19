import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  String _theme = 'light';
  String _fontSize = 'medium';
  String _language = 'en';

  Future<void> _savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': _displayNameController.text.trim(),
        'preferences': {
          'theme': _theme,
          'fontSize': _fontSize,
          'language': _language,
        }
      });
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Onboarding")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Set Your Preferences:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePreferences,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
