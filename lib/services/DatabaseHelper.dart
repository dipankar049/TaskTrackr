import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/calenderTaskModel.dart';
import 'package:task_master/models/dailyTaskModel.dart';

class DatabaseHelper {

  // static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  static final DatabaseHelper instance = DatabaseHelper._init();
  factory DatabaseHelper() => instance;

  static Database? _database;
  DatabaseHelper._init();
  // DatabaseHelper._internal();


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'example.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS meetings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            eventName TEXT NOT NULL,
            "from" TEXT NOT NULL,
            "to" TEXT NOT NULL,
            background INTEGER NOT NULL,
            isAllDay INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS DailyTask (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            defaultMinutes INTEGER,
            spentMinutes INTEGER,
            spentHours INTEGER,
            state TEXT,
            completed INTEGER 
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS task_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskId INTEGER,
            date TEXT,
            duration INTEGER,
            status INTEGER
          )
        ''');
      }
    );
  }

  Future<void> insertMeeting(Meeting meeting) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'meetings',
      meeting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<Meeting>> getMeetings() async {
    final db = await DatabaseHelper.instance.database;

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

  
  //Dailytask operations
  Future<List<DailyTaskModel>> getAll() async {
    final db = await database;
    final result = await db.query('DailyTask', orderBy: 'id ASC');

    return result.map((json) => DailyTaskModel.fromJson(json)).toList();
  }

  Future<DailyTaskModel> read(int id) async {
    final db = await database;
    final maps = await db.query(
      'DailyTask',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DailyTaskModel.fromJson(maps.first);
    } else {
      throw Exception('ID id not found');
    }
  }

  Future<void> insert(DailyTaskModel task) async {
    final db = await database;
    await db.insert('DailyTask', task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(DailyTaskModel task) async {
    final db = await database;

    var res = await db.update('DailyTask', task.toJson(),
        where: 'id = ?',
        whereArgs: [task.id]);
    return res;
  }

  Future<int> updateTaskStatus(int taskId, int isCompleted) async {
    final db = await database; 

    var res = await db.update('DailyTask', {'completed' : isCompleted},
      where: 'id = ?',
      whereArgs: [taskId]);
    return res;
  }

  Future<int> updateTaskState(int taskId, String isActive) async {
    final db = await database; 


    // Update the given task.
    var res = await db.update('DailyTask', {'state' : isActive},
        // Ensure that the task has a matching id.
        where: 'id = ?',
        // Pass the task's id as a whereArg to prevent SQL injection.
        whereArgs: [taskId]); 
    return res;
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('DailyTask',
      where: "id = ?",
      whereArgs: [id]);
  }

  Future<void> close() async {
    Database db = await database;
    await db.close();
  }

  Future<int> storeTaskHistory(Map<String, dynamic> taskHistory) async {
    Database db = await instance.database;
    
    // Insert task history into the table (e.g., 'task_history')
    return await db.insert(
      'task_history',  // Name of your task history table
      taskHistory,     // Data to insert (Map<String, dynamic>)
      conflictAlgorithm: ConflictAlgorithm.replace,  // Replace in case of conflict
    );
  }

  // Method to retrieve all task history records
  Future<List<Map<String, dynamic>>> getTaskHistory() async {
    Database db = await instance.database;

    // Query the task_history table
    return await db.query('task_history');
  }

  // Method to retrieve task history by taskId
  Future<List<Map<String, dynamic>>> getTaskHistoryByTaskId(int taskId) async {
    Database db = await instance.database;

    // Query the task_history table for a specific taskId
    return await db.query(
      'task_history',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }
}
