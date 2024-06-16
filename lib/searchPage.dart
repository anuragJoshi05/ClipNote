import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Ensure the correct package is imported
import 'package:clipnote/colors.dart';
import 'package:clipnote/services/db.dart';
import 'noteView.dart';
import 'model/myNoteModel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Note?> searchResultNotes = [];
  bool isLoading = false;

  void searchResults(String query) async {
    setState(() {
      isLoading = true;
    });

    final resultNotes = await NotesDatabase.instance.searchNotes(query);
    setState(() {
      searchResultNotes = resultNotes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: white.withOpacity(0.1)),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_outlined),
                      color: white,
                    ),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: "Search Your Notes",
                          hintStyle: TextStyle(color: white.withOpacity(0.5), fontSize: 16),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            searchResults(value.toLowerCase());
                          });
                        },
                      ),
                    ),
                  ],
                ),
                isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
                    : noteSectionAll()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget noteSectionAll() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "SEARCH RESULTS",
                  style: TextStyle(color: white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: MasonryGridView.count(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: searchResultNotes.length,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              crossAxisCount: 2,
              itemBuilder: (context, index) {
                final note = searchResultNotes[index];
                return note == null
                    ? SizedBox()
                    : InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteView(note: note),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: white.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          note.content.length > 250
                              ? "${note.content.substring(0, 250)}..."
                              : note.content,
                          style: TextStyle(color: white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
