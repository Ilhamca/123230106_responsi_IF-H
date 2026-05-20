import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabase {
  SqliteDatabase._();

  static const String _databaseName = 'latrespfinal057.db';
  static const int _databaseVersion = 1;
  static const String _usersTable = 'users';
  static const String _sessionTable = 'session';

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  static Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_sessionTable (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        is_logged_in INTEGER NOT NULL DEFAULT 0,
        current_user TEXT
      )
    ''');

    await db.insert(_sessionTable, <String, Object?>{
      'id': 1,
      'is_logged_in': 0,
      'current_user': null,
    });
  }

  static Future<bool> registerUser({
    required String username,
    required String password,
  }) async {
    final db = await database;
    final existingUser = await db.query(
      _usersTable,
      where: 'username = ?',
      whereArgs: <Object?>[username],
      limit: 1,
    );

    if (existingUser.isNotEmpty) {
      return false;
    }

    await db.insert(
      _usersTable,
      <String, Object?>{
        'username': username,
        'password': password,
      },
    );
    return true;
  }

  static Future<bool> verifyLogin({
    required String username,
    required String password,
  }) async {
    final db = await database;
    final user = await db.query(
      _usersTable,
      where: 'username = ? AND password = ?',
      whereArgs: <Object?>[username, password],
      limit: 1,
    );

    if (user.isEmpty) {
      return false;
    }

    await setSession(isLoggedIn: true, currentUser: username);
    return true;
  }

  static Future<void> setSession({
    required bool isLoggedIn,
    required String? currentUser,
  }) async {
    final db = await database;
    await db.update(
      _sessionTable,
      <String, Object?>{
        'is_logged_in': isLoggedIn ? 1 : 0,
        'current_user': currentUser,
      },
      where: 'id = 1',
    );
  }

  static Future<void> logout() async {
    await setSession(isLoggedIn: false, currentUser: null);
  }

  static Future<bool> isLoggedIn() async {
    final db = await database;
    final rows = await db.query(
      _sessionTable,
      where: 'id = 1',
      limit: 1,
    );

    if (rows.isEmpty) {
      return false;
    }

    return (rows.first['is_logged_in'] as int? ?? 0) == 1;
  }

  static Future<String> getCurrentUsername() async {
    final db = await database;
    final rows = await db.query(
      _sessionTable,
      where: 'id = 1',
      limit: 1,
    );

    if (rows.isEmpty) {
      return 'User';
    }

    return rows.first['current_user'] as String? ?? 'User';
  }
}