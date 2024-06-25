import 'package:flutter/material.dart';
import 'package:clipnote/archieveView.dart';
import 'package:clipnote/home.dart';
import 'package:clipnote/editNoteView.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'colors.dart';
import 'package:intl/intl.dart';

class NoteView extends StatefulWidget {
  final Note note;

  NoteView({required this.note});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late Note _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        backgroundColor: bgColor,
        actions: [
          IconButton(
            icon: Icon(
              _note.isArchieve ? Icons.archive : Icons.archive_outlined,
              color: _note.isArchieve ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              final updatedNote = _note.copy(isArchieve: !_note.isArchieve);
              await NotesDatabase.instance.updateNote(updatedNote);

              setState(() {
                _note = updatedNote;
              });

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ArchieveView()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _note.pin ? Icons.push_pin : Icons.push_pin_outlined,
              color: _note.pin ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              final updatedNote = _note.copy(pin: !_note.pin);
              await NotesDatabase.instance.updateNote(updatedNote);

              setState(() {
                _note = updatedNote;
              });

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever_outlined, color: white),
            onPressed: () async {
              await NotesDatabase.instance.deleteNote(_note);
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
                    builder: (context) => EditNoteView(note: _note)),
              );
              if (updatedNote != null) {
                setState(() {
                  _note = updatedNote;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Created on ${DateFormat.yMMMMEEEEd().format(widget.note.createdTime)}",
                style: TextStyle(
                  color: white,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                _note.title,
                style: TextStyle(
                    fontSize: 25, color: white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                _note.content,
                style: TextStyle(
                  fontSize: 17,
                  color: white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
