import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  double _savingsGoal = 0.0;
  bool _isDarkMode = false;
  bool _isBiometricEnabled = false;
  String _userName = 'User';
  DateTime _selectedMonth = DateTime.now();
  
  bool _isFirstRun = true;
  bool _isLoggedIn = false;
  String? _userAvatar;
  double _fontSizeFactor = 1.0;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  double get savingsGoal => _savingsGoal;
  bool get isDarkMode => _isDarkMode;
  bool get isBiometricEnabled => _isBiometricEnabled;
  String get userName => _userName;
  DateTime get selectedMonth => _selectedMonth;
  bool get isFirstRun => _isFirstRun;
  bool get isLoggedIn => _isLoggedIn;
  String? get userAvatar => _userAvatar;
  double get fontSizeFactor => _fontSizeFactor;

  Future<void> loadTransactions() async {
    try {
      final settings = HiveService.getSettingsBox();
      _isDarkMode = settings.get('darkMode', defaultValue: false);
      _isBiometricEnabled = settings.get('biometric', defaultValue: false);
      _savingsGoal = settings.get('savingsGoal', defaultValue: 0.0);
      _userName = settings.get('userName', defaultValue: 'User');
      _isFirstRun = settings.get('isFirstRun', defaultValue: true);
      _isLoggedIn = settings.get('isLoggedIn', defaultValue: false);
      _userAvatar = settings.get('userAvatar');
      _fontSizeFactor = settings.get('fontSizeFactor', defaultValue: 1.0);

      final box = await HiveService.openBox();
      _transactions = box.values
          .map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void completeOnboarding() {
    _isFirstRun = false;
    HiveService.getSettingsBox().put('isFirstRun', false);
    notifyListeners();
  }

  void login(String name) {
    _isLoggedIn = true;
    _userName = name;
    final settings = HiveService.getSettingsBox();
    settings.put('isLoggedIn', true);
    settings.put('userName', name);
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    HiveService.getSettingsBox().put('isLoggedIn', false);
    notifyListeners();
  }

  void setSelectedMonth(DateTime date) {
    _selectedMonth = DateTime(date.year, date.month);
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((tx) =>
      tx.date.year == _selectedMonth.year && tx.date.month == _selectedMonth.month).toList();
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

  Future<void> eraseAllData() async {
    final box = await HiveService.openBox();
    await box.clear();
    _transactions.clear();
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

  void setUserAvatar(String? avatar) {
    _userAvatar = avatar;
    HiveService.getSettingsBox().put('userAvatar', _userAvatar);
    notifyListeners();
  }

  void setFontSizeFactor(double factor) {
    _fontSizeFactor = factor;
    HiveService.getSettingsBox().put('fontSizeFactor', _fontSizeFactor);
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
