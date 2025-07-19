import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeckEditorScreen extends StatefulWidget {
  final String? deckId;
  const DeckEditorScreen({super.key, this.deckId});

  @override
  State<DeckEditorScreen> createState() => _DeckEditorScreenState();
}

class _DeckEditorScreenState extends State<DeckEditorScreen> {
  final _nameController = TextEditingController();
  bool _isPublic = false;
  bool _isNewDeck = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.deckId != null) {
      _isNewDeck = false;
      _loadDeck();
    }
  }

  Future<void> _loadDeck() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('flashcardDecks')
        .doc(widget.deckId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _isPublic = data['isPublic'] is bool ? data['isPublic'] as bool : false;
      setState(() {}); // Refresh UI after data is loaded
    }
  }

  Future<void> _saveDeck() async {
    setState(() => _isSaving = true);

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final now = Timestamp.now();
    final data = {
      'name': _nameController.text.trim(),
      'isPublic': _isPublic,
      'updatedAt': now,
    };

    if (_isNewDeck) {
      data['createdAt'] = now;
      data['cards'] = [];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('flashcardDecks')
          .add(data);
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('flashcardDecks')
          .doc(widget.deckId)
          .update(data);
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewDeck ? 'New Deck' : 'Edit Deck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDeck,
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Public"),
                const SizedBox(width: 8),
                Switch(
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() => _isPublic = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Deck Name',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
