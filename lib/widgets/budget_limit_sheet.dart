import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

void showBudgetLimitSheet(BuildContext context, {String? preselectedCategory}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BudgetLimitSheet(preselectedCategory: preselectedCategory),
  );
}

class _BudgetLimitSheet extends StatefulWidget {
  final String? preselectedCategory;
  const _BudgetLimitSheet({this.preselectedCategory});

  @override
  State<_BudgetLimitSheet> createState() => _BudgetLimitSheetState();
}

class _BudgetLimitSheetState extends State<_BudgetLimitSheet> {
  late String? _selectedCategory;
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Only expense categories
  static final _expenseCategories = categories
      .where((c) => !['Salary', 'Investment', 'Gift'].contains(c.name))
      .toList();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory;
    if (_selectedCategory != null) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final existing = provider.getBudgetLimit(_selectedCategory!);
      if (existing > 0) _amountCtrl.text = existing.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.primary.withAlpha(40)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shield_outlined, color: cs.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Set Budget Limit',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 24),

            // Category picker
            Text('Category', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  hint: Text('Select a category', style: TextStyle(color: cs.onSurfaceVariant)),
                  dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  items: _expenseCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.name,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cat.color.withAlpha(40),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Text(cat.name, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Amount input
            Text('Monthly Limit (₹)', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'e.g. 3000',
                prefixIcon: Icon(Icons.currency_rupee_rounded, color: cs.onSurfaceVariant, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter an amount';
                if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (_selectedCategory != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(color: cs.error.withAlpha(100)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Provider.of<TransactionProvider>(context, listen: false)
                            .removeBudgetLimit(_selectedCategory!);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                if (_selectedCategory != null) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Save Limit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (_selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a category')),
                        );
                        return;
                      }
                      if (!_formKey.currentState!.validate()) return;
                      Provider.of<TransactionProvider>(context, listen: false)
                          .setBudgetLimit(_selectedCategory!, double.parse(_amountCtrl.text));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
