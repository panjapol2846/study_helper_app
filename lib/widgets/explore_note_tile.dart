import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ExploreNoteTile extends StatelessWidget {
  const ExploreNoteTile({super.key});

  @override
  Widget build(BuildContext context) {
    final notesRef = FirebaseFirestore.instance.collectionGroup('notes');

    return StreamBuilder<QuerySnapshot>(
      stream: notesRef.where('isPublic', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No public notes found.'));
        }

        final notes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(note['name'] ?? 'No Title'),
              subtitle: Text(note['description'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  final url = note['url'] ?? '';
                  if (url.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL copied to clipboard')),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
