import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.loadTransactions(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildHeader(context, provider)),
                        SliverToBoxAdapter(child: _buildBalanceCard(context, provider)),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(child: _buildQuickStats(context, provider)),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(child: _buildSavingsGoal(context, provider)),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(child: _buildChartSection(context, provider)),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(child: _buildRecentHeader(context, provider)),
                        if (provider.filteredTransactions.isEmpty)
                          SliverToBoxAdapter(child: _buildEmpty(context))
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildTxItem(context, provider.filteredTransactions[i]),
                              ),
                              childCount: provider.filteredTransactions.take(5).length,
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: cs.surface,
                  backgroundImage: provider.userAvatar != null
                      ? (provider.userAvatar!.startsWith('assets')
                          ? AssetImage(provider.userAvatar!) as ImageProvider
                          : NetworkImage(provider.userAvatar!))
                      : null,
                  child: provider.userAvatar == null ? Icon(Icons.person_rounded, size: 24, color: cs.primary) : null,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                  Text(
                    provider.userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => provider.loadTransactions(),
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
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM yyyy').format(provider.selectedMonth),
                style: Theme.of(context).textTheme.titleSmall,
              ),
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

  Widget _buildBalanceCard(BuildContext context, TransactionProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final textMuted = isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant;
    final dividerColor = isDark ? Colors.white.withAlpha(38) : Theme.of(context).colorScheme.outline.withAlpha(50);
    final circleColor = isDark ? Colors.white : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GlassCard(
        opacity: isDark ? 0.08 : 0.05,
        padding: const EdgeInsets.all(28),
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(right: -10, top: -20, child: _circle(80, 0.08, circleColor)),
            Positioned(right: 50, bottom: -30, child: _circle(100, 0.05, circleColor)),
            Positioned(left: -20, bottom: -10, child: _circle(60, 0.06, circleColor)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: dividerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat('MMMM yyyy').format(provider.selectedMonth),
                        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Net Balance', style: TextStyle(color: textMuted, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '₹${_formatNum(provider.currentBalance)}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ).animate().fade(duration: 400.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
                const SizedBox(height: 28),
                Container(
                  height: 1,
                  color: dividerColor,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildMetricChip('Income', provider.totalIncome, Icons.south_west, const Color(0xFF69F0AE), textColor, textMuted)),
                    Container(width: 1, height: 40, color: dividerColor),
                    Expanded(child: _buildMetricChip('Expenses', provider.totalExpenses, Icons.north_east, const Color(0xFFFF6B6B), textColor, textMuted)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, double amount, IconData icon, Color color, Color textColor, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(51), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: textMuted, fontSize: 11)),
              Text('₹${_formatNum(amount)}', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final txCount = provider.filteredTransactions.length;
    final avgSpend = txCount == 0 ? 0.0 : provider.totalExpenses / txCount;
    final largest = provider.filteredTransactions.isEmpty
        ? 0.0
        : provider.filteredTransactions.map((t) => t.amount).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _statCard(context, '₹${_formatNum(avgSpend)}', 'Avg / Txn', Icons.bar_chart_rounded, cs.primary)),
          const SizedBox(width: 12),
          Expanded(child: _statCard(context, '$txCount', 'Transactions', Icons.receipt_long_rounded, const Color(0xFF7C3AED))),
          const SizedBox(width: 12),
          Expanded(child: _statCard(context, '₹${_formatNum(largest)}', 'Largest', Icons.trending_up_rounded, const Color(0xFFEA580C))),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSavingsGoal(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final pct = provider.savingsProgress.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.amber.withAlpha(38), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.savings_outlined, color: Colors.amber, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Savings Goal', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${_formatNum(provider.currentBalance.clamp(0, double.infinity))}', style: Theme.of(context).textTheme.bodySmall),
                Text('₹${_formatNum(provider.savingsGoal)}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final spending = provider.last7DaysSpending;
    final maxSpending = spending.isEmpty ? 100.0 : spending.reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxSpending == 0 ? 100.0 : maxSpending * 1.3;

    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date).substring(0, 2);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Spending', style: Theme.of(context).textTheme.titleSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Last 7 days', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: chartMaxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: cs.surfaceContainerHighest,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) => LineTooltipItem(
                          '₹${spot.y.toStringAsFixed(0)}',
                          TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 12),
                        )).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(dayLabels[idx], style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: cs.outline.withAlpha(50), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(7, (i) => FlSpot(i.toDouble(), spending[i])),
                      isCurved: true,
                      gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      shadow: Shadow(color: cs.secondary.withAlpha(150), blurRadius: 10, offset: const Offset(0, 4)),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [cs.primary.withAlpha(80), cs.secondary.withAlpha(10)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context, TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Recent Transactions', style: Theme.of(context).textTheme.titleSmall),
          if (provider.filteredTransactions.length > 5)
            Text('See all', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTxItem(BuildContext context, TransactionModel tx) {
    final cs = Theme.of(context).colorScheme;
    final isIncome = tx.type == TransactionType.income;
    final amtColor = isIncome ? const Color(0xFF22C55E) : cs.error;
    final iconColor = isIncome ? const Color(0xFF22C55E) : cs.error;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withAlpha(26), shape: BoxShape.circle),
            child: Icon(isIncome ? Icons.south_west_rounded : Icons.north_east_rounded, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.category, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(DateFormat('dd MMM yyyy').format(tx.date), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}₹${_formatNum(tx.amount)}',
            style: TextStyle(color: amtColor, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No transactions this month', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha((opacity * 255).toInt())),
      );

  static String _formatNum(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
