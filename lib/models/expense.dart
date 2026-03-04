import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; //for uuid
import 'package:intl/intl.dart'; //for date formatting'
final uuid=Uuid();
final formatter = DateFormat('dd/MM/yy');
enum Category{food,travel,leisure,work}
const categoryicons={  //like a map (key:value) pairs used for icon selection
  Category.food:Icons.lunch_dining,
  Category.travel:Icons.flight_takeoff,
  Category.leisure:Icons.movie,
  Category.work:Icons.work
};

class Expense{
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.id,
  });

  final String title;
  final double amount;
  final DateTime date;
  final String id;
  final Category category;

  String get formattedDate{
    return formatter.format(date);
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    Category? category,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: Category.values.firstWhere(
        (c) => c.name == map['category'],
      ),
    );
  }
}

class ExpenseBucket{
  ExpenseBucket({required this.category,required this.expenses});
  ExpenseBucket.forCategory(List<Expense> allExpenses,this.category)
     :expenses=allExpenses.where((expense) => expense.category==category).toList();


  final Category category;
  final List<Expense> expenses;
  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
    }
  }


