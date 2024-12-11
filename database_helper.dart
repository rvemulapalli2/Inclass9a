import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path_provider/path_provider.dart'; // For Android/iOS storage
import 'dart:io' show Platform; // For detecting platforms other than web

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'my_table';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnAge = 'age';

  Database? _db;

  // Initialization: Use SQLite on mobile, avoid it on the web
  Future<void> init() async {
    if (kIsWeb) {
      // No filesystem access on web
      debugPrint('Running on the web, no local SQLite DB.');
      return;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnAge INTEGER NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    if (kIsWeb) {
      debugPrint('Insert operation skipped on the web.');
      return 0;
    }
    return await _db!.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    if (kIsWeb) {
      debugPrint('Query operation skipped on the web.');
      return [];
    }
    return await _db!.query(table);
  }

  Future<int> queryRowCount() async {
    if (kIsWeb) {
      debugPrint('Query row count skipped on the web.');
      return 0;
    }
    final results = await _db!.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> update(Map<String, dynamic> row) async {
    if (kIsWeb) {
      debugPrint('Update operation skipped on the web.');
      return 0;
    }
    int id = row[columnId];
    return await _db!.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    if (kIsWeb) {
      debugPrint('Delete operation skipped on the web.');
      return 0;
    }
    return await _db!.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Query by ID (Extra feature)
  Future<Map<String, dynamic>?> queryById(int id) async {
    if (kIsWeb) {
      debugPrint('Query by ID skipped on the web.');
      return null;
    }
    final result = await _db!.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Delete All Records (Extra feature)
  Future<int> deleteAll() async {
    if (kIsWeb) {
      debugPrint('Delete all operation skipped on the web.');
      return 0;
    }
    return await _db!.delete(table);
  }
}
