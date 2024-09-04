import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/calenderTaskModel.dart';

class CalendarTaskHelper {
  static final CalendarTaskHelper _instance = CalendarTaskHelper._internal();
  factory CalendarTaskHelper() => _instance;
  
  CalendarTaskHelper._internal();
  
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meetings.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meetings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            eventName TEXT NOT NULL,
            from TEXT NOT NULL,
            to TEXT NOT NULL,
            background INTEGER NOT NULL,
            isAllDay INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE meetings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            eventName TEXT NOT NULL,
            from TEXT NOT NULL,
            to TEXT NOT NULL,
            background INTEGER NOT NULL,
            isAllDay INTEGER NOT NULL
          )
        ''');
      }
    );
  }

  // Future<void> _onCreate(Database db, int version) async {
  //   await db.execute('''
  //     CREATE TABLE meetings(
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       eventName TEXT NOT NULL,
  //       from TEXT NOT NULL,
  //       to TEXT NOT NULL,
  //       background INTEGER NOT NULL,
  //       isAllDay INTEGER NOT NULL
  //     )
  //   ''');
  // }

  Future<int> insertMeeting(Meeting meeting) async {
    Database db = await database;
    return await db.insert('meetings', meeting.toMap());
  }

  Future<List<Meeting>> getMeetings() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('meetings');

    return List.generate(maps.length, (i) {
      return Meeting.fromMap(maps[i]);
    });
  }

  Future<int> updateMeeting(Meeting meeting) async {
    Database db = await database;
    return await db.update(
      'meetings',
      meeting.toMap(),
      where: 'id = ?',
      whereArgs: [meeting.id],
    );
  }

  Future<int> deleteMeeting(int id) async {
    Database db = await database;
    return await db.delete(
      'meetings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    Database db = await database;
    await db.close();
  }
}