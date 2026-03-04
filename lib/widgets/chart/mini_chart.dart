import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';

class MiniChart extends StatelessWidget {
  const MiniChart({
    super.key,
    required this.expenses,
  });

  final List<Expense> expenses;

  List<ExpenseBucket> get buckets {
    return [
      ExpenseBucket.forCategory(expenses, Category.food),
      ExpenseBucket.forCategory(expenses, Category.leisure),
      ExpenseBucket.forCategory(expenses, Category.travel),
      ExpenseBucket.forCategory(expenses, Category.work),
    ];
  }

  double get maxTotalExpense {
    double maxTotalExpense = 0;

    for (final bucket in buckets) {
      if (bucket.totalExpenses > maxTotalExpense) {
        maxTotalExpense = bucket.totalExpenses;
      }
    }

    return maxTotalExpense;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (expenses.isEmpty || maxTotalExpense == 0) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.primaryContainer.withOpacity(0.25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'No data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
          ),
        ),
      );
    }

    final total = buckets.fold<double>(
      0,
      (sum, bucket) => sum + bucket.totalExpenses,
    );

    final segments = buckets.where((b) => b.totalExpenses > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Horizontal stacked bar for category mix
        Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: colorScheme.primaryContainer.withOpacity(0.3),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: segments.isEmpty
                ? [
                    Expanded(
                      child: Container(
                        color: colorScheme.primary.withOpacity(0.35),
                      ),
                    ),
                  ]
                : segments.map((bucket) {
                    final fraction = bucket.totalExpenses / total;
                    final flex = (fraction * 100).round().clamp(1, 100);
                    final color = switch (bucket.category) {
                      Category.food => colorScheme.primary,
                      Category.travel => colorScheme.tertiary,
                      Category.leisure => colorScheme.secondary,
                      Category.work => colorScheme.error,
                    };
                    return Expanded(
                      flex: flex,
                      child: Container(
                        color: color.withOpacity(0.9),
                      ),
                    );
                  }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        // Tiny legend with icons so it feels rich but compact
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: segments.map((bucket) {
            final icon = categoryicons[bucket.category];
            final labelAmount = bucket.totalExpenses.toStringAsFixed(0);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                ),
                const SizedBox(width: 2),
                Text(
                  labelAmount,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.85),
                      ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

