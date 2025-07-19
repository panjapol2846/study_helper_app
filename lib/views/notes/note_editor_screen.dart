import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _descController = TextEditingController();

  bool _isNewNote = true;
  bool _isSaving = false;
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      _isNewNote = false;
      _loadNote();
    }
  }

  Future<void> _loadNote() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(widget.noteId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _urlController.text = data['url'] ?? '';
      _descController.text = data['description'] ?? '';
      _isPublic = data['isPublic'] is bool ? data['isPublic'] as bool : false;
      setState(() {}); // Ensure UI updates with loaded value
    }
  }


  Future<void> _saveNote() async {
    setState(() => _isSaving = true);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final now = Timestamp.now();

    final data = {
      'name': _nameController.text.trim(),
      'url': _urlController.text.trim(),
      'description': _descController.text.trim(),
      'isPublic': _isPublic,
      'updatedAt': now,
    };

    if (_isNewNote) {
      data['createdAt'] = now;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notes')
          .add(data);
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(widget.noteId)
          .update(data);
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteNote() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(widget.noteId)
        .delete();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewNote ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
          if (!_isNewNote)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteNote),
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
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _descController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}