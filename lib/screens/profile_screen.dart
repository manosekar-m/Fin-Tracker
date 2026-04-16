import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // ─── Title ────────────────────────────────────────────────────
            Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 28),

            // ─── Avatar + Name ─────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withAlpha(89),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: cs.surface,
                      child: Icon(Icons.person_rounded, size: 46, color: cs.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.userName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showEditNameDialog(context, provider),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.primary.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_rounded, size: 16, color: cs.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Personal Finance Tracker', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Monthly Summary ────────────────────────────────────────────
            _sectionLabel(context, 'This Month'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _card(context),
              child: Row(
                children: [
                  Expanded(child: _summaryTile(context, 'Income', '₹${_fmt(provider.totalIncome)}', const Color(0xFF22C55E))),
                  Container(width: 1, height: 40, color: cs.outline.withAlpha(128)),
                  Expanded(child: _summaryTile(context, 'Expenses', '₹${_fmt(provider.totalExpenses)}', cs.error)),
                  Container(width: 1, height: 40, color: cs.outline.withAlpha(128)),
                  Expanded(child: _summaryTile(context, 'Balance', '₹${_fmt(provider.currentBalance)}', cs.primary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Financial Goals ────────────────────────────────────────────
            _sectionLabel(context, 'Financial Goals'),
            const SizedBox(height: 10),
            _settingTile(
              context: context,
              icon: Icons.savings_rounded,
              iconBg: Colors.amber,
              title: 'Monthly Savings Goal',
              subtitle: '₹${provider.savingsGoal.toStringAsFixed(0)} target',
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              onTap: () => _showEditGoalDialog(context, provider),
            ),
            const SizedBox(height: 24),

            // ─── App Settings ────────────────────────────────────────────────
            _sectionLabel(context, 'App Settings'),
            const SizedBox(height: 10),
            Container(
              decoration: _card(context),
              child: Column(
                children: [
                  _switchTile(
                    context: context,
                    icon: Icons.dark_mode_rounded,
                    iconBg: const Color(0xFF6366F1),
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark appearance',
                    value: provider.isDarkMode,
                    onChanged: (_) => provider.toggleDarkMode(),
                    isFirst: true,
                    isLast: false,
                  ),
                  Divider(height: 1, indent: 72, color: cs.outline.withAlpha(128)),
                  _switchTile(
                    context: context,
                    icon: Icons.fingerprint_rounded,
                    iconBg: const Color(0xFF0D9488),
                    title: 'Biometric Lock',
                    subtitle: 'Fingerprint authentication',
                    value: provider.isBiometricEnabled,
                    onChanged: (val) async {
                      if (val) {
                        bool ok = await AuthService.authenticate();
                        if (ok) provider.toggleBiometric(true);
                      } else {
                        provider.toggleBiometric(false);
                      }
                    },
                    isFirst: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Footer ────────────────────────────────────────────────────────
            GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://www.linkedin.com/in/manosekar-m/');
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  debugPrint('Could not launch $url');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.outline.withAlpha(128)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Made with ', style: Theme.of(context).textTheme.bodySmall),
                        const Icon(Icons.favorite_rounded, color: Colors.red, size: 13),
                        Text(' by manosekar_m', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Fin Tracker v1.0.0', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5));

  Widget _summaryTile(BuildContext context, String label, String value, Color color) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );

  Widget _settingTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _card(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBg.withAlpha(38), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconBg, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  if (subtitle != null) Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isFirst,
    required bool isLast,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg.withAlpha(38), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: cs.primary.withAlpha(128),
            activeThumbColor: cs.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  BoxDecoration _card(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: cs.outline.withAlpha(128)),
    );
  }

  static String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  void _showEditNameDialog(BuildContext context, TransactionProvider provider) {
    final ctrl = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Your Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                provider.setUserName(ctrl.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, TransactionProvider provider) {
    final ctrl = TextEditingController(text: provider.savingsGoal.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Savings Goal'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Goal Amount', prefixText: '₹ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null) {
                provider.setSavingsGoal(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
