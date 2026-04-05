import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class AppColors {
  static const primary = Color(0xFF00796B);
  static const secondary = Color(0xFF004D40);
  static const income = Color(0xFF4CAF50);
  static const expense = Color(0xFFE57373);
  static const background = Color(0xFFF5F5F5);
}

final List<CategoryModel> categories = [
  CategoryModel(name: 'Food', icon: Icons.restaurant, color: Colors.orange),
  CategoryModel(name: 'Transport', icon: Icons.directions_car, color: Colors.blue),
  CategoryModel(name: 'Shopping', icon: Icons.shopping_bag, color: Colors.pink),
  CategoryModel(name: 'Bills', icon: Icons.receipt, color: Colors.red),
  CategoryModel(name: 'Entertainment', icon: Icons.movie, color: Colors.purple),
  CategoryModel(name: 'Health', icon: Icons.medical_services, color: Colors.green),
  CategoryModel(name: 'Education', icon: Icons.school, color: Colors.indigo),
  CategoryModel(name: 'Salary', icon: Icons.payments, color: Colors.teal),
  CategoryModel(name: 'Investment', icon: Icons.trending_up, color: Colors.cyan),
  CategoryModel(name: 'Gift', icon: Icons.card_giftcard, color: Colors.amber),
  CategoryModel(name: 'Others', icon: Icons.more_horiz, color: Colors.grey),
];
