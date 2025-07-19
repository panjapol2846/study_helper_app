import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardEditorScreen extends StatefulWidget {
  final String deckId;
  final String? cardId;
  final String? initialFront;
  final String? initialBack;

  const CardEditorScreen({
    super.key,
    required this.deckId,
    this.cardId,
    this.initialFront,
    this.initialBack,
  });

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends State<CardEditorScreen> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _frontController.text = widget.initialFront ?? '';
    _backController.text = widget.initialBack ?? '';
  }

  Future<void> _saveCard() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cardsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('flashcardDecks')
        .doc(widget.deckId)
        .collection('cards');

    final front = _frontController.text.trim();
    final back = _backController.text.trim();

    if (front.isEmpty || back.isEmpty) return;

    setState(() => _saving = true);

    if (widget.cardId == null) {
      await cardsRef.add({
        'front': front,
        'back': back,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await cardsRef.doc(widget.cardId).update({
        'front': front,
        'back': back,
      });
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cardId == null ? "Add Card" : "Edit Card")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _frontController,
              decoration: const InputDecoration(labelText: 'Front Text'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _backController,
              decoration: const InputDecoration(labelText: 'Back Text'),
            ),
            const SizedBox(height: 24),
            _saving
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveCard,
              child: const Text("Save Card"),
            ),
          ],
        ),
      ),
    );
  }
}
