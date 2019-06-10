import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:todo_demo/model/todo.dart';

/// this class should create my table in the database
/// this uses factory settings which returns one line only every time
class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();
  String tblTodo = "todo";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  /// we create a static database object to use in the class
  static Database _db;

  ///this will check if the database is empty or not
  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }
    return _db;
  }

  /// we here use multi threading to create or open the database
  /// the future method will allow us to do that
  /// the path is differ from ios and android but this way it don't
  Future<Database> initializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "todos.db";

    /// here we create the database if it don't exist
    /// or simply open it
    var dbTodos = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbTodos;
  }

  /// in this method we create the database
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY, $colTitle TEXT, " +
            "$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  /// this would allow us to insert tables in the database
  Future<int> insertTodo(Todo todo) async {
    Database db = await this.db;
    var result = await db.insert(tblTodo, todo.toMap());
    return result;
  }

  /// this would return all the todos from the database and arrange them
  Future<List> getTodos() async {
    Database db = await this.db;
    var result =
        await db.rawQuery("SELECT * FROM $tblTodo order by $colPriority ASC");
    return result;
  }

  /// this would count the todos in the database
  Future<int> getCount() async {
    Database db = await this.db;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("select count (*) from $tblTodo"));
    return result;
  }

  /// this is the update method
  Future<int> updateTodo(Todo todo) async {
    var db = await this.db;
    var result = await db.update(tblTodo, todo.toMap(),
        where: "$colId = ?", whereArgs: [todo.id]);
    return result;
  }

  /// this is the delete method
  Future<int> deleteTodo(int id) async {
    int result;
    var db = await this.db;
    result = await db.rawDelete('DELETE FROM $tblTodo WHERE $colId = $id');
    return result;
  }
}
