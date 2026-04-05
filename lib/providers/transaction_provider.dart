import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  double _savingsGoal = 5000.0;
  bool _isDarkMode = false;
  bool _isBiometricEnabled = false;
  String _userName = 'User';
  DateTime _selectedMonth = DateTime.now();

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  double get savingsGoal => _savingsGoal;
  bool get isDarkMode => _isDarkMode;
  bool get isBiometricEnabled => _isBiometricEnabled;
  String get userName => _userName;
  DateTime get selectedMonth => _selectedMonth;

  Future<void> loadTransactions() async {
    try {
      final settings = HiveService.getSettingsBox();
      _isDarkMode = settings.get('darkMode', defaultValue: false);
      _isBiometricEnabled = settings.get('biometric', defaultValue: false);
      _savingsGoal = settings.get('savingsGoal', defaultValue: 5000.0);
      _userName = settings.get('userName', defaultValue: 'User');

      final box = await HiveService.openBox();
      _transactions = box.values
          .map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (_transactions.isEmpty) {
        await _seedDummyData();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedMonth(DateTime date) {
    _selectedMonth = DateTime(date.year, date.month);
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((tx) =>
      tx.date.year == _selectedMonth.year && tx.date.month == _selectedMonth.month).toList();
  }

  Future<void> _seedDummyData() async {
    final dummyData = [
      TransactionModel(
        id: 'seed_1',
        amount: 50000,
        type: TransactionType.income,
        category: 'Salary',
        date: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Monthly salary',
      ),
      TransactionModel(
        id: 'seed_2',
        amount: 1500,
        type: TransactionType.expense,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Dinner',
      ),
    ];
    
    final box = await HiveService.openBox();
    for (var tx in dummyData) {
      await box.put(tx.id, tx.toMap());
      _transactions.add(tx);
    }
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final box = await HiveService.openBox();
    await box.put(tx.id, tx.toMap());
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final box = await HiveService.openBox();
    await box.put(tx.id, tx.toMap());
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = tx;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    final box = await HiveService.openBox();
    await box.delete(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    HiveService.getSettingsBox().put('darkMode', _isDarkMode);
    notifyListeners();
  }

  void toggleBiometric(bool value) {
    _isBiometricEnabled = value;
    HiveService.getSettingsBox().put('biometric', _isBiometricEnabled);
    notifyListeners();
  }

  void setSavingsGoal(double goal) {
    _savingsGoal = goal;
    HiveService.getSettingsBox().put('savingsGoal', _savingsGoal);
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    HiveService.getSettingsBox().put('userName', _userName);
    notifyListeners();
  }

  double get totalIncome => filteredTransactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, item) => sum + item.amount);
  double get totalExpenses => filteredTransactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, item) => sum + item.amount);
  double get currentBalance => totalIncome - totalExpenses;
  double get savingsProgress => _savingsGoal <= 0 ? 0 : (currentBalance / _savingsGoal).clamp(0.0, 1.0);

  List<double> get last7DaysSpending {
    List<double> dailySpending = List.filled(7, 0.0);
    DateTime today = DateUtils.dateOnly(DateTime.now());
    for (var tx in _transactions.where((t) => t.type == TransactionType.expense)) {
      int diff = today.difference(DateUtils.dateOnly(tx.date)).inDays;
      if (diff >= 0 && diff < 7) {
        dailySpending[6 - diff] += tx.amount;
      }
    }
    return dailySpending;
  }

  Map<String, double> get categoryBreakdown {
    Map<String, double> breakdown = {};
    for (var tx in filteredTransactions.where((t) => t.type == TransactionType.expense)) {
      breakdown[tx.category] = (breakdown[tx.category] ?? 0) + tx.amount;
    }
    return breakdown;
  }
}
