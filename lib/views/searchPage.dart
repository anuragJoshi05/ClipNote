import 'package:clipnote/views/colors.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/views/noteView.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Note> _searchResults = [];
  bool _isLoading = false;

  void _searchNotes(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final FireDB fireDB = FireDB();
      final String email = await fireDB.getCurrentUserEmail();
      final List<Note> notes = await fireDB.getAllStoredNotesForUser(email);
      List<Note> filteredNotes = notes.where((note) {
        return note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        _searchResults = filteredNotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately, e.g., show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            if (query.isNotEmpty) {
              _searchNotes(query);
            } else {
              setState(() {
                _searchResults = [];
              });
            }
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: bgColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'No results found.',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final note = _searchResults[index];
                    final backgroundImage = note.backgroundImage ??
                        'images/default_bg.png'; // Default image
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(backgroundImage),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 10.0),
                      child: ListTile(
                        title: Text(
                          note.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          note.content.length > 100
                              ? '${note.content.substring(0, 100)}...'
                              : note.content,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () async {
                          final updatedNote = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteView(
                                note: note,
                                onNoteUpdated: (Note updatedNote) {
                                  setState(() {
                                    _searchResults[index] = updatedNote;
                                  });
                                },
                              ),
                            ),
                          );
                          if (updatedNote != null) {
                            _searchNotes(_searchController
                                .text); // Refresh search results
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
