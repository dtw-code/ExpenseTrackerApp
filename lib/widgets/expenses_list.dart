import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_item.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({
    super.key,
    required this.expenses,
    required this.removeExpense,
    this.selectedIds = const {},
    this.onItemTap,
    this.onItemLongPress,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) removeExpense;
  final Set<String> selectedIds;
  final void Function(Expense expense)? onItemTap;
  final void Function(Expense expense)? onItemLongPress;

  bool get isSelectionMode => onItemLongPress != null;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        final isSelected = selectedIds.contains(expense.id);

        final child = ExpenseItem(
          expense,
          isSelected: isSelected,
          onTap: onItemTap != null ? () => onItemTap!(expense) : null,
          onLongPress: onItemLongPress != null
              ? () => onItemLongPress!(expense)
              : null,
        );

        if (isSelectionMode) {
          return child;
        }

        return Dismissible(
          key: ValueKey(expense.id),
          dismissThresholds: const {
            DismissDirection.endToStart: 0.4,
          },
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 28,
            ),
          ),
          onDismissed: (_) => removeExpense(expense),
          child: child,
        );
      },
    );
  }
}
