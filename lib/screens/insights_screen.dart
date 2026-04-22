import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final cs = Theme.of(context).colorScheme;
    final breakdown = provider.categoryBreakdown;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, provider)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (breakdown.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty(context))
            else ...[
              SliverToBoxAdapter(child: _buildDonutSection(context, provider, breakdown)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Category Breakdown', style: Theme.of(context).textTheme.titleSmall),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final entry = breakdown.entries.toList()[i];
                    final category = categories.firstWhere((c) => c.name == entry.key, orElse: () => categories.last);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: _buildCategoryCard(context, provider, entry.key, entry.value, category),
                    );
                  },
                  childCount: breakdown.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Insights', style: Theme.of(context).textTheme.headlineSmall),
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
              const SizedBox(width: 8),
              Text(DateFormat('MMM yy').format(provider.selectedMonth), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: 8),
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
    );
  }

  Widget _buildDonutSection(BuildContext context, TransactionProvider provider, Map<String, double> breakdown) {
    final cs = Theme.of(context).colorScheme;
    final total = provider.totalExpenses;
    final sections = breakdown.entries.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Expenses', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '₹${total >= 1000 ? '${(total / 1000).toStringAsFixed(1)}K' : total.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: cs.primary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: sections.asMap().entries.map((e) {
                    final cat = categories.firstWhere((c) => c.name == e.value.key, orElse: () => categories.last);
                    final isTouched = _touchedIndex == e.key;
                    return PieChartSectionData(
                      color: cat.color,
                      value: e.value.value,
                      title: isTouched ? '${(e.value.value / total * 100).toStringAsFixed(1)}%' : '',
                      radius: isTouched ? 70 : 56,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    );
                  }).toList(),
                  sectionsSpace: 3,
                  centerSpaceRadius: 52,
                  centerSpaceColor: cs.surface,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: sections.map((e) {
                final cat = categories.firstWhere((c) => c.name == e.key, orElse: () => categories.last);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(e.key, style: Theme.of(context).textTheme.bodySmall),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, TransactionProvider provider, String name, double value, CategoryModel category) {
    final cs = Theme.of(context).colorScheme;
    final pct = provider.totalExpenses == 0 ? 0.0 : value / provider.totalExpenses;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: category.color.withAlpha(31), borderRadius: BorderRadius.circular(12)),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${value.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text('${(pct * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(category.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Icon(Icons.pie_chart_outline_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('No expense data this month', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
}
