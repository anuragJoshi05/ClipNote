import 'package:clipnote/SideMenuBar.dart';
import 'package:clipnote/colors.dart';
import 'package:clipnote/services/auth.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:clipnote/noteView.dart';
import 'package:clipnote/createNoteView.dart';
import 'package:clipnote/model/myNoteModel.dart';

import 'package:clipnote/searchPage.dart';
import 'package:clipnote/services/loginInfo.dart';
import 'package:clipnote/login.dart';
import 'home.dart';

class ArchieveView extends StatefulWidget {
  const ArchieveView({super.key});

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
      if (mounted) {
        setState(() {
          imgUrl = value;
        });
      }
    });

    // Fetch archived notes from Firestore
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      notesList = await FireDB().getAllStoredNotesForUser(userEmail);
      notesList = notesList.where((note) => note.isArchieve).toList();
    }

    if (mounted) {
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
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateNoteview()));
                await getAllArchievedNotes(); // Update the list after returning from CreateNoteView
              },
              backgroundColor: cardColor,
              child: const Icon(
                Icons.add,
                color: white,
                size: 36,
              ),
            ),
            endDrawerEnableOpenDragGesture: true,
            key: _drawerKey,
            drawer: const SideMenu(),
            backgroundColor: bgColor,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
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
                                icon: const Icon(
                                  Icons.menu,
                                  color: white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SearchPage())); // Corrected to SearchPage()
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
                                      MaterialStateProperty.resolveWith(
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
                              const SizedBox(width: 9),
                              GestureDetector(
                                onTap: () {
                                  signOut();
                                  LocalDataSaver.saveLoginData(false);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login()));
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: Text(
                        "STARRED",
                        style: TextStyle(
                          color: white.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (notesList.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_border_outlined,
                              color: Colors.orange,
                              size: 50,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "No Starred Notes",
                              style: TextStyle(
                                color: white.withOpacity(0.9),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your starred notes will appear here.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Home()));
                                // Add your logic to navigate to the notes section or create a note
                              },
                              icon: const Icon(Icons.add, color: white),
                              label: const Text(
                                "Go to Notes",
                                style: TextStyle(color: white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
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
    final note = notesList[index];
    return InkWell(
      onTap: () async {
        final updatedNote = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteView(
              note: notesList[index],
              onNoteUpdated: (Note updatedNote) {
                setState(() {
                  notesList[index] = updatedNote;
                });
              },
            ),
          ),
        );
        if (updatedNote != null) {
          await getAllArchievedNotes(); // Fetch notes from Firestore after returning from NoteView
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
          image:
          note.backgroundImage != null && note.backgroundImage!.isNotEmpty
              ? DecorationImage(
            image: AssetImage(note.backgroundImage!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20.0), // Adjust padding to avoid collision
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notesList[index].title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    notesList[index].content.length > 250
                        ? notesList[index].content.substring(0, 250)
                        : notesList[index].content,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (notesList[index].pin)
              const Positioned(
                bottom: 0,
                child: Icon(
                  Icons.push_pin,
                  color: Colors.orangeAccent, // Adjust the color as needed
                  size: 18, // Adjust the size as needed
                ),
              ),
          ],
        ),
      ),
    );
  }
}
