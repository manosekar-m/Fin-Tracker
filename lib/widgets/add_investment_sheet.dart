import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/investment_model.dart';
import '../providers/transaction_provider.dart';
import 'package:uuid/uuid.dart';

void showAddInvestmentSheet(BuildContext context, {InvestmentModel? investment}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddInvestmentSheet(investment: investment),
  );
}

class _AddInvestmentSheet extends StatefulWidget {
  final InvestmentModel? investment;
  const _AddInvestmentSheet({this.investment});

  @override
  State<_AddInvestmentSheet> createState() => _AddInvestmentSheetState();
}

class _AddInvestmentSheetState extends State<_AddInvestmentSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late InvestmentType _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.investment?.title ?? '');
    _amountController = TextEditingController(text: widget.investment?.amount.toString() ?? '');
    _notesController = TextEditingController(text: widget.investment?.notes ?? '');
    _selectedDate = widget.investment?.date ?? DateTime.now();
    _selectedType = widget.investment?.type ?? InvestmentType.sip;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
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
            Text(
              widget.investment == null ? 'New Investment' : 'Edit Investment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Investment Name', hintText: 'e.g. HDFC Nifty 50 Index Fund'),
              validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount Invested', prefixText: '₹ '),
              validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
            ),
            const SizedBox(height: 16),

            // Type Picker
            Text('Investment Type', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: investmentTypes.map((t) {
                  final sel = _selectedType == t.type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t.name),
                      selected: sel,
                      onSelected: (val) => setState(() => _selectedType = t.type),
                      avatar: Icon(t.icon, size: 16, color: sel ? Colors.white : t.color),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 20, color: cs.primary),
                    const SizedBox(width: 12),
                    Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                if (widget.investment != null)
                  IconButton(
                    onPressed: () {
                      Provider.of<TransactionProvider>(context, listen: false).deleteInvestment(widget.investment!.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    style: IconButton.styleFrom(backgroundColor: Colors.red.withAlpha(20)),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(widget.investment == null ? 'Track Investment' : 'Update Investment'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final inv = InvestmentModel(
        id: widget.investment?.id ?? const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: _selectedType,
        notes: _notesController.text,
      );

      if (widget.investment == null) {
        provider.addInvestment(inv);
      } else {
        provider.updateInvestment(inv);
      }
      Navigator.pop(context);
    }
  }
}
