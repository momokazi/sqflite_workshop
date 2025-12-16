import 'package:flutter/material.dart';
import 'database_helper.dart'; // Assuming your helper is here
import 'note.dart';
import 'notes_screen.dart'; // Assuming your model is here

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
