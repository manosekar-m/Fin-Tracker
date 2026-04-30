import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';
import '../models/rough_plan_model.dart';
import '../models/investment_model.dart';
import '../services/sync_service.dart';


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
  bool _isRoughPlansEnabled = false;
  List<RoughPlanModel> _roughPlans = [];
  bool _isBudgetBreakdownEnabled = true;
  List<InvestmentModel> _investments = [];
  bool _isLocked = false;



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
  bool get isRoughPlansEnabled => _isRoughPlansEnabled;
  List<RoughPlanModel> get roughPlans => _roughPlans;
  bool get isBudgetBreakdownEnabled => _isBudgetBreakdownEnabled;
  List<InvestmentModel> get investments => _investments;
  bool get isLocked => _isLocked;



  // ─── Budget Limits ──────────────────────────────────────────────
  Map<String, double> _budgetLimits = {};
  Map<String, double> get budgetLimits => Map.unmodifiable(_budgetLimits);

  double getBudgetLimit(String category) => _budgetLimits[category] ?? 0.0;

  double getBudgetUsed(String category) {
    return _transactions
        .where((tx) =>
            tx.type == TransactionType.expense &&
            tx.category == category &&
            tx.date.year == _selectedMonth.year &&
            tx.date.month == _selectedMonth.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Returns all categories with a limit that are >=80% used this month.
  List<Map<String, dynamic>> get budgetWarnings {
    final warnings = <Map<String, dynamic>>[];
    for (final entry in _budgetLimits.entries) {
      if (entry.value <= 0) continue;
      final used = getBudgetUsed(entry.key);
      final pct = used / entry.value;
      if (pct >= 0.8) {
        warnings.add({
          'category': entry.key,
          'limit': entry.value,
          'used': used,
          'pct': pct,
        });
      }
    }
    return warnings;
  }

  void setBudgetLimit(String category, double amount) {
    _budgetLimits[category] = amount;
    _saveBudgetLimits();
    notifyListeners();
  }

  void removeBudgetLimit(String category) {
    _budgetLimits.remove(category);
    _saveBudgetLimits();
    notifyListeners();
  }

  void _saveBudgetLimits() {
    HiveService.getSettingsBox().put('budgetLimits', Map<String, double>.from(_budgetLimits));
  }

  void _loadBudgetLimits() {
    final raw = HiveService.getSettingsBox().get('budgetLimits');
    if (raw != null && raw is Map) {
      _budgetLimits = Map<String, double>.from(
        raw.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      );
    }
  }
  // ────────────────────────────────────────────────────────────────

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
      _isRoughPlansEnabled = settings.get('roughPlansEnabled', defaultValue: false);
      _isBudgetBreakdownEnabled = settings.get('budgetBreakdownEnabled', defaultValue: true);
      _loadBudgetLimits();


      final roughBox = HiveService.getRoughPlansBox();
      _roughPlans = roughBox.values
          .map((e) => RoughPlanModel.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final box = await HiveService.openBox();
      _transactions = box.values
          .map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final invBox = HiveService.getInvestmentsBox();
      _investments = invBox.values
          .map((e) => InvestmentModel.fromMap(Map<String, dynamic>.from(e)))
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
    return _transactions
        .where((tx) =>
            tx.date.year == _selectedMonth.year &&
            tx.date.month == _selectedMonth.month)
        .toList();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final box = await HiveService.openBox();
    await box.put(tx.id, tx.toMap());
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    syncCloud();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final box = await HiveService.openBox();
    await box.put(tx.id, tx.toMap());
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = tx;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
      syncCloud();
    }
  }

  Future<void> deleteTransaction(String id) async {
    final box = await HiveService.openBox();
    await box.delete(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
    syncCloud();
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

  void toggleRoughPlans(bool value) {
    _isRoughPlansEnabled = value;
    HiveService.getSettingsBox().put('roughPlansEnabled', _isRoughPlansEnabled);
    notifyListeners();
  }

  void toggleBudgetBreakdown(bool value) {
    _isBudgetBreakdownEnabled = value;
    HiveService.getSettingsBox().put('budgetBreakdownEnabled', _isBudgetBreakdownEnabled);
    notifyListeners();
  }


  Future<void> addRoughPlan(RoughPlanModel plan) async {
    final box = HiveService.getRoughPlansBox();
    await box.put(plan.id, plan.toMap());
    _roughPlans.insert(0, plan);
    notifyListeners();
  }

  Future<void> updateRoughPlan(RoughPlanModel plan) async {
    final box = HiveService.getRoughPlansBox();
    await box.put(plan.id, plan.toMap());
    final index = _roughPlans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      _roughPlans[index] = plan;
      notifyListeners();
    }
  }

  Future<void> deleteRoughPlan(String id) async {
    final box = HiveService.getRoughPlansBox();
    await box.delete(id);
    _roughPlans.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ─── Investment Methods ──────────────────────────────────────────
  Future<void> addInvestment(InvestmentModel inv) async {
    final box = HiveService.getInvestmentsBox();
    await box.put(inv.id, inv.toMap());
    _investments.insert(0, inv);
    _investments.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> updateInvestment(InvestmentModel inv) async {
    final box = HiveService.getInvestmentsBox();
    await box.put(inv.id, inv.toMap());
    final index = _investments.indexWhere((i) => i.id == inv.id);
    if (index != -1) {
      _investments[index] = inv;
      _investments.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> deleteInvestment(String id) async {
    final box = HiveService.getInvestmentsBox();
    await box.delete(id);
    _investments.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void setLocked(bool value) {
    _isLocked = value;
    notifyListeners();
  }

  Future<void> syncCloud() async {
    try {
      await SyncService.pushToCloud();
    } catch (e) {
      debugPrint('Cloud Sync failed/skipped: $e');
    }
  }

  double get totalInvested => _investments.fold(0.0, (sum, item) => sum + item.amount);


  double get totalIncome => filteredTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get totalExpenses => filteredTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get currentBalance => totalIncome - totalExpenses;
  double get savingsProgress =>
      _savingsGoal <= 0 ? 0 : (currentBalance / _savingsGoal).clamp(0.0, 1.0);

  List<double> get last7DaysSpending {
    final dailySpending = List.filled(7, 0.0);
    final today = DateUtils.dateOnly(DateTime.now());
    for (var tx in _transactions.where((t) => t.type == TransactionType.expense)) {
      final diff = today.difference(DateUtils.dateOnly(tx.date)).inDays;
      if (diff >= 0 && diff < 7) {
        dailySpending[6 - diff] += tx.amount;
      }
    }
    return dailySpending;
  }

  Map<String, double> get categoryBreakdown {
    final breakdown = <String, double>{};
    for (var tx in filteredTransactions.where((t) => t.type == TransactionType.expense)) {
      breakdown[tx.category] = (breakdown[tx.category] ?? 0) + tx.amount;
    }
    return breakdown;
  }
}
