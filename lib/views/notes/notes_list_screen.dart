import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  Set<String> expandedNoteIds = {};
  String _searchText = '';
  String _sortBy = 'Latest';

  void _toggleExpand(String noteId) {
    setState(() {
      if (expandedNoteIds.contains(noteId)) {
        expandedNoteIds.remove(noteId);
      } else {
        expandedNoteIds.add(noteId);
      }
    });
  }

  void _copyUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard')),
    );
  }

  Query _getNotesQuery() {
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');

    switch (_sortBy) {
      case 'A-Z':
        return notesCollection.orderBy('name', descending: false);
      case 'Z-A':
        return notesCollection.orderBy('name', descending: true);
      case 'Oldest':
        return notesCollection.orderBy('createdAt', descending: false);
      case 'Latest':
      default:
        return notesCollection.orderBy('createdAt', descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Notes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Notes',
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
                          setState(() {
                            _sortBy = value;
                          });
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
              stream: _getNotesQuery().snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredNotes = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchText);
                }).toList();

                if (filteredNotes.isEmpty) {
                  return const Center(child: Text("No notes found."));
                }

                return ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final doc = filteredNotes[index];
                    final note = doc.data() as Map<String, dynamic>;
                    final noteId = doc.id;

                    final name = note['name'] ?? '';
                    final url = note['url'] ?? '';
                    final description = note['description'] ?? '';
                    final isPublic = note['isPublic'] == true;
                    final isExpanded = expandedNoteIds.contains(noteId);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () => _toggleExpand(noteId),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    isPublic ? 'Public' : 'Private',
                                    style: TextStyle(
                                      color: isPublic ? Colors.green : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NoteEditorScreen(noteId: noteId),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (isExpanded && description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    description,
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ),
                              if (isExpanded && url.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          url,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () => _copyUrl(url),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
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
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Create New Note',
      ),
    );
  }
}
