import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Imported for shuffling

class StudyModeScreen extends StatefulWidget {
  final String deckId;

  const StudyModeScreen({super.key, required this.deckId});

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen> {
  List<Map<String, dynamic>> _cards = [];
  int _currentIndex = 0;
  bool _showBack = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('flashcardDecks')
        .doc(widget.deckId)
        .collection('cards')
        .orderBy('createdAt')
        .get();

    final loadedCards = snapshot.docs.map((doc) => doc.data()).toList();
    // Shuffle the cards once they are loaded
    loadedCards.shuffle(Random());

    setState(() {
      _cards = loadedCards;
      _loading = false;
    });
  }

  /// Shuffles the cards and resets the view to the first card.
  void _shuffleCards() {
    setState(() {
      _cards.shuffle(Random());
      _currentIndex = 0;
      _showBack = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cards have been shuffled!")),
    );
  }

  /// Navigates to the next card in the deck.
  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showBack = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You've reached the end of the deck.")),
      );
    }
  }

  /// Navigates to the previous card in the deck.
  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showBack = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are at the beginning of the deck.")),
      );
    }
  }

  /// Pops the current screen to return to the deck list.
  void _finishStudy() {
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Study Mode")),
        body: const Center(child: Text("This deck has no cards to study.")),
      );
    }

    final currentCard = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Mode"),
        actions: [
          IconButton(
            onPressed: _shuffleCards,
            icon: const Icon(Icons.shuffle),
            tooltip: "Shuffle Cards",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Card ${_currentIndex + 1} of ${_cards.length}",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _showBack = !_showBack),
              child: Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.cardColor,
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _showBack ? currentCard['back'] : currentCard['front'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _previousCard,
                  icon: const Icon(Icons.navigate_before),
                  label: const Text("Back"),
                ),
                ElevatedButton.icon(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.navigate_next),
                  label: const Text("Next"),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finishStudy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Finish Study"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}