import 'package:clipnote/home.dart';
import 'package:flutter/material.dart';
import 'package:clipnote/editNoteView.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'colors.dart';

class NoteView extends StatefulWidget {
  final Note note;

  NoteView({required this.note});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.note.pin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        backgroundColor: bgColor,
        title: Text(
          widget.note.title,
          style: TextStyle(color: white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.archive, color: white),
            onPressed: () {
              // TODO: Archive functionality
            },
          ),
          IconButton(
            icon: Icon(
              widget.note.pin ? Icons.push_pin : Icons.push_pin_outlined,
              color: widget.note.pin ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              await NotesDatabase.instance.pinNote(widget.note);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever_outlined, color: white),
            onPressed: () async {
              await NotesDatabase.instance.deleteNote(widget.note.id);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          IconButton(
            icon: Icon(Icons.edit, color: white),
            onPressed: () async {
              final updatedNote = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditNoteView(note: widget.note)),
              );
              if (updatedNote != null) {
                Navigator.pop(context, updatedNote);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.note.content,
          style: TextStyle(color: white),
        ),
      ),
    );
  }
}
