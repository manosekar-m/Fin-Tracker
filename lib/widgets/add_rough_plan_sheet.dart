import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rough_plan_model.dart';
import '../providers/transaction_provider.dart';
import 'dart:ui';
import 'package:uuid/uuid.dart';

class AddRoughPlanSheet extends StatefulWidget {
  final RoughPlanModel? existingPlan;
  const AddRoughPlanSheet({super.key, this.existingPlan});

  @override
  State<AddRoughPlanSheet> createState() => _AddRoughPlanSheetState();
}

class _AddRoughPlanSheetState extends State<AddRoughPlanSheet> {
  final _titleCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingPlan != null) {
      _titleCtrl.text = widget.existingPlan!.title;
      _budgetCtrl.text = widget.existingPlan!.budget > 0 ? widget.existingPlan!.budget.toStringAsFixed(0) : '';
      _notesCtrl.text = widget.existingPlan!.notes;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _budgetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0.0;
    
    if (widget.existingPlan == null) {
      provider.addRoughPlan(RoughPlanModel(
        id: const Uuid().v4(),
        title: title,
        budget: budget,
        notes: _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      ));
    } else {
      provider.updateRoughPlan(RoughPlanModel(
        id: widget.existingPlan!.id,
        title: title,
        budget: budget,
        notes: _notesCtrl.text.trim(),
        createdAt: widget.existingPlan!.createdAt,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B1426).withAlpha(180) : Colors.white.withAlpha(220),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: cs.onSurfaceVariant.withAlpha(60), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.existingPlan == null ? 'New Rough Plan' : 'Edit Plan', style: Theme.of(context).textTheme.headlineSmall),
                  if (widget.existingPlan != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                      onPressed: () {
                        Provider.of<TransactionProvider>(context, listen: false)
                            .deleteRoughPlan(widget.existingPlan!.id);
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Plan deleted'),
                            duration: const Duration(seconds: 5),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Plan Title',
                  hintText: 'e.g. Goa Trip, New Phone...',
                  prefixIcon: Icon(Icons.title_rounded, color: cs.primary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimated Budget (Optional)',
                  hintText: '0',
                  prefixIcon: Icon(Icons.currency_rupee_rounded, color: cs.primary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add details here...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded, color: cs.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: Add an amount at the end of a line (e.g., "Food 200") to track spending within this plan.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: cs.onSurfaceVariant.withAlpha(150)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(widget.existingPlan == null ? 'CREATE PLAN' : 'UPDATE PLAN', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAddRoughPlanSheet(BuildContext context, {RoughPlanModel? plan}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AddRoughPlanSheet(existingPlan: plan),
  );
}
