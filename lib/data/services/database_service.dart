import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
import '../models/shopping_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ucook_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount_cop INTEGER NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            spent_on TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE shopping_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            list_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            quantity REAL NOT NULL DEFAULT 1,
            unit TEXT,
            is_done INTEGER NOT NULL DEFAULT 0,
            source_food_id INTEGER
          );
        ''');
      },
    );
  }

  // --- Expenses ---
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'spent_on DESC');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // --- Shopping Items ---
  Future<List<ShoppingItem>> getShoppingItems() async {
    final db = await database;
    final maps = await db.query('shopping_items', orderBy: 'is_done ASC, id DESC');
    return maps.map((m) => ShoppingItem.fromMap(m)).toList();
  }

  Future<int> insertShoppingItem(ShoppingItem item) async {
    final db = await database;
    return await db.insert('shopping_items', item.toMap());
  }

  Future<int> updateShoppingItem(ShoppingItem item) async {
    final db = await database;
    return await db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteShoppingItem(int id) async {
    final db = await database;
    return await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
  }
}
