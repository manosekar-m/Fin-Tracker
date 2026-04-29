import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart';
import '../services/hive_service.dart';
import 'auth_screen.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFontSliderExpanded = false;

  void _showDeveloperCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use the exact same colors the app uses
    final sheetBg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg  = cs.surface;

    // Permanent boy avatar
    const devAvatar = 'https://img.icons8.com/color/480/boy.png';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant.withAlpha(120),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // ── Header row: emoji + "Developer" ────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😀', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  'Developer',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Inner dark card ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(18)
                      : cs.outline.withAlpha(60),
                ),
              ),
              child: Column(
                children: [
                  // ── Avatar + speech-bubble wave ─────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Avatar circle
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [cs.primary, cs.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withAlpha(70),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          backgroundColor: cardBg,
                          backgroundImage:
                              const NetworkImage(devAvatar),
                        ),
                      ),
                      // Speech bubble with waving hand
                      Positioned(
                        top: -14,
                        right: -18,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1C2840)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: WavingHandWidget(size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Name ────────────────────────────────────────
                  Text(
                    'Manosekar M',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ── Subtitle ────────────────────────────────────
                  Text(
                    'Fin Tracker Creator | Mobile Application Developer',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withAlpha(150)
                          : const Color(0xFF706B5E),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Divider ─────────────────────────────────────
                  Container(
                    width: 40, height: 2,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(40)
                          : cs.outline.withAlpha(100),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Side-by-side buttons ─────────────────────────
                  Row(
                    children: [
                      // GitHub
                      Expanded(
                        child: _socialButton(
                          label: 'GitHub',
                          icon: Icons.code_rounded,
                          bg: isDark
                              ? const Color(0xFF21262D)
                              : const Color(0xFF24292F),
                          url: 'https://github.com/manosekar-m',
                        ),
                      ),
                      const SizedBox(width: 12),
                      // LinkedIn
                      Expanded(
                        child: _socialButton(
                          label: 'LinkedIn',
                          icon: Icons.link_rounded,
                          bg: const Color(0xFF0A66C2),
                          url: 'https://www.linkedin.com/in/manosekar-m/',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required IconData icon,
    required Color bg,
    required String url,
  }) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        // Directly launch the URL. `canLaunchUrl` can silently fail on Android 11+
        // if the <queries> manifest tags are not set up.
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bg.withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final cs = Theme.of(context).colorScheme;
    final userAvatar = provider.userAvatar;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative Background Orbs
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withAlpha(20),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [cs.primary, cs.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withAlpha(80),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: cs.surface,
                              backgroundImage: userAvatar != null
                                  ? (userAvatar.startsWith('assets')
                                      ? AssetImage(userAvatar) as ImageProvider
                                      : NetworkImage(userAvatar))
                                  : null,
                              child: userAvatar == null
                                  ? Icon(Icons.person_rounded,
                                      size: 50, color: cs.primary)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () =>
                                  _showAvatarSelectionDialog(context, provider),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: cs.surface, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.camera_alt_rounded,
                                    size: 16, color: cs.onPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.userName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.edit_rounded, size: 14),
                            onPressed: () =>
                                _showEditNameDialog(context, provider),
                            constraints: const BoxConstraints(
                                minWidth: 28, minHeight: 28),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // ─── Monthly Summary ────────────────────────────────────────────
                  _sectionLabel(context, 'Monthly Summary'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: provider.isDarkMode
                          ? Colors.white.withAlpha(10)
                          : cs.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: cs.outline.withAlpha(60)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: _summaryTile(
                                context,
                                'Income',
                                '₹${_fmt(provider.totalIncome)}',
                                const Color(0xFF10B981))),
                        Container(
                            width: 1,
                            height: 40,
                            color: cs.outline.withAlpha(60)),
                        Expanded(
                            child: _summaryTile(context, 'Expenses',
                                '₹${_fmt(provider.totalExpenses)}', cs.error)),
                        Container(
                            width: 1,
                            height: 40,
                            color: cs.outline.withAlpha(60)),
                        Expanded(
                            child: _summaryTile(
                                context,
                                'Net Balance',
                                '₹${_fmt(provider.currentBalance)}',
                                cs.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Financial Goals ────────────────────────────────────────────
                  _sectionLabel(context, 'Financial Goals'),
                  const SizedBox(height: 12),
                  _settingTile(
                    context: context,
                    icon: Icons.savings_rounded,
                    iconBg: Colors.amber,
                    title: 'Monthly Savings Goal',
                    subtitle:
                        '₹${provider.savingsGoal.toStringAsFixed(0)} target set',
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => _showEditGoalDialog(context, provider),
                  ),
                  const SizedBox(height: 28),

                  // ─── App Settings ────────────────────────────────────────────────
                  _sectionLabel(context, 'App Management'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: provider.isDarkMode
                          ? Colors.white.withAlpha(10)
                          : cs.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: cs.outline.withAlpha(60)),
                    ),
                    child: Column(
                      children: [
                        _switchTile(
                          context: context,
                          icon: Icons.dark_mode_rounded,
                          iconBg: const Color(0xFFC5A059),
                          title: 'Dark appearance',
                          subtitle: 'Reduce eye strain',
                          value: provider.isDarkMode,
                          onChanged: (_) => provider.toggleDarkMode(),
                          isFirst: true,
                          isLast: false,
                        ),
                        Divider(
                            height: 1,
                            indent: 70,
                            color: cs.outline.withAlpha(60)),
                        _switchTile(
                          context: context,
                          icon: Icons.fingerprint_rounded,
                          iconBg: const Color(0xFF10B981),
                          title: 'Biometric security',
                          subtitle: 'Lock app with fingerprint',
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
                          isLast: false,
                        ),
                        Divider(
                            height: 1,
                            indent: 70,
                            color: cs.outline.withAlpha(60)),
                        _switchTile(
                          context: context,
                          icon: Icons.assignment_outlined,
                          iconBg: const Color(0xFF706B5E),
                          title: 'Rough Plans',
                          subtitle: 'Plan trips or big purchases',
                          value: provider.isRoughPlansEnabled,
                          onChanged: (val) => provider.toggleRoughPlans(val),
                          isFirst: false,
                          isLast: false,
                        ),
                        Divider(
                            height: 1,
                            indent: 70,
                            color: cs.outline.withAlpha(60)),
                        _sliderTile(
                          context: context,
                          icon: Icons.text_fields_rounded,
                          iconBg: const Color(0xFF8B7E74),
                          title: 'Font Size',
                          subtitle: 'Scale: ${provider.fontSizeFactor.toStringAsFixed(1)}x',
                          value: provider.fontSizeFactor,
                          isExpanded: _isFontSliderExpanded,
                          onToggle: () => setState(() => _isFontSliderExpanded = !_isFontSliderExpanded),
                          onChanged: (val) => provider.setFontSizeFactor(val),
                        ),
                        Divider(
                            height: 1,
                            indent: 70,
                            color: cs.outline.withAlpha(60)),
                        _settingTile(
                          context: context,
                          icon: Icons.help_outline_rounded,
                          iconBg: Colors.blue,
                          title: 'App usage guide',
                          subtitle: 'Learn how to use Fin Tracker',
                          trailing:
                              const Icon(Icons.chevron_right_rounded, size: 20),
                          onTap: () => _showHowToUseDialog(context),
                          noBorder: true,
                        ),
                        Divider(
                            height: 1,
                            indent: 70,
                            color: cs.outline.withAlpha(60)),
                        _settingTile(
                          context: context,
                          icon: Icons.delete_forever_rounded,
                          iconBg: Colors.red,
                          title: 'Reset app data',
                          subtitle: 'Wipe all transaction history',
                          trailing: const Icon(Icons.chevron_right_rounded,
                              size: 20, color: Colors.red),
                          onTap: () => _showEraseDataDialog(context, provider),
                          noBorder: true,
                        ),
                        Divider(
                            height: 1,
                            indent: 70,
                            color: cs.outline.withAlpha(60)),
                        _settingTile(
                          context: context,
                          icon: Icons.logout_rounded,
                          iconBg: Colors.orange,
                          title: 'Logout',
                          subtitle: 'Sign out from current session',
                          trailing: const Icon(Icons.chevron_right_rounded,
                              size: 20, color: Colors.orange),
                          onTap: () => _showLogoutDialog(context),
                          noBorder: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ─── Footer ────────────────────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        // Box 1: Fin Tracker (Top)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withAlpha(isDark ? 100 : 150),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'FIN TRACKER',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                  fontSize: 9,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Box 2: Made with Love & Version (Full width) — tap to open dev card
                        GestureDetector(
                          onTap: () => _showDeveloperCard(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: cs.primary.withAlpha(isDark ? 30 : 15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: cs.primary.withAlpha(40)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Made with ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                                    const Icon(Icons.favorite_rounded, color: Colors.red, size: 12),
                                    Text(' by manosekar_m',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            )),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'v1.0.0 • 2026',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 9,
                                        color: cs.onSurfaceVariant.withAlpha(180),
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 110), // Scroll padding
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Text(label,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5));

  Widget _summaryTile(
          BuildContext context, String label, String value, Color color) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14, color: color)),
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
    bool noBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: noBorder ? null : _card(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: iconBg.withAlpha(38),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconBg, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  if (subtitle != null)
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconBg.withAlpha(38),
                borderRadius: BorderRadius.circular(12)),
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
            inactiveTrackColor: isDark ? Colors.white.withAlpha(30) : null,
            inactiveThumbColor: isDark ? Colors.white.withAlpha(150) : null,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _sliderTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required double value,
    required bool isExpanded,
    required VoidCallback onToggle,
    required ValueChanged<double> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: iconBg.withAlpha(38),
                      borderRadius: BorderRadius.circular(12)),
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
                Transform.rotate(
                  angle: isExpanded ? 1.57 : 0, // 90 degrees if expanded
                  child: const Icon(Icons.chevron_right_rounded, size: 20),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                min: 0.8,
                max: 1.4,
                divisions: 6,
                activeColor: cs.primary,
                inactiveColor: cs.primary.withAlpha(50),
                onChanged: onChanged,
              ),
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0B1426).withAlpha(180) : Colors.white.withAlpha(220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withAlpha(isDark ? 20 : 100)),
          ),
          title: const Text('Edit Name'),
          content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Your Name')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, TransactionProvider provider) {
    final ctrl = TextEditingController(text: provider.savingsGoal.toStringAsFixed(0));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0B1426).withAlpha(180) : Colors.white.withAlpha(220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withAlpha(isDark ? 20 : 100)),
          ),
          title: const Text('Savings Goal'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Goal Amount', prefixText: '₹ '),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
      ),
    );
  }

  void _showHowToUseDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: cs.outlineVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: cs.primary.withAlpha(26),
                        shape: BoxShape.circle),
                    child: Icon(Icons.auto_awesome_rounded,
                        color: cs.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Start Guide',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        Text('Your journey from start to finish',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildGuideItem(
                      context,
                      step: '01',
                      title: 'Personalize Your Profile',
                      desc:
                          'Tap your avatar at the top to choose a fun character and enter your name. Make Fin Tracker truly yours.',
                      icon: Icons.person_outline_rounded,
                      color: Colors.blue,
                    ),
                    _buildGuideItem(
                      context,
                      step: '02',
                      title: 'Add Transactions Manually',
                      desc:
                          'Tap any "+" icon to record an expense or income. You can categorize it, add custom notes, and pick the exact date and time.',
                      icon: Icons.edit_note_rounded,
                      color: Colors.orange,
                    ),
                    _buildGuideItem(
                      context,
                      step: '03',
                      title: 'Smart Receipt Scanner',
                      desc:
                          'Too lazy to type? In the "New Transaction" screen, tap the scanner icon to snap a picture of your receipt. We will automatically extract the amount and categorize it for you!',
                      icon: Icons.document_scanner_rounded,
                      color: Colors.teal,
                    ),
                    _buildGuideItem(
                      context,
                      step: '04',
                      title: 'Set Monthly Targets',
                      desc:
                          'Head to the Profile section and set a "Monthly Savings Goal". Track your progress on the Home screen to stay motivated.',
                      icon: Icons.savings_rounded,
                      color: Colors.amber,
                    ),
                    _buildGuideItem(
                      context,
                      step: '05',
                      title: 'Analyze Your Spending',
                      desc:
                          'Visit the "Insights" tab. Tap on the glowing Donut Chart segments to see exactly where your money is going and optimize your habits.',
                      icon: Icons.pie_chart_rounded,
                      color: Colors.purple,
                    ),
                    _buildGuideItem(
                      context,
                      step: '06',
                      title: 'Secure Your Data',
                      desc:
                          'Enable Biometric Lock in settings so only YOU can see your finances. You can also wipe all data if you need a fresh start.',
                      icon: Icons.fingerprint_rounded,
                      color: const Color(0xFF6366F1),
                      isLast: true,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Start Budgeting Now',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context, {
    required String step,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    bool isLast = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withAlpha(51), width: 2)),
                alignment: Alignment.center,
                child: Text(step,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 2,
                      color: cs.outlineVariant.withAlpha(100),
                      margin: const EdgeInsets.symmetric(vertical: 4)),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withAlpha(isDark ? 50 : 25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 20, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    desc,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEraseDataDialog(BuildContext context, TransactionProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0B1426).withAlpha(180) : Colors.white.withAlpha(220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withAlpha(isDark ? 20 : 100)),
          ),
          icon: const Icon(Icons.warning_amber_rounded,
              color: Colors.red, size: 40),
          title: const Text('Erase All Data?', textAlign: TextAlign.center),
          content: const Text(
            'This will permanently delete all your transactions. This action cannot be undone.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                provider.eraseAllData();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All data erased'),
                    duration: const Duration(seconds: 5),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              child: const Text('Erase'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0B1426).withAlpha(180) : Colors.white.withAlpha(220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withAlpha(isDark ? 20 : 100)),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final settings = HiveService.getSettingsBox();
                await settings.put('isLoggedIn', false);
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarSelectionDialog(
      BuildContext context, TransactionProvider provider) {
    final avatars = [
      'https://img.icons8.com/color/480/user-male-circle--v1.png',
      'https://img.icons8.com/color/480/astronaut.png',
      'https://img.icons8.com/color/480/bear.png',
      'https://img.icons8.com/color/480/cat.png',
      'https://img.icons8.com/color/480/rubber-duck.png',
      'https://img.icons8.com/color/480/fox.png',
      'https://img.icons8.com/color/480/swan.png',
      'https://img.icons8.com/color/480/boy.png',
      'https://img.icons8.com/color/480/nerd.png',
      'https://img.icons8.com/color/480/ninja.png',
      'https://img.icons8.com/color/480/panda.png',
      'https://img.icons8.com/color/480/user-female-circle.png',
      'https://img.icons8.com/color/480/businesswoman.png',
    ];
    final cs = Theme.of(context).colorScheme;
    String? tempSelected = provider.userAvatar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: provider.isDarkMode ? const Color(0xFF0F172A) : cs.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select an Avatar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 30),

                // Selection Preview
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surface,
                      ),
                      child: ClipOval(
                        child: tempSelected != null
                            ? Image.network(tempSelected!, fit: BoxFit.cover)
                            : Icon(Icons.person_outline_rounded,
                                size: 60, color: cs.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: avatars.map((url) {
                        final isSelected = tempSelected == url;
                        return GestureDetector(
                          onTap: () => setModalState(() => tempSelected = url),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? cs.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            padding: EdgeInsets.all(isSelected ? 3 : 0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: provider.isDarkMode
                                    ? Colors.white.withAlpha(15)
                                    : cs.surfaceContainerHighest,
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person,
                                          color: cs.primary.withAlpha(100)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.setUserAvatar(tempSelected);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isDarkMode
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Waving Hand Animation Widget ─────────────────────────────────────────────
class WavingHandWidget extends StatefulWidget {
  final double size;
  const WavingHandWidget({super.key, this.size = 64});

  @override
  State<WavingHandWidget> createState() => _WavingHandWidgetState();
}

class _WavingHandWidgetState extends State<WavingHandWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _wave;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _wave = Tween<double>(begin: -0.45, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wave,
      builder: (context, child) {
        return Transform.rotate(
          angle: _wave.value,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: Text('👋', style: TextStyle(fontSize: widget.size)),
    );
  }
}
