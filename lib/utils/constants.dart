import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class AppColors {
  static const primary = Color(0xFF9E7E38);
  static const secondary = Color(0xFF8B6E30);
  static const income = Color(0xFF10B981);
  static const expense = Color(0xFFE11D48);
  static const background = Color(0xFFFDFBF7);
}

final List<CategoryModel> categories = [
  CategoryModel(name: 'Food', icon: Icons.restaurant, color: const Color(0xFF8B7E74)),
  CategoryModel(name: 'Transport', icon: Icons.directions_car, color: const Color(0xFF64748B)),
  CategoryModel(name: 'Shopping', icon: Icons.shopping_bag, color: const Color(0xFFA68A56)),
  CategoryModel(name: 'Bills', icon: Icons.receipt, color: const Color(0xFF706B5E)),
  CategoryModel(name: 'Entertainment', icon: Icons.movie, color: const Color(0xFF475569)),
  CategoryModel(name: 'Health', icon: Icons.medical_services, color: const Color(0xFF0D9488)),
  CategoryModel(name: 'Education', icon: Icons.school, color: const Color(0xFF94A3B8)),
  CategoryModel(name: 'Salary', icon: Icons.payments, color: const Color(0xFF059669)),
  CategoryModel(name: 'Investment', icon: Icons.trending_up, color: const Color(0xFFC5A059)),
  CategoryModel(name: 'Gift', icon: Icons.card_giftcard, color: const Color(0xFF9A3412)),
];
