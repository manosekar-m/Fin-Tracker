import 'package:flutter/material.dart';
import '../widgets/add_transaction_sheet.dart';
import 'home_screen.dart';
import 'transaction_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  static const _navItems = [
    (icon: Icons.home_outlined,         filled: Icons.home_rounded,           label: 'Home'),
    (icon: Icons.receipt_long_outlined,  filled: Icons.receipt_long_rounded,   label: 'Txns'),
    (icon: Icons.analytics_outlined,     filled: Icons.analytics_rounded,      label: 'Insights'),
    (icon: Icons.person_outline_rounded, filled: Icons.person_rounded,         label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(context),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outline.withAlpha(89), width: 1)),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                // Left two items
                ...[0, 1].map((i) => Expanded(child: _navItem(context, i))),
                // FAB spacer
                const SizedBox(width: 72),
                // Right two items
                ...[2, 3].map((i) => Expanded(child: _navItem(context, i))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withAlpha(115),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showAddTransactionSheet(context),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];
    final color = isSelected ? cs.primary : cs.onSurfaceVariant.withAlpha(140);

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      splashColor: cs.primary.withAlpha(20),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: isSelected
                ? Container(
                    key: const ValueKey('filled'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(31),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(item.filled, color: cs.primary, size: 22),
                  )
                : Padding(
                    key: const ValueKey('outline'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Icon(item.icon, color: color, size: 22),
                  ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}
