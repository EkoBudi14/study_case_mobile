import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/bleDeviceModel.dart';

class DatabaseDeviceHelper {
  final String _databaseName = 'ble_tracker.db';
  final int _databaseVersion = 1;

  final String table = 'devices';

  static Database? db;

  Future<Database> database() async {
    if (db != null) return db!;
    db = await _initDatabase();
    return db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $table ('
      'id TEXT PRIMARY KEY, '
      'name TEXT NOT NULL, '
      'rssi INTEGER NOT NULL, '
      'last_seen INTEGER NOT NULL)',
    );
  }

  Future<void> upsert(BleDeviceModel device) async {
    final database = await this.database();
    await database.insert(
      table,
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BleDeviceModel>> all() async {
    final database = await this.database();
    final rows = await database.query(table, orderBy: 'last_seen DESC');
    return rows.map(BleDeviceModel.fromMap).toList();
  }

  Future<void> clear() async {
    final database = await this.database();
    await database.delete(table);
  }
}
