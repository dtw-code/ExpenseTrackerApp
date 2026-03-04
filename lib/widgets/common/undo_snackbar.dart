import 'package:flutter/material.dart';

/// Shows a styled SnackBar for undo actions (single or bulk delete).
class UndoSnackBar {
  UndoSnackBar._();

  static void show({
    required BuildContext context,
    required VoidCallback onUndo,
    String message = 'Expense deleted',
    String actionLabel = 'Undo',
    int durationSeconds = 4,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        duration: Duration(seconds: durationSeconds),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.inverseSurface,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.onInverseSurface,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        action: SnackBarAction(
          label: actionLabel,
          textColor: colorScheme.primaryContainer,
          onPressed: onUndo,
        ),
      ),
    );
  }

  /// Message when multiple expenses were deleted.
  static void showBulkUndo({
    required BuildContext context,
    required VoidCallback onUndo,
    int count = 0,
    int durationSeconds = 5,
  }) {
    show(
      context: context,
      onUndo: onUndo,
      message: count <= 1
          ? 'Expense deleted'
          : '$count expenses deleted',
      actionLabel: 'Undo all',
      durationSeconds: durationSeconds,
    );
  }
}
