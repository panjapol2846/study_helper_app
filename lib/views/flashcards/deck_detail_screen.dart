import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_editor_screen.dart';

class DeckDetailScreen extends StatelessWidget {
  final String deckId;

  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cardsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('flashcardDecks')
        .doc(deckId)
        .collection('cards')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Deck Details"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cardsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data!.docs;

          if (cards.isEmpty) {
            return const Center(child: Text("No cards yet. Tap + to add one."));
          }

          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final front = card['front'] ?? '';
              final back = card['back'] ?? '';
              final cardId = card.id;

              return ListTile(
                title: Text(front),
                subtitle: Text(back, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardEditorScreen(
                        deckId: deckId,
                        cardId: cardId,
                        initialFront: front,
                        initialBack: back,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CardEditorScreen(deckId: deckId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
