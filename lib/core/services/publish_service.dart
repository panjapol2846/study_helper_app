import 'package:cloud_firestore/cloud_firestore.dart';

class PublishService {
  final _firestore = FirebaseFirestore.instance;

  // Fetch all public notes from all users
  Future<List<Map<String, dynamic>>> fetchPublicNotes() async {
    final querySnapshot = await _firestore
        .collectionGroup('notes')
        .where('public', isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['noteId'] = doc.id;
      data['userId'] = doc.reference.parent.parent?.id; // Get userId from the path
      return data;
    }).toList();
  }

  // Fetch all public decks from all users
  Future<List<Map<String, dynamic>>> fetchPublicDecks() async {
    final querySnapshot = await _firestore
        .collectionGroup('decks')
        .where('public', isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['deckId'] = doc.id;
      data['userId'] = doc.reference.parent.parent?.id; // Get userId from the path
      return data;
    }).toList();
  }
}
