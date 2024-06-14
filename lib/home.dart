import 'package:clipnote/SideMenuBar.dart';
import 'package:clipnote/colors.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/searchPage.dart';
import 'package:clipnote/services/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:clipnote/noteView.dart';
import 'package:clipnote/createNoteView.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  late List<Note> notesList = [];
  String note = lorem(paragraphs: 1, words: 9);
  String note1 = lorem(paragraphs: 1, words: 50);
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Future createEntry(Note note) async {
    await NotesDatabase.instance.insertEntry(note);
  }

  Future getAllNotes() async {
    notesList = await NotesDatabase.instance.readAllNotes();
    setState(() {
      isLoading = false;
    });
  }

  Future readOneNote(int id) async {
    await NotesDatabase.instance.readOneNote(id);
  }

  Future updateOneNote(Note note) async {
    await NotesDatabase.instance.updateNote(note);
  }

  Future deleteNote(int id) async {
    await NotesDatabase.instance.deleteNote(id);
  }

  @override
  void initState() {
    super.initState();
    _initializeNotes();
  }

  Future<void> _initializeNotes() async {
    await getAllNotes();
    if (notesList.isEmpty) {
      await createEntry(Note(
        pin: false,
        title: "Royal AJ",
        content: note1,
        createdTime: DateTime.now(),
      ));
      await getAllNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(backgroundColor: bgColor , body:
            Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateNoteview()));
              },
              backgroundColor: cardColor,
              child: Icon(
                Icons.add,
                color: white,
                size: 36,
              ),
            ),
            endDrawerEnableOpenDragGesture: true,
            key: _drawerKey,
            drawer: SideMenu(),
            backgroundColor: bgColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _drawerKey.currentState!.openDrawer();
                                },
                                icon: Icon(
                                  Icons.menu,
                                  color: white,
                                ),
                              ),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Searchpage()));
                                },
                                child: SizedBox(
                                  height: 55,
                                  width: 202,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Search your notes",
                                        style: TextStyle(
                                          color: white.withOpacity(0.5),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Icon(
                                  Icons.grid_view,
                                  color: white,
                                ),
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                    (states) => white.withOpacity(0.1),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 9),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      margin:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Text(
                        "ALL",
                        style: TextStyle(
                          color: white.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: MasonryGridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount: notesList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NoteView()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notesList[index].title,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    notesList[index].content.length > 250
                                        ? notesList[index]
                                            .content
                                            .substring(0, 250)
                                        : notesList[index].content,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF34A853),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "HEADING",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                !index.isEven ? note : note1,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
