import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../widgets/budget_limit_sheet.dart';
import '../widgets/glass_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  static String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final warnings = provider.budgetWarnings;

        // All expense categories
        final expenseCategories = categories
            .where((c) => !['Salary', 'Investment', 'Gift'].contains(c.name))
            .toList();

        return Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Budget Limits',
                                style: Theme.of(context).textTheme.headlineSmall),
                            Text(
                              DateFormat('MMMM yyyy').format(provider.selectedMonth),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Warning Banner ────────────────────────────────────────
                if (warnings.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _WarningBanner(warnings: warnings),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Summary Strip ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    borderRadius: BorderRadius.circular(18),
                    child: Row(
                      children: [
                        Expanded(
                          child: _summaryTile(
                            context,
                            label: 'Limits Set',
                            value: '${provider.budgetLimits.length}',
                            color: cs.primary,
                            icon: Icons.shield_outlined,
                          ),
                        ),
                        Container(width: 1, height: 36, color: cs.outline.withAlpha(80)),
                        Expanded(
                          child: _summaryTile(
                            context,
                            label: 'Over Budget',
                            value: '${warnings.where((w) => (w['pct'] as double) >= 1.0).length}',
                            color: cs.error,
                            icon: Icons.warning_amber_rounded,
                          ),
                        ),
                        Container(width: 1, height: 36, color: cs.outline.withAlpha(80)),
                        Expanded(
                          child: _summaryTile(
                            context,
                            label: 'Near Limit',
                            value: '${warnings.where((w) => (w['pct'] as double) < 1.0).length}',
                            color: Colors.amber[700]!,
                            icon: Icons.info_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Category List ─────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: expenseCategories.length,
                    itemBuilder: (ctx, i) {
                      final cat = expenseCategories[i];
                      final limit = provider.getBudgetLimit(cat.name);
                      final used = provider.getBudgetUsed(cat.name);
                      final hasLimit = limit > 0;
                      final pct = hasLimit ? (used / limit).clamp(0.0, 1.0) : 0.0;

                      Color barColor;
                      if (!hasLimit) {
                        barColor = cs.onSurfaceVariant.withAlpha(60);
                      } else if (pct >= 1.0) {
                        barColor = cs.error;
                      } else if (pct >= 0.8) {
                        barColor = Colors.amber[700]!;
                      } else {
                        barColor = const Color(0xFF22C55E);
                      }

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => showBudgetLimitSheet(context, preselectedCategory: cat.name),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cat.color.withAlpha(40),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(cat.icon, color: cat.color, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cat.name,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                          hasLimit
                                              ? '₹${_fmt(used)} of ₹${_fmt(limit)}'
                                              : 'No limit set • ₹${_fmt(used)} spent',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Badge
                                  if (hasLimit)
                                    _budgetBadge(context, pct, isDark)
                                  else
                                    Icon(Icons.add_circle_outline_rounded,
                                        size: 20, color: cs.onSurfaceVariant.withAlpha(120)),
                                ],
                              ),
                              if (hasLimit) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: pct),
                                    duration: const Duration(milliseconds: 700),
                                    curve: Curves.easeOutCubic,
                                    builder: (_, val, __) => LinearProgressIndicator(
                                      value: val,
                                      minHeight: 7,
                                      backgroundColor: cs.surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryTile(BuildContext context,
      {required String label, required String value, required Color color, required IconData icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
        Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _budgetBadge(BuildContext context, double pct, bool isDark) {
    Color bg;
    Color fg;
    String label;
    if (pct >= 1.0) {
      bg = Theme.of(context).colorScheme.error.withAlpha(30);
      fg = Theme.of(context).colorScheme.error;
      label = 'Over';
    } else if (pct >= 0.8) {
      bg = Colors.amber.withAlpha(30);
      fg = Colors.amber[800]!;
      label = '${(pct * 100).toStringAsFixed(0)}%';
    } else {
      bg = const Color(0xFF22C55E).withAlpha(30);
      fg = const Color(0xFF22C55E);
      label = '${(pct * 100).toStringAsFixed(0)}%';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final List<Map<String, dynamic>> warnings;
  const _WarningBanner({required this.warnings});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final overCount = warnings.where((w) => (w['pct'] as double) >= 1.0).length;
    final nearCount = warnings.where((w) => (w['pct'] as double) < 1.0).length;

    final isOver = overCount > 0;
    final bannerColor = isOver ? cs.error : Colors.amber[700]!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bannerColor.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(
            isOver ? Icons.warning_rounded : Icons.info_outline_rounded,
            color: bannerColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isOver
                  ? '$overCount ${overCount == 1 ? 'category' : 'categories'} over budget'
                      '${nearCount > 0 ? ', $nearCount near limit' : ''}'
                  : '$nearCount ${nearCount == 1 ? 'category' : 'categories'} approaching limit',
              style: TextStyle(
                color: bannerColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
