import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final breakdown = provider.categoryBreakdown;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildMonthSelector(context, provider),
          ),
        ),
      ),
      body: breakdown.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No expense data for this month'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expense Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: breakdown.entries.map((e) {
                          final category = categories.firstWhere((c) => c.name == e.key,
                              orElse: () => categories.last);
                          return PieChartSectionData(
                            color: category.color,
                            value: e.value,
                            title: '${(e.value / (provider.totalExpenses == 0 ? 1 : provider.totalExpenses) * 100).toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Category Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...breakdown.entries.map((e) {
                    final category = categories.firstWhere((c) => c.name == e.key,
                        orElse: () => categories.last);
                    return ListTile(
                      leading: Icon(category.icon, color: category.color),
                      title: Text(e.key),
                      trailing: Text('₹${e.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: LinearProgressIndicator(
                        value: provider.totalExpenses == 0 ? 0 : e.value / provider.totalExpenses,
                        backgroundColor: Colors.grey[200],
                        color: category.color,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              provider.setSelectedMonth(
                DateTime(provider.selectedMonth.year, provider.selectedMonth.month - 1),
              );
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(provider.selectedMonth),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              provider.setSelectedMonth(
                DateTime(provider.selectedMonth.year, provider.selectedMonth.month + 1),
              );
            },
          ),
        ],
      ),
    );
  }
}
