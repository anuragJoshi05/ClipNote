import 'package:flutter/material.dart';
import 'package:clipnote/editNoteView.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'colors.dart';

class NoteView extends StatelessWidget {
  final Note note;

  NoteView({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        backgroundColor: bgColor,
        title: Text(
          note.title,
          style: TextStyle(color: white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: white),
            onPressed: () async {
              final updatedNote = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditNoteView(note: note)),
              );
              if (updatedNote != null) {
                Navigator.pop(context, updatedNote);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.archive, color: white),
            onPressed: () {
              // TODO: Archive functionality
            },
          ),
          IconButton(
            icon: Icon(note.pin ? Icons.push_pin : Icons.push_pin_outlined,
                color: white),
            onPressed: () async {
              final updatedNote = note.copy(pin: !note.pin);
              await NotesDatabase.instance.updateNote(updatedNote);
              Navigator.pop(context, updatedNote);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          note.content,
          style: TextStyle(color: white),
        ),
      ),
    );
  }
}
