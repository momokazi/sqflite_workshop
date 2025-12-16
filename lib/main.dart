import 'package:flutter/material.dart';
import 'database_helper.dart'; // Assuming your helper is here
import 'note.dart'; // Assuming your model is here

void main() {
  // Ensure the Flutter binding is initialized before using plugins like sqflite
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Notes Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NoteListScreen(),
    );
  }
}

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  // Instantiate the Database Helper (Singleton)
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Future to hold the notes list
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching notes as soon as the widget is created
    _notesFuture = _dbHelper.getNotes();
  }

  // Refreshes the list of notes
  void _refreshNotes() {
    setState(() {
      _notesFuture = _dbHelper.getNotes();
    });
  }

  // Handles adding/editing a note
  void _addOrEditNote({Note? note}) {
    // This is a simplified function call. In a real app,
    // you would navigate to a form screen.
    final titleController = TextEditingController(text: note?.title);
    final contentController = TextEditingController(text: note?.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add New Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(note == null ? 'Save' : 'Update'),
              onPressed: () async {
                final newNote = Note(
                  id: note?.id,
                  title: titleController.text,
                  content: contentController.text,
                );

                if (note == null) {
                  await _dbHelper.insertNote(newNote);
                } else {
                  await _dbHelper.updateNote(newNote);
                }

                Navigator.of(context).pop();
                _refreshNotes(); // Refresh the list after saving
              },
            ),
          ],
        );
      },
    );
  }

  // Handles deleting a note
  void _deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    _refreshNotes(); // Refresh the list after deleting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQFlite Notes')),
      body: FutureBuilder<List<Note>>(
        // The FutureBuilder watches the result of this Future
        future: _notesFuture,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          // Show a loading spinner while waiting for the data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Data has been successfully loaded
          final notes = snapshot.data;

          if (notes == null || notes.isEmpty) {
            return const Center(
              child: Text('No notes found. Tap "+" to add one!'),
            );
          }

          // Display the list of notes
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _addOrEditNote(note: note), // Edit on tap
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteNote(note.id!), // Delete on icon tap
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(), // Add new note
        child: const Icon(Icons.add),
      ),
    );
  }
}
