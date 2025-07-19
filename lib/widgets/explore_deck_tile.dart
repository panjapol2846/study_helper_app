import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreDeckTile extends StatelessWidget {
  const ExploreDeckTile({super.key});

  @override
  Widget build(BuildContext context) {
    final decksRef = FirebaseFirestore.instance.collectionGroup('decks');

    return StreamBuilder<QuerySnapshot>(
      stream: decksRef.where('isPublic', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No public decks found.'));
        }

        final decks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: decks.length,
          itemBuilder: (context, index) {
            final deck = decks[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(deck['name'] ?? 'Untitled Deck'),
              subtitle: Text('${deck['cards']?.length ?? 0} cards'),
              onTap: () {
                // You could navigate to a view-only study screen here
              },
            );
          },
        );
      },
    );
  }
}
