import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_final/views/flashcards/deck_detail_screen.dart';
import 'package:mobile_final/views/flashcards/deck_editor_screen.dart';
import 'package:mobile_final/views/flashcards/study_mode_screen.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  String _searchText = '';
  String _sortBy = 'Latest';

  void _showDeckOptions(BuildContext context, String deckId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Deck Details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeckDetailScreen(deckId: deckId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Deck'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeckEditorScreen(deckId: deckId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Deck'),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('flashcardDecks')
                  .doc(deckId)
                  .delete();
            },
          ),
        ],
      ),
    );
  }

  Query _getDecksQuery() {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('flashcardDecks');

    switch (_sortBy) {
      case 'A-Z':
        return collection.orderBy('name', descending: false);
      case 'Z-A':
        return collection.orderBy('name', descending: true);
      case 'Oldest':
        return collection.orderBy('createdAt', descending: false);
      case 'Latest':
      default:
        return collection.orderBy('createdAt', descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Flashcards")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Decks',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchText = value.toLowerCase()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    DropdownButton<String>(
                      value: _sortBy,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                        DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                        DropdownMenuItem(value: 'Latest', child: Text('Latest')),
                        DropdownMenuItem(value: 'Oldest', child: Text('Oldest')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getDecksQuery().snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final decks = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchText);
                }).toList();

                if (decks.isEmpty) {
                  return const Center(child: Text("No decks found."));
                }

                return ListView.builder(
                  itemCount: decks.length,
                  itemBuilder: (context, index) {
                    final doc = decks[index];
                    final deck = doc.data() as Map<String, dynamic>;
                    final deckId = doc.id;
                    final name = deck['name'] ?? 'Untitled';
                    final isPublic = deck['isPublic'] == true;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text(
                          isPublic ? 'Public' : 'Private',
                          style: TextStyle(
                            color: isPublic ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudyModeScreen(deckId: deckId),
                            ),
                          );
                        },
                        onLongPress: () => _showDeckOptions(context, deckId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DeckEditorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Create New Deck',
      ),
    );
  }
}
