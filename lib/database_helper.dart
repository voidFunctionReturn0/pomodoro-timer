import 'package:path/path.dart';
import 'package:pomodoro_timer/models/timer_item.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future initDatabase() async {
    String path = join(await getDatabasesPath(), 'pomodoro_timer_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE timers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            minutes INTEGER
          )
        ''');
        await db.insert('timers', const TimerItem(minutes: 25).toMap());
        await db.insert('timers', const TimerItem(minutes: 5).toMap());
      },
    );
  }

  Future insertTimer(TimerItem timer) async {
    Database db = await database;
    return await db.insert('timers', timer.toMap());
  }

  Future<List<TimerItem>> getTimers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('timers');
    return List.generate(maps.length, (index) {
      return TimerItem(
        id: maps[index]['id'],
        minutes: maps[index]['minutes'],
      );
    });
  }

  Future deleteTimer(int id) async {
    Database db = await database;
    await db.delete(
      'timers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
