import 'dart:io';
import 'package:deep_waste/models/Category.dart';
import 'package:deep_waste/models/Item.dart';
import 'package:deep_waste/models/User.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static final _dbName = "deepwaste.db";

  // Use this class as a singleton
  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  static Database? _database; // Make _database nullable

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Instantiate the database only when it's not been initialized yet.
    _database = await _initDatabase();
    return _database!;
  }

  // Creates and opens the database.
  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    // Check if the database exists
    var dbExists = await databaseExists(path);

    if (!dbExists) {
      print("db not exist");

      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", _dbName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    // open the database
    return await openDatabase(path);
  }

  Future<List<Category>> getCategories() async {
    Database db = await instance.database;
    var categories = await db.query('Category');
    List<Category> categoryList = categories.isNotEmpty
        ? categories.map((c) => Category.fromMap(c)).toList()
        : [];
    return categoryList;
  }

  Future<List<Item>> getItems() async {
    Database db = await instance.database;
    var items = await db.query('Item');
    List<Item> itemList =
        items.isNotEmpty ? items.map((c) => Item.fromMap(c)).toList() : [];
    return itemList;
  }

  Future<User?> getUser() async {
    Database db = await instance.database;
    var user = await db.query('User');
    User? usr = user.isNotEmpty ? User.fromMap(user.first) : null;
    return usr;
  }

  Future<int> insertUser(User profile) async {
    final db = await instance.database;
    final id = await db.insert("User", profile.toMap());
    return id;
  }

  Future<int> deleteUser(int userId) async {
    final db = await instance.database;
    final id = await db.delete("User", where: "id = ?", whereArgs: [userId]);
    return id;
  }

  Future<int> updateItem(Item item) async {
    final db = await instance.database;
    final id = await db.update(
      "Item",
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    return id;
  }
}
