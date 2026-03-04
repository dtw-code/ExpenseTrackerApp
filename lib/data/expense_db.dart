import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:expense_tracker/models/expense.dart';

class ExpenseDb {
  ExpenseDb._internal();

  static final ExpenseDb instance = ExpenseDb._internal();

  static const _dbName = 'expense_tracker.db';
  static const _dbVersion = 1;
  static const _tableExpenses = 'expenses';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableExpenses (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            category TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Expense>> getExpensesForMonth(DateTime month) async {
    final db = await database;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final startIso = start.toIso8601String();
    final endIso = end.toIso8601String();

    final result = await db.query(
      _tableExpenses,
      where: 'date >= ? AND date < ?',
      whereArgs: [startIso, endIso],
      orderBy: 'date ASC',
    );

    return result.map(Expense.fromMap).toList();
  }

  Future<List<DateTime>> getMonthsWithExpenses() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT substr(date, 1, 7) AS ym
      FROM $_tableExpenses
      GROUP BY ym
      ORDER BY ym DESC
    ''');

    return result
        .map((row) {
          final ym = row['ym'] as String?;
          if (ym == null || ym.length != 7) return null;
          final parts = ym.split('-');
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          if (year == null || month == null) return null;
          return DateTime(year, month);
        })
        .whereType<DateTime>()
        .toList();
  }

  Future<Expense> insertExpense(Expense expense) async {
    final db = await database;
    final withId = expense.id.isEmpty
        ? expense.copyWith(id: uuid.v4())
        : expense;

    await db.insert(
      _tableExpenses,
      withId.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return withId;
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      _tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      _tableExpenses,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }
}

