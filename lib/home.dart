import 'dart:math';
import 'package:clipnote/SideMenuBar.dart';
import 'package:clipnote/colors.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/searchPage.dart';
import 'package:clipnote/services/account_switcher.dart';
import 'package:clipnote/services/auth.dart';
import 'package:clipnote/services/db.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:clipnote/services/loginInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:clipnote/noteView.dart';
import 'package:clipnote/createNoteView.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isStaggered = true;
  bool isLoading = true;
  late List<Note> notesList = [];
  late String? imgUrl;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  final List<Color> borderColors = [
    Colors.red.withOpacity(0.5),
    Colors.green.withOpacity(0.5),
    Colors.blue.withOpacity(0.5),
    Colors.yellow.withOpacity(0.5),
    Colors.orange.withOpacity(0.5),
    Colors.purple.withOpacity(0.5),
    Colors.pink.withOpacity(0.5),
    Colors.teal.withOpacity(0.5),
    Colors.indigo.withOpacity(0.5),
    Colors.cyan.withOpacity(0.5),
    Colors.amber.withOpacity(0.5),
    Colors.lime.withOpacity(0.5),
    Colors.brown.withOpacity(0.5),
    Colors.grey.withOpacity(0.5),
  ];

  Future<List<GoogleSignInAccount>> getGoogleAccounts() async {
    try {
      await googleSignIn
          .signInSilently(); // Attempt to sign in silently to retrieve accounts
      return googleSignIn.currentUser != null
          ? [googleSignIn.currentUser!]
          : [];
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<void> createEntry(Note note) async {
    await NotesDatabase.instance.insertEntry(note);
    await getAllNotes(); // Update the list after creating a new entry
  }

  Future<void> getAllNotes() async {
    LocalDataSaver.getImg().then((value) {
      if (mounted) {
        setState(() {
          imgUrl = value;
        });
      }
    });
    notesList = await NotesDatabase.instance.readAllNotes();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> readOneNote(int id) async {
    await NotesDatabase.instance.readOneNote(id);
  }

  Future<void> updateOneNote(Note note) async {
    await NotesDatabase.instance.updateNote(note);
    await getAllNotes(); // Update the list after updating a note
  }

  Future<void> deleteNote(Note note) async {
    await NotesDatabase.instance.deleteNote(note);
    await getAllNotes(); // Update the list after deleting a note
  }

  Future<void> _fetchNotes() async {
    final User? user = await LoginInfo().getCurrentUser();
    if (user != null) {
      notesList = await FireDB().getAllStoredNotesForUser(user.email!);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getAllNotes();
    _fetchNotes(); // Fetch notes from Firestore for the current user
    LocalDataSaver.saveSyncSet(false); // Remove the sync button functionality
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
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateNoteview(),
                  ),
                );
                await getAllNotes(); // Update the list after returning from CreateNoteView
              },
              backgroundColor:
                  Colors.amber, // Set your desired background color here
              elevation: 4, // Adjust the elevation for a subtle shadow
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
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
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey
                              .withOpacity(0.5), // Add greyish white border
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _drawerKey.currentState!.openDrawer();
                                  },
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SearchPage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.white70,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(
                                              0.5), // Add greyish white border
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              "Search notes",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
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
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isStaggered = !isStaggered;
                                  });
                                },
                                style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) => Colors.white.withOpacity(0.1),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  isStaggered ? Icons.list : Icons.grid_view,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: InkWell(
                                  onTap: () async {
                                    final List<GoogleSignInAccount> accounts =
                                        await getGoogleAccounts();

                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AccountSwitcher(
                                            accounts: accounts);
                                      },
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: imgUrl != null
                                        ? NetworkImage(imgUrl!)
                                        : Image.asset('images/googleLogo.png')
                                            .image,
                                    backgroundColor: Colors.grey,
                                  ),
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
                        "ALL",
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
                          border: Border.all(
                            color: Colors.grey
                                .withOpacity(0.5), // Add greyish white border
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.note_add,
                              color: Colors.orangeAccent,
                              size: 50,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "No notes yet!",
                              style: TextStyle(
                                color: white.withOpacity(0.9),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your notes will appear here.",
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
                                        builder: (context) =>
                                            const CreateNoteview()));
                                // Add your note creation logic here
                              },
                              icon: const Icon(Icons.add, color: white),
                              label: const Text(
                                "Create a Note",
                                style: TextStyle(color: white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
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
    final borderColor = borderColors[Random().nextInt(borderColors.length)];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
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
          await _fetchNotes(); // Fetch notes from Firestore after returning from NoteView
        }
      },
      child: Stack(
        clipBehavior: Clip.none, // Allow the pin to overflow the container
        children: [
          Container(
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
              border: Border.all(
                color: borderColor, // Apply random border color
                width: 1,
              ),
              image: note.backgroundImage != null &&
                      note.backgroundImage!.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(note.backgroundImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
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
            Positioned(
              top: -7.5, // Adjust the top position for a 3D effect
              right: -6, // Adjust the right position for a 3D effect
              child: Transform.rotate(
                angle: 0.6, // Rotate the pin for a more realistic effect
                child: const Icon(
                  Icons.push_pin,
                  color: Colors.orangeAccent, // Adjust the color as needed
                  size: 23, // Adjust the size as needed
                ),
              ),
            ),
        ],
      ),
    );
  }
}
