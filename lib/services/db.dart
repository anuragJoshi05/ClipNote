import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    await db.execute('''
    CREATE TABLE Notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pin INTEGER NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      createdTime TEXT NOT NULL
    )
    ''');
  }

  Future<void> insertEntry() async {
    final db = await instance.database;
    await db!.insert("Notes", {
      "pin": 0, // Use 0 for false and 1 for true
      "title": "FLUTTER IS GOOD",
      "content": "THIS IS MY NOTE CONTENT",
      "createdTime": "13 June 2024"
    });
  }

  Future<String> readAllNotes() async {
    final db = await instance.database;
    final orderBy = 'createdTime ASC';
    final query_result = await db!.query("Notes", orderBy: orderBy);
    print(query_result);
    return "SUCCESSFUL";
  }

  Future<String?> readOneNote(int id) async {
    final db = await instance.database;
    final map = await db!.query(
      "Notes",
      columns: ["title"],
      where: 'id = ?',
      whereArgs: [id],
    );
    print(map);
    return map.isNotEmpty ? map.first['title'] as String : null;
  }

  Future updateNote(int id) async {
    final db = await instance.database;
    return await db!.update("Notes", {"title": "This is updated title"},
        where: "id = ?", whereArgs: [id]);
  }
  Future deleteNote(int id) async {
    final db = await instance.database;
    await db!.delete("TABLE NAME", where: 'id: ?', whereArgs: [id]);

    //Run this command in home.dart initState to delete Note.....
    //await NotesDatabase.instance.deleteNote(3);
  }
}
