import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<FileSystemEntity> _savedNotes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedNotes();
  }

  Future<void> _loadSavedNotes() async {
    final dir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${dir.path}/notes');
    if (await notesDir.exists()) {
      setState(() {
        _savedNotes = notesDir.listSync();
      });
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _noteController.text;
    if (title.isEmpty || content.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${dir.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }

    final file = File('${notesDir.path}/$title.txt');
    await file.writeAsString(content);

    _titleController.clear();
    _noteController.clear();
    _loadSavedNotes();
  }

  Future<void> _openNote(File file) async {
    final content = await file.readAsString();
    setState(() {
      _titleController.text = file.uri.pathSegments.last.replaceAll('.txt', '');
      _noteController.text = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
  leading: TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('<', style: TextStyle(fontSize: 16)),
  ),
  title: const Text('Notes'),
),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Note Title'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  hintText: 'Write your note here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _saveNote, child: const Text('Save Note')),
            const SizedBox(height: 10),
            const Divider(),
            const Text('Saved Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _savedNotes.length,
                itemBuilder: (context, index) {
                  final file = _savedNotes[index] as File;
                  final fileName = file.uri.pathSegments.last;
                  return ListTile(
                    title: Text(fileName.replaceAll('.txt', '')),
                    onTap: () => _openNote(file),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
