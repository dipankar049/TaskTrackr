// Import the plugins Path provider and SQLite.
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

// Import UserModel
import 'package:task_master/models/dailyTaskModel.dart';

class DailyTaskHelper {
  // SQLite database instance
  static final DailyTaskHelper instance = DailyTaskHelper._internal();
  static Database? _database;

  DailyTaskHelper._internal(); 

  // Database name and version
  static const String databaseName = 'database.db';

  static const int versionNumber = 1;

  // Table name
  static const String dailyTask = 'DailyTask';

  // Table (Users) Columns
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDefaultMinutes = 'defaultMinutes';
  static const String colSpentMinutes = 'spentMinutes';
  static const String colSpentHours = 'spentHours';
  static const String colState = 'state';
  static const String colCompleted = 'completed';

  // Define a getter to access the database asynchronously.
  Future<Database> get database async {
    // If the database instance is already initialized, return it.
    if (_database != null) {
      return _database!;
    }

    // If the database instance is not initialized, call the initialization method.
    _database = await _initDatabase();

    // Return the initialized database instance.
    return _database!;
  }

  _initDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    String path = join(documentsDirectory.path, databaseName);
    // When the database is first created, create a table to store DailyTask.
    var db = await openDatabase(path, version: versionNumber, onCreate: _onCreate);
    return db;
  }

  // Run the CREATE TABLE statement on the database.
  _onCreate(Database db, int intVersion) async {
    await db.execute("CREATE TABLE IF NOT EXISTS $dailyTask ("
        " $colId INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $colTitle TEXT NOT NULL, "
        " $colDefaultMinutes INTEGER,"
        " $colSpentMinutes INTEGER,"
        " $colSpentHours INTEGER,"
        " $colState TEXT,"
        " $colCompleted INTEGER" 
        ")");
  }

  // A method that retrieves all the DailyTask from the DailyTask table.
  Future<List<DailyTaskModel>> getAll() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The DailyTask. {SELECT * FROM DailyTask ORDER BY Id ASC}
    final result = await db.query(dailyTask, orderBy: '$colId ASC');

    // Convert the List<Map<String, dynamic> into a List<Task>.
    return result.map((json) => DailyTaskModel.fromJson(json)).toList();
  }

  // Future<List<DailyTaskModel>> getActiveTask() async {
  //   // Get a reference to the database.
  //   final db = await database;

  //   // Query the table for all The DailyTask. {SELECT * FROM DailyTask ORDER BY Id ASC}
  //   final result = await db.query(dailyTask, orderBy: '$colId ASC');

  //   // Convert the List<Map<String, dynamic> into a List<Task>.
  //   return result.map((json) => DailyTaskModel.fromJson(json)).toList();
  // }

  // Serach task by Id
  Future<DailyTaskModel> read(int id) async {
    final db = await database;
    final maps = await db.query(
      dailyTask,
      where: '$colId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DailyTaskModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  // Define a function that inserts DailyTask into the database
  Future<void> insert(DailyTaskModel task) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the task into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same task is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(dailyTask, task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Define a function to update a task
  Future<int> update(DailyTaskModel task) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given task.
    var res = await db.update(dailyTask, task.toJson(),
        // Ensure that the task has a matching id.
        where: '$colId = ?',
        // Pass the task's id as a whereArg to prevent SQL injection.
        whereArgs: [task.id]);
    return res;
  }

  Future<int> updateTaskStatus(int taskId, int isCompleted) async {
    // Get a reference to the database.
    final db = await database; 


    // Update the given task.
    var res = await db.update(dailyTask, {'completed' : isCompleted},
        // Ensure that the task has a matching id.
        where: '$colId = ?',
        // Pass the task's id as a whereArg to prevent SQL injection.
        whereArgs: [taskId]);
    return res;
  }

  Future<int> updateTaskState(int taskId, String isActive) async {
    // Get a reference to the database.
    final db = await database; 


    // Update the given task.
    var res = await db.update(dailyTask, {'state' : isActive},
        // Ensure that the task has a matching id.
        where: '$colId = ?',
        // Pass the task's id as a whereArg to prevent SQL injection.
        whereArgs: [taskId]); 
    return res;
  }

  // Define a function to delete a task
  Future<void> delete(int id) async {
    // Get a reference to the database.
    final db = await database;
    try {
      // Remove the task from the database.
      await db.delete(dailyTask,
          // Use a `where` clause to delete a specific task.
          where: "$colId = ?",
          // Pass the Dog's id as a whereArg to prevent SQL injection.
          whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future close() async {
    final db = await database; 
    db.close();
  }
}