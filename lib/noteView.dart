import 'package:clipnote/colors.dart';
import 'package:clipnote/editNoteView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'model/myNoteModel.dart';

class NoteView extends StatefulWidget {
  Note note;
  NoteView({super.key, required this.note});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        backgroundColor: bgColor,
        elevation: 0.00,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.push_pin_outlined),
            splashRadius: 18,
            color: white,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.archive_outlined),
            splashRadius: 18,
            color: white,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Editnoteview()));
            },
            icon: Icon(Icons.edit_outlined),
            splashRadius: 18,
            color: white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.note.title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                widget.note.content,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
