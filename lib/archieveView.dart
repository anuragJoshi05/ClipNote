import 'package:clipnote/SideMenuBar.dart';
import 'package:clipnote/colors.dart';
import 'package:clipnote/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:clipnote/noteView.dart';
import 'package:clipnote/createNoteView.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'package:clipnote/searchPage.dart';
import 'package:clipnote/services/loginInfo.dart';
import 'package:clipnote/login.dart';

class ArchieveView extends StatefulWidget {
  ArchieveView({super.key});

  @override
  State<ArchieveView> createState() => _ArchieveViewState();
}

class _ArchieveViewState extends State<ArchieveView> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool isLoading = true;
  bool isStaggered = true;
  late List<Note> notesList = [];
  late String? imgUrl;

  Future getAllArchievedNotes() async {
    LocalDataSaver.getImg().then((value) {
      if (this.mounted) {
        setState(() {
          imgUrl = value;
        });
      }
    });
    notesList = await NotesDatabase.instance.readAllNotes();
    notesList = notesList.where((note) => note.isArchieve).toList();
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllArchievedNotes();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateNoteview()));
                await getAllArchievedNotes(); // Update the list after returning from CreateNoteView
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
                physics: BouncingScrollPhysics(),
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
                                          builder: (context) =>
                                              SearchPage())); // Corrected to SearchPage()
                                },
                                child: SizedBox(
                                  height: 55,
                                  width:
                                      MediaQuery.of(context).size.width / 1.95,
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
                                onPressed: () {
                                  setState(() {
                                    isStaggered = !isStaggered;
                                  });
                                },
                                child: Icon(
                                  isStaggered ? Icons.list : Icons.grid_view,
                                  color: white,
                                ),
                                style: ButtonStyle(
                                  overlayColor:
                                      WidgetStateProperty.resolveWith(
                                    (states) => white.withOpacity(0.1),
                                  ),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 9),
                              GestureDetector(
                                onTap: () {
                                  signOut();
                                  LocalDataSaver.saveLoginData(false);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                                },
                                child: CircleAvatar(
                                  onBackgroundImageError: (Object, StackTrace) {
                                    print("OK");
                                  },
                                  radius: 16,
                                  backgroundImage:
                                      NetworkImage(imgUrl.toString()),
                                ),
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
                        "ARCHIVED",
                        style: TextStyle(
                          color: white.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (notesList.isEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lightbulb_outlined,
                              color: white,
                              size: 40,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No Archived notes",
                              style: TextStyle(
                                color: white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (notesList.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: isStaggered
                            ? MasonryGridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                itemCount: notesList.length,
                                itemBuilder: (context, index) {
                                  return _buildNoteItem(context, index);
                                },
                              )
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: notesList.length,
                                itemBuilder: (context, index) {
                                  return _buildNoteItem(context, index);
                                },
                              ),
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildNoteItem(BuildContext context, int index) {
    return InkWell(
      onTap: () async {
        final updatedNote = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteView(note: notesList[index]),
          ),
        );
        if (updatedNote != null) {
          setState(() {
            notesList[index] = updatedNote; // Update the list in the UI
          });
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        padding: const EdgeInsets.all(10.0),
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
                  ? notesList[index].content.substring(0, 250)
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
  }
}
