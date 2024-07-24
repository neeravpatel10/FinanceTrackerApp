import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  late Database _db;

  DatabaseHelper._instance();

  Future<Database> get db async {
    if (!isDatabaseInitialized) {
      _db = await _initDb();
      isDatabaseInitialized = true;
    }
    return _db;
  }

  bool isDatabaseInitialized = false;

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        category TEXT,
        date TEXT,
        description TEXT
      )
    ''');
  }

  Future<int> insertExpense(Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient.insert('expenses', row);
  }

  Future<int> updateExpense(Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient.update('expenses', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteExpense(int id) async {
    final dbClient = await db;
    return await dbClient.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAllExpenses() async {
    final dbClient = await db;
    return await dbClient.query('expenses');
  }
}
