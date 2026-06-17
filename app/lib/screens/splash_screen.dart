import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';

/// Brand splash: mark pop + progress bar + "checking N stores…".
class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pop;
  late final AnimationController _bar;
  int _n = 0;
  Timer? _countTimer;
  Timer? _doneTimer;

  static const _bg = Color(0xFF14130F);
  static const _ink = Color(0xFFF5F1E6);
  static const _accent = Color(0xFF6BCB9F);

  @override
  void initState() {
    super.initState();
    final reduce = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _bar = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..forward();
    _countTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _n = 22);
    });
    _doneTimer = Timer(Duration(milliseconds: reduce ? 300 : 2200), widget.onDone);
  }

  @override
  void dispose() {
    _countTimer?.cancel();
    _doneTimer?.cancel();
    _pop.dispose();
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
      backgroundColor: _bg,
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // warm green glow
          Positioned(
            top: -180,
            child: Container(
              width: 700,
              height: 700,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x523FA978), Color(0x003FA978)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(parent: _pop, curve: PkCurve.spring),
                child: FadeTransition(opacity: _pop, child: const BrandMark(size: 88)),
              ),
              const SizedBox(height: 18),
              Text('πόσο κάνει', style: PkText.display(size: 46, weight: FontWeight.w800, color: _ink, tracking: -0.03)),
              const SizedBox(height: 8),
              Text(
                'Μην ρωτάς πόσο κάνει. Ρώτα πού είναι φθηνότερο.',
                textAlign: TextAlign.center,
                style: PkText.body(size: 16, color: _ink.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(PkRadius.pill),
                child: SizedBox(
                  width: 200,
                  height: 5,
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withValues(alpha: 0.12)),
                      AnimatedBuilder(
                        animation: _bar,
                        builder: (context, _) => FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _bar.value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF3FA978), _accent]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DefaultTextStyle(
                style: PkText.mono(size: 12, color: _ink.withValues(alpha: 0.5)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('έλεγχος '),
                    Text('$_n', style: PkText.mono(size: 12, weight: FontWeight.w600, color: _accent)),
                    const Text(' καταστημάτων…'),
                  ],
                ),
              ),
            ],
          ),
          ),
        ],
      ),
      ),
    );
  }
}
