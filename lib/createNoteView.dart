import 'package:clipnote/home.dart';
import 'package:clipnote/services/db.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'model/myNoteModel.dart';
import 'package:uuid/uuid.dart';

class CreateNoteview extends StatefulWidget {
  const CreateNoteview({super.key});

  @override
  State<CreateNoteview> createState() => _CreateNoteviewState();
}

class _CreateNoteviewState extends State<CreateNoteview> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  var uuid = const Uuid();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: white),
        backgroundColor: bgColor,
        actions: [
          IconButton(
            splashRadius: 18,
            onPressed: () async {
              await NotesDatabase.instance.insertEntry(Note(
                  title: title.text,
                  uniqueID : uuid.v1(),
                  content: content.text,
                  pin: false,
                  isArchieve: false,
                  createdTime: DateTime.now()));

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const Home()));
            },
            icon: const Icon(Icons.save_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              TextField(
                cursorColor: white,
                controller: title,
                style: const TextStyle(
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
              const SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height - 150,
                child: TextField(
                  controller: content,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  cursorColor: white,
                  style: const TextStyle(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}