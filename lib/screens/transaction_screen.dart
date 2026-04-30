import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/glass_card.dart';
import '../widgets/export_sheet.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _searchQuery = '';
  TransactionType? _filterType;
  String? _filterCategory;
  DateTimeRange? _dateRange;
  double? _minAmount;
  double? _maxAmount;

  static String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  int get _activeFilterCount {
    int c = 0;
    if (_filterType != null) c++;
    if (_filterCategory != null) c++;
    if (_dateRange != null) c++;
    if (_minAmount != null || _maxAmount != null) c++;
    return c;
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> base) {
    return base.where((tx) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          tx.category.toLowerCase().contains(q) ||
          tx.notes.toLowerCase().contains(q);
      final matchType = _filterType == null || tx.type == _filterType;
      final matchCat = _filterCategory == null || tx.category == _filterCategory;
      final matchDate = _dateRange == null ||
          (!tx.date.isBefore(_dateRange!.start) &&
              !tx.date.isAfter(_dateRange!.end.add(const Duration(days: 1))));
      final matchMin = _minAmount == null || tx.amount >= _minAmount!;
      final matchMax = _maxAmount == null || tx.amount <= _maxAmount!;
      return matchSearch && matchType && matchCat && matchDate && matchMin && matchMax;
    }).toList();
  }

  void _clearFilters() => setState(() {
        _filterType = null;
        _filterCategory = null;
        _dateRange = null;
        _minAmount = null;
        _maxAmount = null;
        _searchQuery = '';
      });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final cs = Theme.of(context).colorScheme;
    final filtered = _applyFilters(provider.filteredTransactions);

    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in filtered) {
      final key = DateFormat('dd MMM yyyy').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transactions', style: Theme.of(context).textTheme.headlineSmall),
                  Row(
                    children: [
                      // PDF Export
                      IconButton(
                        icon: Icon(Icons.picture_as_pdf_rounded, color: cs.primary, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.primary.withAlpha(20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        tooltip: 'Export PDF',
                        onPressed: () => showExportSheet(context),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => provider.setSelectedMonth(
                          DateTime(provider.selectedMonth.year, provider.selectedMonth.month - 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(DateFormat('MMM yy').format(provider.selectedMonth),
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => provider.setSelectedMonth(
                          DateTime(provider.selectedMonth.year, provider.selectedMonth.month + 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Summary Strip ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSummaryStrip(context, provider),
            ),
            const SizedBox(height: 16),

            // ─── Search ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search by category or note…',
                        prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Advanced filter button with badge
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.tune_rounded,
                            color: _activeFilterCount > 0 ? cs.primary : cs.onSurfaceVariant),
                        style: IconButton.styleFrom(
                          backgroundColor: _activeFilterCount > 0
                              ? cs.primary.withAlpha(26)
                              : cs.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showAdvancedFilters(context, provider),
                      ),
                      if (_activeFilterCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                            child: Center(
                              child: Text('$_activeFilterCount',
                                  style: TextStyle(
                                      color: cs.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ─── Active Filter Chips ─────────────────────────────────
            if (_activeFilterCount > 0)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (_filterType != null)
                      _filterChip(context, _filterType == TransactionType.income ? 'Income' : 'Expense',
                          () => setState(() => _filterType = null)),
                    if (_filterCategory != null)
                      _filterChip(context, _filterCategory!,
                          () => setState(() => _filterCategory = null)),
                    if (_dateRange != null)
                      _filterChip(
                          context,
                          '${DateFormat('dd MMM').format(_dateRange!.start)} – ${DateFormat('dd MMM').format(_dateRange!.end)}',
                          () => setState(() => _dateRange = null)),
                    if (_minAmount != null || _maxAmount != null)
                      _filterChip(
                          context,
                          '₹${_minAmount?.toStringAsFixed(0) ?? '0'} – ₹${_maxAmount?.toStringAsFixed(0) ?? '∞'}',
                          () => setState(() {
                                _minAmount = null;
                                _maxAmount = null;
                              })),
                    _filterChip(context, 'Clear all', _clearFilters, isClear: true),
                  ],
                ),
              ),
            if (_activeFilterCount > 0) const SizedBox(height: 8),

            // ─── Type Filter Chips ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _chip(context, 'All', null, Icons.layers_rounded),
                  const SizedBox(width: 8),
                  _chip(context, 'Income', TransactionType.income, Icons.south_west_rounded),
                  const SizedBox(width: 8),
                  _chip(context, 'Expense', TransactionType.expense, Icons.north_east_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── List ────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty(context)
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                      itemCount: grouped.length,
                      itemBuilder: (ctx, i) {
                        final dateKey = grouped.keys.toList()[i];
                        final txList = grouped[dateKey]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, top: 4),
                              child: Text(
                                _formatDateKey(dateKey),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            ...txList.map((tx) => _buildTxCard(context, tx, provider)),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minCtrl = TextEditingController(text: _minAmount?.toStringAsFixed(0) ?? '');
    final maxCtrl = TextEditingController(text: _maxAmount?.toStringAsFixed(0) ?? '');
    DateTimeRange? tempRange = _dateRange;
    String? tempCat = _filterCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.primary.withAlpha(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.tune_rounded, color: cs.primary, size: 20),
                  const SizedBox(width: 10),
                  Text('Advanced Filters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 20),

              // Date Range
              Text('Date Range', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: ctx,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                    initialDateRange: tempRange,
                    builder: (ctx2, child) => Theme(
                      data: Theme.of(context),
                      child: child!,
                    ),
                  );
                  if (picked != null) setSheetState(() => tempRange = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range_rounded, color: cs.onSurfaceVariant, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        tempRange == null
                            ? 'Select date range'
                            : '${DateFormat('dd MMM yyyy').format(tempRange!.start)}  →  ${DateFormat('dd MMM yyyy').format(tempRange!.end)}',
                        style: TextStyle(
                          color: tempRange == null ? cs.onSurfaceVariant : cs.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (tempRange != null)
                        GestureDetector(
                          onTap: () => setSheetState(() => tempRange = null),
                          child: Icon(Icons.clear, size: 16, color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              Text('Category', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: tempCat,
                    hint: Text('All categories', style: TextStyle(color: cs.onSurfaceVariant)),
                    dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All categories',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      ...categories.map((cat) => DropdownMenuItem<String?>(
                            value: cat.name,
                            child: Row(
                              children: [
                                Icon(cat.icon, color: cat.color, size: 16),
                                const SizedBox(width: 8),
                                Text(cat.name, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          )),
                    ],
                    onChanged: (val) => setSheetState(() => tempCat = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount Range
              Text('Amount Range (₹)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Min', prefixText: '₹ '),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('–', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Max', prefixText: '₹ '),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearFilters();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dateRange = tempRange;
                          _filterCategory = tempCat;
                          _minAmount = double.tryParse(minCtrl.text);
                          _maxAmount = double.tryParse(maxCtrl.text);
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, VoidCallback onRemove,
      {bool isClear = false}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isClear ? cs.error.withAlpha(20) : cs.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isClear ? cs.error.withAlpha(80) : cs.primary.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isClear ? cs.error : cs.primary)),
              const SizedBox(width: 4),
              Icon(Icons.close_rounded, size: 14, color: isClear ? cs.error : cs.primary),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateKey(String key) {
    final now = DateTime.now();
    if (DateFormat('dd MMM yyyy').format(now) == key) return 'Today';
    if (DateFormat('dd MMM yyyy').format(now.subtract(const Duration(days: 1))) == key) return 'Yesterday';
    return key;
  }

  Widget _buildSummaryStrip(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Expanded(child: _strip(context, 'Income', '₹${_fmt(provider.totalIncome)}', const Color(0xFF22C55E))),
          Container(width: 1, height: 36, color: cs.outline.withAlpha(128)),
          Expanded(child: _strip(context, 'Expenses', '₹${_fmt(provider.totalExpenses)}', cs.error)),
          Container(width: 1, height: 36, color: cs.outline.withAlpha(128)),
          Expanded(child: _strip(context, 'Net', '₹${_fmt(provider.currentBalance.abs())}', cs.primary)),
        ],
      ),
    );
  }

  Widget _strip(BuildContext context, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, TransactionType? type, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final sel = _filterType == type;
    return GestureDetector(
      onTap: () => setState(() => _filterType = sel ? null : type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: sel ? cs.onPrimary : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: sel ? cs.onPrimary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTxCard(BuildContext context, TransactionModel tx, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final isIncome = tx.type == TransactionType.income;
    final amtColor = isIncome ? const Color(0xFF22C55E) : cs.error;
    final cat = categories.firstWhere((c) => c.name == tx.category, orElse: () => categories.last);

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E).withAlpha(38),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_rounded, color: Color(0xFF22C55E)),
          SizedBox(width: 6),
          Text('Edit', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cs.error.withAlpha(38),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('Delete', style: TextStyle(color: cs.error, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 6),
          Icon(Icons.delete_outline_rounded, color: cs.error),
        ]),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          showAddTransactionSheet(context, transaction: tx);
          return false;
        }
        return true;
      },
      onDismissed: (_) {
        provider.deleteTransaction(tx.id);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              Icon(Icons.delete_outline_rounded, color: cs.onInverseSurface, size: 18),
              const SizedBox(width: 10),
              const Text('Transaction deleted'),
            ]),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'UNDO', onPressed: () => provider.addTransaction(tx)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => showAddTransactionSheet(context, transaction: tx),
        child: GlassCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: cat.color.withAlpha(31), borderRadius: BorderRadius.circular(12)),
                child: Icon(cat.icon, color: cat.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.category, style: Theme.of(context).textTheme.titleSmall),
                    if (tx.notes.isNotEmpty)
                      Text(tx.notes,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${isIncome ? '+' : '-'}₹${_fmt(tx.amount)}',
                      style: TextStyle(color: amtColor, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(DateFormat('hh:mm a').format(tx.date),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No transactions found',
                style: Theme.of(context).textTheme.bodyMedium),
            if (_activeFilterCount > 0) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('Clear filters'),
                onPressed: _clearFilters,
              ),
            ],
          ],
        ),
      );
}
