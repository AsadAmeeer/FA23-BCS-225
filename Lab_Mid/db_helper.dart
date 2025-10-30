import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/patient.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('doctor_plus.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory docDir = await getApplicationDocumentsDirectory();
    final path = join(docDir.path, fileName);
    // bump DB version to add new columns (gender, notes, phone, docPathsJson)
    return await openDatabase(path,
        version: 4, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER,
        gender TEXT,
        notes TEXT,
        disease TEXT,
        phone TEXT,
        imagePath TEXT,
        docPathsJson TEXT,
        documentPath TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add columns incrementally for older databases
    if (oldVersion < 2) {
      // legacy: ensure documentPath exists
      try {
        await db.execute('ALTER TABLE patients ADD COLUMN documentPath TEXT');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      // add gender and notes
      try {
        await db.execute('ALTER TABLE patients ADD COLUMN gender TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE patients ADD COLUMN notes TEXT');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      // add phone and docPathsJson
      try {
        await db.execute('ALTER TABLE patients ADD COLUMN phone TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE patients ADD COLUMN docPathsJson TEXT');
      } catch (_) {}
    }
  }

  Future<int> insertPatient(Patient p) async {
    final db = await database;
    return await db.insert('patients', p.toMap());
  }

  Future<List<Patient>> getPatients() async {
    final db = await database;
    final rows = await db.query('patients', orderBy: 'id DESC');
    return rows.map((r) => Patient.fromMap(r)).toList();
  }

  Future<int> updatePatient(Patient p) async {
    final db = await database;
    return await db
        .update('patients', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }
}
