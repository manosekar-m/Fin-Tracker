import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

class AddTransactionSheet extends StatefulWidget {
  final TransactionModel? existingTransaction;

  const AddTransactionSheet({super.key, this.existingTransaction});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  late TransactionType _type;
  late String _category;
  late String _notes;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;
    _amount = tx?.amount ?? 0;
    _type = tx?.type ?? TransactionType.expense;
    _category = tx?.category ?? 'Food';
    _notes = tx?.notes ?? '';
    _date = tx?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existingTransaction == null ? 'Add Transaction' : 'Edit Transaction',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.upload)),
                  ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.download)),
                ],
                selected: {_type},
                onSelectionChanged: (val) => setState(() => _type = val.first),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _amount == 0 ? '' : _amount.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || double.tryParse(val) == null) ? 'Enter valid amount' : null,
                onSaved: (val) => _amount = double.parse(val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _notes = val ?? '',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(_date.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final provider = Provider.of<TransactionProvider>(context, listen: false);
                    
                    if (widget.existingTransaction == null) {
                      provider.addTransaction(TransactionModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        amount: _amount,
                        type: _type,
                        category: _category,
                        date: _date,
                        notes: _notes,
                      ));
                    } else {
                      provider.updateTransaction(TransactionModel(
                        id: widget.existingTransaction!.id,
                        amount: _amount,
                        type: _type,
                        category: _category,
                        date: _date,
                        notes: _notes,
                      ));
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.existingTransaction == null ? 'Save Transaction' : 'Update Transaction'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

void showAddTransactionSheet(BuildContext context, {TransactionModel? transaction}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => AddTransactionSheet(existingTransaction: transaction),
  );
}
