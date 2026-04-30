import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/investment_model.dart';
import '../widgets/add_investment_sheet.dart';
import '../widgets/glass_card.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key});

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
        final investments = provider.investments;
        final total = provider.totalInvested;

        // Breakdown by type
        final breakdown = <InvestmentType, double>{};
        for (var inv in investments) {
          breakdown[inv.type] = (breakdown[inv.type] ?? 0) + inv.amount;
        }

        return Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: Column(
              children: [
                // ─── Header ───────────────────────────────────────────────
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
                            Text('Investment Tracker',
                                style: Theme.of(context).textTheme.headlineSmall),
                            Text('Manage your wealth',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Summary Card ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Invested',
                            style: TextStyle(color: cs.onPrimary.withAlpha(180), fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('₹${_fmt(total)}',
                            style: TextStyle(color: cs.onPrimary, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _miniStat('Count', '${investments.length}', cs.onPrimary),
                            const SizedBox(width: 24),
                            _miniStat('Latest', investments.isNotEmpty ? DateFormat('dd MMM').format(investments.first.date) : '-', cs.onPrimary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Type Breakdown Chips ──────────────────────────────────
                if (breakdown.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: investmentTypes.where((t) => breakdown.containsKey(t.type)).map((t) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: t.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: t.color.withAlpha(60)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(t.icon, color: t.color, size: 14),
                                  const SizedBox(width: 6),
                                  Text(t.name, style: TextStyle(color: t.color, fontWeight: FontWeight.w700, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('₹${_fmt(breakdown[t.type]!)}', style: Theme.of(context).textTheme.titleSmall),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 10),

                // ─── List ──────────────────────────────────────────────────
                Expanded(
                  child: investments.isEmpty
                      ? _buildEmpty(context)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: investments.length,
                          itemBuilder: (ctx, i) {
                            final inv = investments[i];
                            final typeData = investmentTypes.firstWhere((t) => t.type == inv.type);
                            return GlassCard(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                onTap: () => showAddInvestmentSheet(context, investment: inv),
                                borderRadius: BorderRadius.circular(18),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: typeData.color.withAlpha(30),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(typeData.icon, color: typeData.color, size: 22),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(inv.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                          Text('${typeData.name} • ${DateFormat('dd MMM yyyy').format(inv.date)}', 
                                            style: Theme.of(context).textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                    Text('₹${_fmt(inv.amount)}',
                                        style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800, fontSize: 16)),
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddInvestmentSheet(context),
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Investment', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color.withAlpha(150), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100)),
          const SizedBox(height: 16),
          Text('No investments tracked yet', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Start building your wealth today', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
