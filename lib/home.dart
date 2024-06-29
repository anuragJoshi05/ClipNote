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
import 'package:google_fonts/google_fonts.dart';
import 'package:clipnote/login.dart';
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
                          Expanded(
                            child: Row(
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
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SearchPage())); // Corrected to SearchPage()
                                    },
                                    child: SizedBox(
                                      height: 55,
                                      width: MediaQuery.of(context).size.width /
                                          1.95,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    (states) => white.withOpacity(0.1),
                                  ),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  isStaggered ? Icons.list : Icons.grid_view,
                                  color: white,
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
                                            CreateNoteview()));
                                // Add your note creation logic here
                              },
                              icon: Icon(Icons.add, color: white),
                              label: Text(
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
    );
  }
}
