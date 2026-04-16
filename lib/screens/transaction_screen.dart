import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/add_transaction_sheet.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _searchQuery = '';
  TransactionType? _filterType;

  static String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final cs = Theme.of(context).colorScheme;
    final filtered = provider.filteredTransactions.where((tx) {
      final matchSearch = tx.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.notes.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchType = _filterType == null || tx.type == _filterType;
      return matchSearch && matchType;
    }).toList();

    // Group by date
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
            // ─── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transactions', style: Theme.of(context).textTheme.headlineSmall),
                  Row(
                    children: [
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
                      Text(DateFormat('MMM yy').format(provider.selectedMonth), style: Theme.of(context).textTheme.titleSmall),
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

            // ─── Summary Strip ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSummaryStrip(context, provider),
            ),
            const SizedBox(height: 16),

            // ─── Search ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
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
            const SizedBox(height: 12),

            // ─── Filter Chips ────────────────────────────────────────────────
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

            // ─── List ────────────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
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

  String _formatDateKey(String key) {
    final now = DateTime.now();
    if (DateFormat('dd MMM yyyy').format(now) == key) return 'Today';
    if (DateFormat('dd MMM yyyy').format(now.subtract(const Duration(days: 1))) == key) return 'Yesterday';
    return key;
  }

  Widget _buildSummaryStrip(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withAlpha(128)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _strip(context, 'Income', '₹${_fmt(provider.totalIncome)}', const Color(0xFF22C55E)),
          ),
          Container(width: 1, height: 36, color: cs.outline.withAlpha(128)),
          Expanded(
            child: _strip(context, 'Expenses', '₹${_fmt(provider.totalExpenses)}', cs.error),
          ),
          Container(width: 1, height: 36, color: cs.outline.withAlpha(128)),
          Expanded(
            child: _strip(context, 'Net', '₹${_fmt(provider.currentBalance.abs())}', cs.primary),
          ),
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
            Text(
              label,
              style: TextStyle(color: sel ? cs.onPrimary : cs.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13),
            ),
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
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: cs.error.withAlpha(38), borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_outline_rounded, color: cs.error),
      ),
      confirmDismiss: (dir) async => dir == DismissDirection.endToStart,
      onDismissed: (_) => provider.deleteTransaction(tx.id),
      child: GestureDetector(
        onTap: () => showAddTransactionSheet(context, transaction: tx),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withAlpha(128)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: cat.color.withAlpha(31), borderRadius: BorderRadius.circular(12)),
                child: Icon(cat.icon, color: cat.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.category, style: Theme.of(context).textTheme.titleSmall),
                    if (tx.notes.isNotEmpty)
                      Text(tx.notes, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}₹${_fmt(tx.amount)}',
                    style: TextStyle(color: amtColor, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(DateFormat('hh:mm a').format(tx.date), style: Theme.of(context).textTheme.bodySmall),
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
            Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No transactions found', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}
