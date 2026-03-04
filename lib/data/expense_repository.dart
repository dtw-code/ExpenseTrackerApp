import 'package:expense_tracker/data/expense_db.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpenseRepository {
  ExpenseRepository({ExpenseDb? db}) : _db = db ?? ExpenseDb.instance;

  final ExpenseDb _db;

  Future<List<Expense>> loadMonthExpenses(DateTime month) {
    return _db.getExpensesForMonth(month);
  }

  Future<List<DateTime>> loadAvailableMonths() {
    return _db.getMonthsWithExpenses();
  }

  Future<Expense> createExpense({
    required String title,
    required double amount,
    required DateTime date,
    required Category category,
  }) async {
    final expense = Expense(
      id: '',
      title: title.trim(),
      amount: amount,
      date: date,
      category: category,
    );

    return _db.insertExpense(expense);
  }

  Future<void> deleteExpense(Expense expense) {
    return _db.deleteExpense(expense.id);
  }

  Future<void> updateExpense(Expense expense) {
    return _db.updateExpense(expense);
  }

  Future<void> insertExpense(Expense expense) {
    return _db.insertExpense(expense);
  }
}

