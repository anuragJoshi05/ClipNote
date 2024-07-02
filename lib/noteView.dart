import 'package:clipnote/backgroundSwitcher.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:clipnote/home.dart';
import 'package:clipnote/editNoteView.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'colors.dart';
import 'package:intl/intl.dart';

class NoteView extends StatefulWidget {
  final Note note;
  final Function(Note) onNoteUpdated;

  const NoteView({super.key, required this.note, required this.onNoteUpdated});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> with SingleTickerProviderStateMixin {
  late Note _note;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;
  String? _backgroundImage;

  List<String> backgrounds = [
    "default",
    "images/bg1.jpg",
    "images/bg2.jpg",
    "images/bg3.jpg",
    "images/bg4.jpg",
    "images/bg5.jpg",
    "images/bg6.jpg",
    "images/bg7.jpg",
    "images/bg8.jpg",
    "images/bg9.jpg",
    "images/bg10.jpg"
  ];

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Load the background image from the note
    _backgroundImage = _note.backgroundImage;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateNoteArchiveStatus() async {
    setState(() {
      _isLoading = true;
    });
    _controller.forward().then((_) => _controller.reverse());

    final updatedNote = _note.copy(isArchieve: !_note.isArchieve);
    await NotesDatabase.instance.updateNote(updatedNote);
    await FireDB().updateNoteFirestore(updatedNote);

    setState(() {
      _note = updatedNote;
      _isLoading = false;
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }

  Future<void> _updateNotePinStatus() async {
    setState(() {
      _isLoading = true;
    });

    final updatedNote = _note.copy(pin: !_note.pin);
    await NotesDatabase.instance.updateNote(updatedNote);

    setState(() {
      _note = updatedNote;
      _isLoading = false;
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }

  Future<void> _deleteNote() async {
    setState(() {
      _isLoading = true;
    });

    await NotesDatabase.instance.deleteNote(_note);

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }

  Future<void> _editNote() async {
    setState(() {
      _isLoading = true;
    });

    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNoteView(note: _note, backgroundImage: _backgroundImage)),
    );
    if (updatedNote != null) {
      setState(() {
        _note = updatedNote;
        _isLoading = false;
      });
      widget.onNoteUpdated(updatedNote);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _changeBackground() async {
    final selectedBackground = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return BackgroundSwitcher(
          backgrounds: backgrounds,
        );
      },
    );

    if (selectedBackground != null) {
      setState(() {
        _backgroundImage = selectedBackground == "default" ? "" : selectedBackground;
      });

      final updatedNote = _note.copy(backgroundImage: _backgroundImage);
      await NotesDatabase.instance.updateNote(updatedNote);
      await FireDB().updateNoteFirestore(updatedNote);
      widget.onNoteUpdated(updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundImage == null || _backgroundImage!.isEmpty ? bgColor : null,
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
                    icon:
                    const Icon(Icons.delete_forever_outlined, color: white),
                    onPressed: _deleteNote,
                  ),
                  ScaleTransition(
                    scale: _animation,
                    child: IconButton(
                      icon: Icon(
                        _note.isArchieve ? Icons.star : Icons.star_outlined,
                        color: _note.isArchieve ? Colors.yellow : Colors.white,
                      ),
                      onPressed: _updateNoteArchiveStatus,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _note.pin ? Icons.push_pin : Icons.push_pin_outlined,
                      color: _note.pin ? Colors.red : Colors.white,
                    ),
                    onPressed: _updateNotePinStatus,
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Created on ${DateFormat.yMMMMEEEEd().format(widget.note.createdTime)}",
                              style: const TextStyle(
                                color: white,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              _note.title,
                              style: const TextStyle(
                                  fontSize: 25,
                                  color: white,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              _note.content,
                              style: const TextStyle(
                                fontSize: 17,
                                color: white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.yellow,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'colorButton',
            onPressed: _changeBackground,
            backgroundColor: Colors.yellow,
            child: const Icon(Icons.color_lens),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'editButton',
            onPressed: _editNote,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
