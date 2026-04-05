import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String notes;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'type': type.toString(), // Store as string to be safe
    'category': category,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: _parseType(data['type']),
      category: data['category']?.toString() ?? 'Others',
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      notes: data['notes']?.toString() ?? '',
    );
  }

  static TransactionType _parseType(dynamic type) {
    if (type == null) return TransactionType.expense;
    final typeStr = type.toString().toLowerCase();
    if (typeStr.contains('income')) return TransactionType.income;
    return TransactionType.expense;
  }
}

class CategoryModel {
  final String name;
  final IconData icon;
  final Color color;

  CategoryModel({required this.name, required this.icon, required this.color});
}
