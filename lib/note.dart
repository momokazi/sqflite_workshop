class Note {
  final int? id;
  final String title;
  final String content;

  Note({this.id, required this.title, required this.content});

  // Convert a Note object into a Map. The keys must match the column names.
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content};
  }

  // Convert a Map (from a database query) into a Note object.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
    );
  }

  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content}';
  }
}
