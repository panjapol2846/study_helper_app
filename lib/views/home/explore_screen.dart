import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Notes'),
              Tab(text: 'Decks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PublicNotesTab(),
            PublicDecksTab(),
          ],
        ),
      ),
    );
  }
}

class PublicNotesTab extends StatefulWidget {
  const PublicNotesTab({super.key});

  @override
  State<PublicNotesTab> createState() => _PublicNotesTabState();
}

class _PublicNotesTabState extends State<PublicNotesTab> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final notesQuery = FirebaseFirestore.instance
        .collectionGroup('notes')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: notesQuery.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs.where((doc) {
                final name = (doc['name'] ?? '').toString().toLowerCase();
                return name.contains(searchQuery);
              }).toList();

              if (docs.isEmpty) return const Center(child: Text('No matching notes.'));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final note = docs[index].data();
                  final title = note['name'] ?? 'Untitled';
                  final description = note['description'] ?? '';
                  final url = note['url'] ?? '';
                  final authorId = docs[index].reference.path.split('/')[1];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(authorId).get(),
                    builder: (context, userSnapshot) {
                      final authorName = userSnapshot.data?.get('displayName') ?? 'Unknown';

                      return ListTile(
                        title: Text(title),
                        subtitle: Text('by $authorName'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(
                                title: title,
                                description: description,
                                url: url,
                                author: authorName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class NoteDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String url;
  final String author;

  const NoteDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.url,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("by $author", style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Text("URL:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: Text(url, style: const TextStyle(color: Colors.blue))),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL copied to clipboard')),
                    );
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            Text("Description:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(description),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await userRef.collection('notes').add({
                  'name': title,
                  'url': url,
                  'description': description,
                  'isPublic': false,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note saved to your account')),
                );
              },
              child: const Text('Save to My Notes'),
            ),
          ],
        ),
      ),
    );
  }
}

class PublicDecksTab extends StatefulWidget {
  const PublicDecksTab({super.key});

  @override
  State<PublicDecksTab> createState() => _PublicDecksTabState();
}

class _PublicDecksTabState extends State<PublicDecksTab> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final decksQuery = FirebaseFirestore.instance
        .collectionGroup('flashcardDecks')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search decks...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: decksQuery.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs.where((doc) {
                final name = (doc['name'] ?? '').toString().toLowerCase();
                return name.contains(searchQuery);
              }).toList();

              if (docs.isEmpty) return const Center(child: Text('No matching decks.'));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final deckDoc = docs[index];
                  final deck = deckDoc.data();
                  final title = deck['name'] ?? 'Untitled';
                  final description = deck['description'] ?? '';
                  final authorId = deckDoc.reference.path.split('/')[1];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(authorId).get(),
                    builder: (context, userSnapshot) {
                      final authorName = userSnapshot.data?.get('displayName') ?? 'Unknown';

                      return ListTile(
                        title: Text(title),
                        subtitle: Text('by $authorName'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeckDetailScreen(
                                title: title,
                                description: description,
                                author: authorName,
                                sourceDeckRef: deckDoc.reference,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class DeckDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String author;
  final DocumentReference sourceDeckRef;

  const DeckDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.sourceDeckRef,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Author: $author", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Description:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(description),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final cardsSnapshot = await sourceDeckRef.collection('cards').get();
                final newDeckRef = await userRef.collection('flashcardDecks').add({
                  'name': title,
                  'description': description,
                  'isPublic': false,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                for (var doc in cardsSnapshot.docs) {
                  await newDeckRef.collection('cards').add(doc.data());
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deck and cards saved to your account')),
                );
              },
              child: const Text('Save to My Decks'),
            ),
          ],
        ),
      ),
    );
  }
}
