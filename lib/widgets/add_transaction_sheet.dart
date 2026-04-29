import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import 'dart:ui';

class AddTransactionSheet extends StatefulWidget {
  final TransactionModel? existingTransaction;
  const AddTransactionSheet({super.key, this.existingTransaction});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet>
    with SingleTickerProviderStateMixin {
  final _amountCtrl   = TextEditingController();
  final _notesCtrl    = TextEditingController();
  final _customCatCtrl = TextEditingController();
  late TabController _tabCtrl;

  late TransactionType _type;
  late String _category;
  late DateTime _date;

  bool _isProcessingOcr = false;
  final _ocrService = OCRService();
  final _imagePicker = ImagePicker();

  static const _customKey = '__other__';

  // ─── Preset categories ────────────────────────────────────────────────
  bool get _isOther => _category == _customKey;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final tx = widget.existingTransaction;
    _type     = tx?.type ?? TransactionType.expense;
    _date     = tx?.date ?? DateTime.now();
    _notesCtrl.text = tx?.notes ?? '';

    _tabCtrl.index = _type == TransactionType.expense ? 0 : 1;
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _type = _tabCtrl.index == 0 ? TransactionType.expense : TransactionType.income);
      }
    });

    if (tx != null) {
      _amountCtrl.text = tx.amount == 0 ? '' : tx.amount.toStringAsFixed(0);
      final known = categories.any((c) => c.name == tx.category);
      if (known) {
        _category = tx.category;
      } else {
        _category = _customKey;
        _customCatCtrl.text = tx.category;
      }
    } else {
      _category = categories.first.name;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _customCatCtrl.dispose();
    _tabCtrl.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existingTransaction != null;
    final isExpense = _type == TransactionType.expense;
    final accentColor = isExpense ? const Color(0xFFEF4444) : const Color(0xFF22C55E);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B1426).withAlpha(180) : Colors.white.withAlpha(220),
            border: Border(top: BorderSide(color: Colors.white.withAlpha(isDark ? 20 : 100), width: 1)),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Handle ────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Header Row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  isEdit ? 'Edit Transaction' : 'New Transaction',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (!isEdit) ...[
                  const SizedBox(width: 8),
                  _isProcessingOcr
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: Icon(Icons.document_scanner_outlined, color: cs.primary),
                          style: IconButton.styleFrom(backgroundColor: cs.primary.withAlpha(25)),
                          tooltip: 'Scan Receipt',
                          onPressed: _scanReceipt,
                        ),
                ],
                const Spacer(),
                if (isEdit)
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                    style: IconButton.styleFrom(backgroundColor: cs.error.withAlpha(20)),
                    onPressed: () {
                      final tx = widget.existingTransaction!;
                      Provider.of<TransactionProvider>(context, listen: false)
                          .deleteTransaction(tx.id);
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Transaction deleted'),
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () => Provider.of<TransactionProvider>(context, listen: false).addTransaction(tx),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  )
                else
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Expense / Income Tab Toggle ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabCtrl,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.north_east_rounded, size: 16,
                            color: _type == TransactionType.expense ? const Color(0xFFEF4444) : cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text('Expense',
                            style: TextStyle(color: _type == TransactionType.expense ? const Color(0xFFEF4444) : cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.south_west_rounded, size: 16,
                            color: _type == TransactionType.income ? const Color(0xFF22C55E) : cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text('Income',
                            style: TextStyle(color: _type == TransactionType.income ? const Color(0xFF22C55E) : cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Amount Display (Premium) ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor.withAlpha(25), accentColor.withAlpha(5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accentColor.withAlpha(40)),
              ),
              child: Column(
                children: [
                  Text(
                    _type == TransactionType.expense ? 'You spent' : 'You received',
                    style: TextStyle(color: accentColor.withAlpha(160), fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('₹', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: accentColor)),
                      const SizedBox(width: 8),
                      Text(
                        _amountCtrl.text.isEmpty ? '0' : _amountCtrl.text,
                        style: TextStyle(
                          fontSize: _amountCtrl.text.length > 7 ? 40 : 54,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          letterSpacing: -1,
                        ),
                      ),
                      _Cursor(color: accentColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ─── Scrollable body ────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category Grid ──────────────────────────────────────
                  Text('Category', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...categories.map((cat) => _categoryChip(context, cat.name, cat.icon, cat.color, cs)),
                      // "Other" chip always last
                      _otherChip(context, cs),
                    ],
                  ),

                  // ── Custom category text input ──────────────
                  if (_isOther) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customCatCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Category name',
                        hintText: 'e.g. Gym, Rent…',
                        prefixIcon: Icon(Icons.label_outline_rounded, color: accentColor, size: 18),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Date & Notes Row ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 20, color: accentColor),
                                const SizedBox(width: 10),
                                Text(
                                  _formatDate(_date),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _notesCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Add note…',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Custom Keypad ─────────────────────────────────────────────
          _NumericKeypad(
            accentColor: accentColor,
            onTap: _handleKeyPress,
            onBackspace: _handleBackspace,
            onSave: _save,
            saveLabel: isEdit ? 'UPDATE TRANSACTION' : 'SAVE TRANSACTION',
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _categoryChip(BuildContext context, String name, IconData icon, Color color, ColorScheme cs) {
    final selected = _category == name && !_isOther;
    return GestureDetector(
      onTap: () => setState(() {
        _category = name;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(25) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? color : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otherChip(BuildContext context, ColorScheme cs) {
    final selected = _isOther;
    return GestureDetector(
      onTap: () => setState(() {
        _category = _customKey;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withAlpha(25) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'Other',
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(data: Theme.of(context), child: child!),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(d.year, d.month, d.day);
    if (target == today) return 'Today, ${_monthName(d.month)} ${d.day}';
    if (target == yesterday) return 'Yesterday, ${_monthName(d.month)} ${d.day}';
    return '${_monthName(d.month)} ${d.day}, ${d.year}';
  }

  String _monthName(int m) => const [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ][m - 1];

  void _handleKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == '.') {
        if (!_amountCtrl.text.contains('.')) {
          _amountCtrl.text += '.';
        }
      } else {
        if (_amountCtrl.text.contains('.') && _amountCtrl.text.split('.')[1].length >= 2) {
          return;
        }
        if (_amountCtrl.text == '0') {
          _amountCtrl.text = key;
        } else {
          _amountCtrl.text += key;
        }
      }
    });
  }

  void _handleBackspace() {
    HapticFeedback.selectionClick();
    if (_amountCtrl.text.isNotEmpty) {
      setState(() {
        _amountCtrl.text = _amountCtrl.text.substring(0, _amountCtrl.text.length - 1);
      });
    }
  }

  void _save() {
    final amtText = _amountCtrl.text.trim();
    final amount = double.tryParse(amtText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final resolvedCat = _isOther ? _customCatCtrl.text.trim() : _category;
    if (_isOther && resolvedCat.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a category name'),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    if (widget.existingTransaction == null) {
      provider.addTransaction(TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        type: _type,
        category: resolvedCat,
        date: _date,
        notes: _notesCtrl.text.trim(),
      ));
    } else {
      provider.updateTransaction(TransactionModel(
        id: widget.existingTransaction!.id,
        amount: amount,
        type: _type,
        category: resolvedCat,
        date: _date,
        notes: _notesCtrl.text.trim(),
      ));
    }
    Navigator.pop(context);
  }

  Future<void> _scanReceipt() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan Receipt'),
        content: const Text('Choose an image source to scan your receipt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() => _isProcessingOcr = true);

    try {
      final result = await _ocrService.processImage(pickedFile.path);

      if (!mounted) return;

      setState(() {
        if (result.amount != null) {
          _amountCtrl.text = result.amount!.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
        }
        if (result.date != null) {
          _date = result.date!;
        }
        if (result.notes != null) {
          _notesCtrl.text = result.notes!;
        }
        if (result.category != null) {
          final known = categories.any((c) => c.name.toLowerCase() == result.category!.toLowerCase());
          if (known) {
            _category = categories.firstWhere((c) => c.name.toLowerCase() == result.category!.toLowerCase()).name;
            _type = TransactionType.expense; // Generally receipts are expenses
            _tabCtrl.index = 0;
          } else {
            _category = _customKey;
            _customCatCtrl.text = result.category!;
          }
        }
      });
      
      if (result.amount == null && result.category == null && result.date == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not extract any data from the receipt.'),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        String msg = 'Extracted: ';
        if (result.amount != null) msg += '₹${_amountCtrl.text} ';
        if (result.category != null) msg += 'for $_category ';
        if (result.date != null) msg += 'on ${_formatDate(_date)}';
        
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(msg.trim()),
             duration: const Duration(seconds: 5),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to process image.'),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingOcr = false);
      }
    }
  }
}

class _Cursor extends StatefulWidget {
  final Color color;
  const _Cursor({required this.color});

  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(width: 2, height: 40, color: widget.color),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  final Color accentColor;
  final Function(String) onTap;
  final VoidCallback onBackspace;
  final VoidCallback onSave;
  final String saveLabel;

  const _NumericKeypad({
    required this.accentColor,
    required this.onTap,
    required this.onBackspace,
    required this.onSave,
    required this.saveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(['1', '2', '3']),
          _row(['4', '5', '6']),
          _row(['7', '8', '9']),
          Row(
            children: [
              _key('.', flex: 1),
              _key('0', flex: 1),
              _key('backspace', flex: 1, isIcon: true),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(saveLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(List<String> keys) => Row(children: keys.map((k) => _key(k)).toList());

  Widget _key(String label, {int flex = 1, bool isIcon = false}) {
    return Expanded(
      flex: flex,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => isIcon ? onBackspace() : onTap(label),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: isIcon
                ? Icon(Icons.backspace_outlined, size: 20, color: accentColor)
                : Text(
                    label,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: accentColor.withAlpha(200)),
                  ),
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
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => AddTransactionSheet(existingTransaction: transaction),
  );
}
