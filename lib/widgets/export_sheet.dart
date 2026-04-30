import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';
import '../services/pdf_service.dart';

void showExportSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ExportSheet(),
  );
}

class _ExportSheet extends StatefulWidget {
  const _ExportSheet();

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final month = provider.selectedMonth;
    final txCount = provider.transactions
        .where((t) => t.date.year == month.year && t.date.month == month.month)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.primary.withAlpha(40)),
      ),
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

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.picture_as_pdf_rounded, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Export Statement',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(DateFormat('MMMM yyyy').format(month),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Info card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: cs.onSurfaceVariant, size: 18),
                const SizedBox(width: 10),
                Text('$txCount transaction${txCount == 1 ? '' : 's'} will be included',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          if (_isGenerating)
            const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ))
          else ...[
            _actionButton(
              context,
              icon: Icons.preview_rounded,
              label: 'Preview PDF',
              subtitle: 'View in built-in reader',
              color: cs.primary,
              onTap: () => _generate(context, mode: _ExportMode.preview),
            ),
            const SizedBox(height: 10),
            _actionButton(
              context,
              icon: Icons.share_rounded,
              label: 'Share PDF',
              subtitle: 'Send via WhatsApp, Email, etc.',
              color: const Color(0xFF22C55E),
              onTap: () => _generate(context, mode: _ExportMode.share),
            ),
            const SizedBox(height: 10),
            _actionButton(
              context,
              icon: Icons.save_alt_rounded,
              label: 'Save to Device',
              subtitle: 'Save to Documents folder',
              color: const Color(0xFF6366F1),
              onTap: () => _generate(context, mode: _ExportMode.save),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: cs.onSurface)),
                    Text(subtitle,
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generate(BuildContext context, {required _ExportMode mode}) async {
    final nav = Navigator.of(context);
    final sm = ScaffoldMessenger.of(context);
    
    setState(() => _isGenerating = true);
    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final month = provider.selectedMonth;
      final bytes = await PdfService.generateMonthlyStatement(provider, month);
      final monthStr = DateFormat('MMM_yyyy').format(month);
      final fileName = 'FinTracker_$monthStr.pdf';

      if (!mounted) return;

      switch (mode) {
        case _ExportMode.preview:
          nav.pop();
          await Printing.layoutPdf(
            onLayout: (_) async => bytes,
            name: fileName,
          );
          break;
        case _ExportMode.share:
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(bytes);
          if (!mounted) return;
          nav.pop();
          await Share.shareXFiles([XFile(file.path)], text: 'Fin Tracker Monthly Statement');
          break;
        case _ExportMode.save:
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(bytes);
          if (!mounted) return;
          nav.pop();
          
          sm.showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Saved to Documents: $fileName')),
              ]),
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        sm.showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}

enum _ExportMode { preview, share, save }
