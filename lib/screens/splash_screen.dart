import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // "FIN TRACKER" — space at index 3 is a gap, not animated
  static const _chars = ['F', 'I', 'N', ' ', 'T', 'R', 'A', 'C', 'K', 'E', 'R'];

  late final List<Animation<double>> _fade;
  late final List<Animation<double>> _slide;
  late final Animation<double> _tagFade;
  late final Animation<double> _screenOpacity;

  @override
  void initState() {
    super.initState();

    // Total timeline: 3 400 ms
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    // Letters spread across 0 – 58 % of timeline
    _fade = List.generate(_chars.length, (i) {
      final s = (i / _chars.length) * 0.52;
      final e = (s + 0.11).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(s, e, curve: Curves.easeOut)),
      );
    });

    _slide = List.generate(_chars.length, (i) {
      final s = (i / _chars.length) * 0.52;
      final e = (s + 0.11).clamp(0.0, 1.0);
      return Tween<double>(begin: 22, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(s, e, curve: Curves.easeOut)),
      );
    });

    // Tagline appears after letters
    _tagFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.62, 0.78, curve: Curves.easeOut)),
    );

    // Whole screen fades out at the end
    _screenOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.88, 1.0, curve: Curves.easeIn)),
    );

    _ctrl.forward();

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final letterColor = cs.onSurface;
    final taglineColor = cs.onSurfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _screenOpacity.value,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Letter row ──────────────────────────────────────────
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_chars.length, (i) {
                    if (_chars[i] == ' ') return const SizedBox(width: 20);
                    return Opacity(
                      opacity: _fade[i].value,
                      child: Transform.translate(
                        offset: Offset(0, _slide[i].value),
                        child: Text(
                          _chars[i],
                          style: GoogleFonts.plusJakartaSans(
                            color: letterColor,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                            height: 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 14),

                // ── Tagline ─────────────────────────────────────────────
                Opacity(
                  opacity: _tagFade.value,
                  child: Text(
                    'Your Money, Simplified',
                    style: GoogleFonts.plusJakartaSans(
                      color: taglineColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
