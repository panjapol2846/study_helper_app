import 'package:flutter/material.dart';
import 'package:mobile_final/core/services/auth_service.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  Future<void> _handleSignup() async {
    try {
      final user = await _authService.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {


        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profile': {
            'email': user.email,
            'joinedAt': FieldValue.serverTimestamp(),
          },
          'preferences': {
            'theme': 'light',
            'fontSize': 'medium',
            'language': 'en',
          },
          'onboardingComplete': false,
        });

        Navigator.pushReplacementNamed(context, '/onboarding');

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _handleSignup, child: const Text("Sign Up")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
