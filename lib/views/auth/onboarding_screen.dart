
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
    final primaryColor = const Color(0xFF4CD964); // mint green

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'STUDY', style: TextStyle(color: Colors.black)),
                      TextSpan(text: 'SYNC', style: TextStyle(color: Color(0xFF4CD964))),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Display Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _theme,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.color_lens_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    labelText: 'Theme',
                  ),
                  items: ['light', 'dark'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value[0].toUpperCase() + value.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _theme = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _fontSize,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.format_size),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    labelText: 'Font Size',
                  ),
                  items: ['small', 'medium', 'large'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value[0].toUpperCase() + value.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _language,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.language),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    labelText: 'Language',
                  ),
                  items: ['en', 'es', 'fr'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _language = value!;
                    });
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _savePreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
