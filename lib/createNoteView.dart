import 'package:clipnote/home.dart';
import 'package:clipnote/services/db.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'model/myNoteModel.dart';

class CreateNoteview extends StatefulWidget {
  const CreateNoteview({super.key});

  @override
  State<CreateNoteview> createState() => _CreateNoteviewState();
}

class _CreateNoteviewState extends State<CreateNoteview> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        backgroundColor: bgColor,
        actions: [
          IconButton(
            splashRadius: 18,
            onPressed: () async {
              await NotesDatabase.instance.insertEntry(Note(
                  title: title.text,
                  content: content.text,
                  pin: false,
                  isArchieve: false,
                  createdTime: DateTime.now()));
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
            icon: Icon(Icons.save_outlined),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            TextField(
              cursorColor: white,
              controller: title,
              style: TextStyle(
                  fontSize: 25, color: white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: "Title",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.withOpacity(0.8),
                  )),
            ),
            Container(
                height: 300,
                child: TextField(
                  controller: content,
                  keyboardType: TextInputType.multiline,
                  minLines: 50,
                  maxLines: null,
                  cursorColor: white,
                  style: TextStyle(
                    fontSize: 17,
                    color: white,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: "Note",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.withOpacity(0.8),
                      )),
                )),
          ],
        ),
      ),
    );
  }
}
