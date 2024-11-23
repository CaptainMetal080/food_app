import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "FoodOrdering.db";
  static final _databaseVersion = 1;

  static final table = 'orders';
  static final columnId = '_id';
  static final columnFood = 'food_item';
  static final columnCost = 'cost';
  static final columnDate = 'date';

  // Singleton pattern for DatabaseHelper
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // The database reference
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the directory for the database
    var dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create table query
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnFood TEXT NOT NULL,
        $columnCost REAL NOT NULL,
        $columnDate TEXT NOT NULL
      )
    ''');
  }

  // Insert a new order
  Future<int> insertOrder(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  // Get orders for a specific date
  Future<List<Map<String, dynamic>>> getOrdersForDate(String date) async {
    Database db = await instance.database;
    return await db.query(table, where: '$columnDate = ?', whereArgs: [date]);
  }

  // Update an order
  Future<int> updateOrder(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [row[columnId]],
    );
  }


  // Delete an order
  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }


  // Get all orders
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    Database db = await instance.database;
    return await db.query(table);
  }
}
