import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final filteredTransactions = provider.transactions.where((tx) {
      final matchesSearch = tx.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (tx.notes ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == null || tx.type == _filterType;
      return matchesSearch && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _filterChip('All', null),
                    const SizedBox(width: 8),
                    _filterChip('Income', TransactionType.income),
                    const SizedBox(width: 8),
                    _filterChip('Expense', TransactionType.expense),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: filteredTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No transactions found'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                return _buildTransactionCard(context, tx, provider);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String label, TransactionType? type) {
    final isSelected = _filterType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = selected ? type : null);
      },
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionModel tx, TransactionProvider provider) {
    final isIncome = tx.type == TransactionType.income;
    return Dismissible(
      key: Key(tx.id),
      // Allow swiping in both directions
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe Right (Start to End) -> Edit
          showAddTransactionSheet(context, transaction: tx);
          return false; // Don't dismiss the item
        } else {
          // Swipe Left (End to Start) -> Delete
          return true; // Confirm dismissal for deletion
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          provider.deleteTransaction(tx.id);
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          onLongPress: () => showAddTransactionSheet(context, transaction: tx),
          leading: CircleAvatar(
            backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(tx.date.toString().split(' ')[0]),
          trailing: Text(
            '${isIncome ? '+' : '-'} ₹${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
