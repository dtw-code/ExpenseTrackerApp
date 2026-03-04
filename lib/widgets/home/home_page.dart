import 'package:flutter/material.dart';

import 'package:expense_tracker/data/expense_repository.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses.dart';
import 'package:expense_tracker/widgets/home/month_tile.dart';
import 'package:expense_tracker/models/expense.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.repository,
  });

  final ExpenseRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  List<DateTime> _months = [];
  final Map<DateTime, double> _totalsByMonth = {};
  final Map<DateTime, List<Expense>> _expensesByMonth = {};

  @override
  void initState() {
    super.initState();
    _loadMonths();
  }

  Future<void> _loadMonths() async {
    setState(() {
      _isLoading = true;
    });

    final months = await widget.repository.loadAvailableMonths();

    final totals = <DateTime, double>{};
    final expensesByMonth = <DateTime, List<Expense>>{};
    for (final month in months) {
      final expenses = await widget.repository.loadMonthExpenses(month);
      expensesByMonth[month] = expenses;
      totals[month] = expenses.fold<double>(
        0,
        (sum, e) => sum + e.amount,
      );
    }

    if (!mounted) return;

    setState(() {
      _months = months;
      _totalsByMonth
        ..clear()
        ..addAll(totals);
      _expensesByMonth
        ..clear()
        ..addAll(expensesByMonth);
      _isLoading = false;
    });
  }

  void _openMonth(DateTime month) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Expenses(
          repository: widget.repository,
          month: month,
          showHomeButton: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Overview'),
        centerTitle: true,
      ),
      body: _months.isEmpty
          ? const Center(
              child: Text('No expenses yet. Start adding some!'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 4,
                children: _months
                    .map(
                      (month) {
                        final expenses = _expensesByMonth[month] ?? const <Expense>[];
                        final total = _totalsByMonth[month] ?? 0;
                        return MonthTile(
                          month: month,
                          total: total,
                          expenses: expenses,
                          onTap: () => _openMonth(month),
                        );
                      },
                    )
                    .toList(),
              ),
            ),
    );
  }
}

