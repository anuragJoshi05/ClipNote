import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:clipnote/model/myNoteModel.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database;
  NotesDatabase._init();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initializeDB('Notes.db');
    return _database;
  }

  Future<Database?> _initializeDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final boolType = 'INTEGER NOT NULL';
    final textType = 'TEXT NOT NULL';
    await db.execute('''
    CREATE TABLE Notes (
      ${NotesImpNames.id} $idType,
      ${NotesImpNames.pin} $boolType, 
      ${NotesImpNames.title} $textType,
      ${NotesImpNames.content} $textType,
      ${NotesImpNames.createdTime} $textType,
    )
    ''');
  }

  Future<Note?> insertEntry(Note note) async {
    final db = await instance.database;
    final id = await db!.insert(NotesImpNames.tableName, note.toJson());
    return note.copy(id: id);
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final orderBy = '${NotesImpNames.createdTime} ASC';
    final query_result =
        await db!.query(NotesImpNames.tableName, orderBy: orderBy);
    return query_result.map((json) => Note.fromJson(json)).toList();
  }

  Future<Note?> readOneNote(int id) async {
    final db = await instance.database;
    final map = await db!.query(
      NotesImpNames.tableName,
      columns: NotesImpNames.values,
      where: '${NotesImpNames.id} = ?',
      whereArgs: [id],
    );
    if (map.isNotEmpty) {
      return Note.fromJson(map.first);
    } else {
      return null;
    }
  }

  Future updateNote(Note note) async {
    final db = await instance.database;
    return await db!.update(NotesImpNames.tableName, note.toJson(),
        where: '${NotesImpNames.id} = ?', whereArgs: [note.id]);
  }

  Future deleteNote(Note note) async {
    final db = await instance.database;
    await db!.delete(NotesImpNames.tableName,
        where: '${NotesImpNames.id} = ?', whereArgs: [note.id]);

    //Run this command in home.dart initState to delete Note.....
    //await NotesDatabase.instance.deleteNote(3);
  }

  Future closeDB() async {
    final db = await instance.database;
    db!.close();
  }
}
