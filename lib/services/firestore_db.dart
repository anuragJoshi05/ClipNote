import 'package:clipnote/services/db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clipnote/model/myNoteModel.dart';

class FireDB {
  // CREATE, READ, UPDATE, DELETE (CRUD)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> createNewNoteFirestore(Note note) async {
    final User? currentUser = _auth.currentUser;
    await FirebaseFirestore.instance
        .collection("notes")
        .doc(currentUser?.email)
        .collection("userNotes")
        .doc(note.uniqueID)
        .set({
      "Title": note.title,
      "uniqueID": note.uniqueID,
      "Content": note.content,
      "CreatedAt": note.createdTime,
    }).then((_) {
      print("DATE ADDED SUCCESSFULLY");
    }).catchError((error) {
      print("Failed to add note: $error");
    });
  }

  getAllStoredNotes() async {
    final User? currentUser = _auth.currentUser;
    await FirebaseFirestore.instance
        .collection("notes")
        .doc(currentUser?.email)
        .collection("userNotes")
        .orderBy("CreatedAt")
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        Map note = result.data();

        NotesDatabase.instance.insertEntry(Note(
            title: note["Title"],
            uniqueID: note["uniqueID"],
            content: note["Content"],
            createdTime: note["date"],
            pin: note["pin"],
            isArchieve: note["archive"]));
        // Add Notes In Database
      });
    }).catchError((error) {
      print("Failed to get notes: $error");
    });
  }

  Future<void> updateNoteFirestore(Note note) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("No user is currently signed in.");
      return;
    }

    final noteRef = FirebaseFirestore.instance
        .collection("notes")
        .doc(currentUser.email)
        .collection("userNotes") // Ensure consistent collection name
        .doc(note.uniqueID);

    final docSnapshot = await noteRef.get();

    if (!docSnapshot.exists) {
      print("No document to update with ID: ${note.uniqueID}");
      return;
    }

    await noteRef.update({
      "Title": note.title, // Ensure consistency with your Firestore fields
      "Content": note.content,
    }).then((_) {
      print("Note updated successfully");
    }).catchError((error) {
      print("Failed to update note: $error");
    });
  }


  Future<void> deleteNoteFirestore(Note note) async {
    final User? currentUser = _auth.currentUser;
    await FirebaseFirestore.instance
        .collection("notes")
        .doc(currentUser?.email.toString())
        .collection("userNotes")
        .doc(note.uniqueID.toString())
        .delete()
        .then((_) {
      print("DATA DELETED SUCCESSFULLY");
    });
  }
}
