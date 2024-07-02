import 'package:clipnote/services/db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clipnote/model/myNoteModel.dart';

class FireDB {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createNewNoteFirestore(Note note) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection("notes")
          .doc(currentUser.email)
          .collection("userNotes")
          .doc(note.uniqueID)
          .set({
        "Title": note.title,
        "uniqueID": note.uniqueID,
        "Content": note.content,
        "CreatedAt": note.createdTime,
        "isArchieve": note.isArchieve,
        "pin": note.pin,
        "backgroundImage": note.backgroundImage ?? "", // Set default value to ""

      }).then((_) {
        print("Note added successfully");
      }).catchError((error) {
        print("Failed to add note: $error");
      });
    }
  }

  Future<List<Note>> getAllStoredNotesForUser(String userEmail) async {
    List<Note> notesList = [];
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("notes")
          .doc(currentUser.email)
          .collection("userNotes")
          .orderBy("CreatedAt")
          .get();

      querySnapshot.docs.forEach((result) {
        Map<String, dynamic> note = result.data() as Map<String, dynamic>;
        notesList.add(Note(
          title: note["Title"],
          uniqueID: note["uniqueID"],
          content: note["Content"],
          createdTime: note["CreatedAt"].toDate(),
          pin: note["pin"],
          isArchieve: note["isArchieve"],
          backgroundImage: note["backgroundImage"], // Handle the backgroundImage field
        ));
      });
    }
    return notesList;
  }

  Future<void> updateNoteFirestore(Note note) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final noteRef = FirebaseFirestore.instance
          .collection("notes")
          .doc(currentUser.email)
          .collection("userNotes")
          .doc(note.uniqueID);

      final docSnapshot = await noteRef.get();

      if (!docSnapshot.exists) {
        print("No document to update with ID: ${note.uniqueID}");
        return;
      }

      await noteRef.update({
        "Title": note.title,
        "Content": note.content,
        "isArchieve": note.isArchieve,
        "pin": note.pin,
        "backgroundImage": note.backgroundImage, // New field
      }).then((_) {
        print("Note updated successfully");
      }).catchError((error) {
        print("Failed to update note: $error");
      });
    }
  }

  Future<void> deleteNoteFirestore(Note note) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection("notes")
          .doc(currentUser.email)
          .collection("userNotes")
          .doc(note.uniqueID)
          .delete()
          .then((_) {
        print("Note deleted successfully");
      }).catchError((error) {
        print("Failed to delete note: $error");
      });
    }
  }
}