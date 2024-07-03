import 'package:clipnote/services/firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'colors.dart';

class EditNoteView extends StatefulWidget {
  final Note note;
  final String? backgroundImage;

  const EditNoteView({required this.note, this.backgroundImage, Key? key})
      : super(key: key);

  @override
  _EditNoteViewState createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _backgroundImage = widget.backgroundImage;
  }

  Future<void> _saveNote() async {
    final updatedNote = widget.note.copy(
      title: _titleController.text,
      content: _contentController.text,
      backgroundImage: _backgroundImage,
    );

    await NotesDatabase.instance.updateNote(updatedNote);
    await FireDB().updateNoteFirestore(updatedNote);

    Navigator.pop(context, updatedNote); // Pass the updated note back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_backgroundImage != null && _backgroundImage!.isNotEmpty)
            Positioned.fill(
              child: Image.asset(
                _backgroundImage!,
                fit: BoxFit.cover,
              ),
            ),
          Column(
            children: [
              AppBar(
                iconTheme: const IconThemeData(color: white),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    splashRadius: 18,
                    onPressed: _saveNote,
                    icon: const Icon(Icons.save_outlined, color: white),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(
                      children: [
                        TextField(
                          cursorColor: white,
                          controller: _titleController,
                          style: const TextStyle(
                            fontSize: 25,
                            color: white,
                            fontWeight: FontWeight.bold,
                          ),
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
                            ),
                          ),
                        ),
                        TextField(
                          controller: _contentController,
                          keyboardType: TextInputType.multiline,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
