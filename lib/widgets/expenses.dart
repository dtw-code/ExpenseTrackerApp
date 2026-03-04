import 'package:flutter/material.dart';

import 'package:expense_tracker/data/expense_repository.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/new_expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/common/undo_snackbar.dart';
import 'package:expense_tracker/widgets/expenses_list.dart';
import 'package:expense_tracker/widgets/home/home_page.dart';

class Expenses extends StatefulWidget {
  const Expenses({
    super.key,
    required this.repository,
    required this.month,
    this.showHomeButton = true,
  });

  final ExpenseRepository repository;
  final DateTime month;
  final bool showHomeButton;

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpense = [];
  var isloading = true;
  double _total = 0;

  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

  DateTime get _month => DateTime(widget.month.year, widget.month.month);

  Future<void> _openAddExpenseOverlay() async {
    final created = await showModalBottomSheet<Expense>(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(repository: widget.repository),
    );
    if (created == null) return;
    if (!mounted) return;
    setState(() {
      _registeredExpense.add(created);
      _registeredExpense.sort((a, b) => a.date.compareTo(b.date));
      _total = _registeredExpense.fold(0, (sum, item) => sum + item.amount);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final loaded = await widget.repository.loadMonthExpenses(_month);
    setState(() {
      _registeredExpense
        ..clear()
        ..addAll(loaded);
      _registeredExpense.sort((a, b) => a.date.compareTo(b.date));
      _total = _registeredExpense.fold(0, (sum, item) => sum + item.amount);
      isloading = false;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _onItemLongPress(Expense expense) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(expense.id);
    });
  }

  void _onItemTap(Expense expense) {
    if (!_selectionMode) return;
    setState(() {
      if (_selectedIds.contains(expense.id)) {
        _selectedIds.remove(expense.id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(expense.id);
      }
    });
  }

  void removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpense.indexOf(expense);
    setState(() {
      _registeredExpense.remove(expense);
      _total = _registeredExpense.fold(0, (sum, item) => sum + item.amount);
    });
    await widget.repository.deleteExpense(expense);
    if (!mounted) return;
    UndoSnackBar.show(
      context: context,
      message: 'Expense deleted',
      onUndo: () async {
        setState(() {
          _registeredExpense.insert(expenseIndex, expense);
          _registeredExpense.sort((a, b) => a.date.compareTo(b.date));
          _total = _registeredExpense.fold(0, (sum, item) => sum + item.amount);
        });
        await widget.repository.insertExpense(expense);
      },
    );
  }

  void _deleteSelectedExpenses() async {
    final toDelete = _registeredExpense
        .where((e) => _selectedIds.contains(e.id))
        .toList();
    if (toDelete.isEmpty) return;

    for (final e in toDelete) {
      _registeredExpense.remove(e);
      await widget.repository.deleteExpense(e);
    }
    setState(() {
      _total = _registeredExpense.fold(0, (sum, item) => sum + item.amount);
      _selectedIds.clear();
      _selectionMode = false;
    });

    if (!mounted) return;
    UndoSnackBar.showBulkUndo(
      context: context,
      count: toDelete.length,
      onUndo: () async {
        for (final e in toDelete) {
          await widget.repository.insertExpense(e);
        }
        setState(() {
          _registeredExpense.addAll(toDelete);
          _registeredExpense.sort((a, b) => a.date.compareTo(b.date));
          _total = _registeredExpense.fold(0, (sum, item) => sum + item.amount);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget maincontent = const Center(
      child: Text('No expenses yet. Start adding some!'),
    );

    if (_registeredExpense.isNotEmpty) {
      maincontent = ExpenseList(
        expenses: _registeredExpense,
        removeExpense: removeExpense,
        selectedIds: _selectedIds,
        onItemTap: _selectionMode ? _onItemTap : null,
        onItemLongPress: _selectionMode ? null : _onItemLongPress,
      );
    }

    if (isloading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget totalBanner() {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 2, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              'Total: Rs ${_total.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _exitSelectionMode,
              )
            : null,
        title: Text(
          _selectionMode
              ? '${_selectedIds.length} selected'
              : 'Expense Tracker',
        ),
        centerTitle: true,
        actions: [
          if (_selectionMode) ...[
            IconButton(
              onPressed: _selectedIds.isEmpty ? null : _deleteSelectedExpenses,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete selected',
            ),
          ] else ...[
            if (widget.showHomeButton)
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => HomePage(
                        repository: widget.repository,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.home_outlined),
              ),
            IconButton(
              onPressed: _openAddExpenseOverlay,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                Chart(expenses: _registeredExpense),
                Expanded(child: maincontent),
                totalBanner(),
              ],
            )
          : Row(
              children: [
                Expanded(child: Chart(expenses: _registeredExpense)),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: maincontent),
                      totalBanner(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
