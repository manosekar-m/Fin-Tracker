import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final breakdown = provider.categoryBreakdown;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights', style: TextStyle(fontWeight: FontWeight.bold))),
      body: breakdown.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No expense data to analyze'),
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
                            title: '${(e.value / provider.totalExpenses * 100).toStringAsFixed(0)}%',
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
                        value: e.value / provider.totalExpenses,
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
}
