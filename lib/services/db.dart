import 'package:clipnote/services/firestore_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:clipnote/model/myNoteModel.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // updated for summary field
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';

    await db.execute('''
    CREATE TABLE $tableNotes ( 
      ${NoteFields.id} $idType, 
      ${NoteFields.uniqueID} $textType,
      ${NoteFields.pin} $boolType,
      ${NoteFields.isArchieve} $boolType,
      ${NoteFields.title} $textType,
      ${NoteFields.content} $textType,
      ${NoteFields.createdTime} $textType,
      ${NoteFields.backgroundImage} $nullableTextType,
      ${NoteFields.summary} $nullableTextType
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE $tableNotes ADD COLUMN ${NoteFields.isArchieve} BOOLEAN NOT NULL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE $tableNotes ADD COLUMN ${NoteFields.backgroundImage} TEXT');
    }
    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE $tableNotes ADD COLUMN ${NoteFields.summary} TEXT');
    }
  }

  Future<Note> insertEntry(Note note) async {
    final db = await instance.database;
    final id = await db.insert(tableNotes, note.toJson());
    await FireDB().createNewNoteFirestore(note);
    return note.copy(id: id);
  }

  Future<Note> readOneNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    const orderBy = '${NoteFields.createdTime} ASC';
    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> updateNote(Note note) async {
    await FireDB().updateNoteFirestore(note);
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> pinNote(Note note) async {
    final db = await instance.database;
    final int newPinValue = note.pin ? 0 : 1;

    await db.update(
      tableNotes,
      {NoteFields.pin: newPinValue},
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> archNote(Note note) async {
    final db = await instance.database;
    final int newArchValue = note.isArchieve ? 0 : 1;

    await db.update(
      tableNotes,
      {NoteFields.isArchieve: newArchValue},
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<List<Note>> readArchivedNotes() async {
    final db = await instance.database;

    final result = await db.query(
      tableNotes,
      where: '${NoteFields.isArchieve} = ?',
      whereArgs: [1],
    );

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> deleteNote(Note? note) async {
    await FireDB().deleteNoteFirestore(note!);
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;

    final result = await db.query(
      tableNotes,
      where: '${NoteFields.title} LIKE ? OR ${NoteFields.content} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete(tableNotes);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

const String tableNotes = 'notes';
