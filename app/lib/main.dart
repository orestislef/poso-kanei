import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean, shareable URLs (no #) on web, backed by the server's SPA fallback.
  if (kIsWeb) usePathUrlStrategy();
  // Draw edge-to-edge behind the status / navigation bars; SafeArea inside the
  // shell keeps interactive content clear of notches and the home indicator.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  runApp(const PosoKaneiApp());
}

class PosoKaneiApp extends StatefulWidget {
  const PosoKaneiApp({super.key});
  @override
  State<PosoKaneiApp> createState() => _PosoKaneiAppState();
}

class _PosoKaneiAppState extends State<PosoKaneiApp> {
  final PkAppState _state = PkAppState();
  final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) => AppScope(
        state: _state,
        child: MaterialApp.router(
          title: 'πόσο κάνει',
          debugShowCheckedModeBanner: false,
          theme: PkTheme.light,
          darkTheme: PkTheme.dark,
          themeMode: _state.themeMode,
          routerConfig: _router,
          builder: (context, child) => _BootGate(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// Splash → onboarding → app, layered over the routed content so deep links
/// still resolve once the gate clears.
class _BootGate extends StatefulWidget {
  final Widget child;
  const _BootGate({required this.child});
  @override
  State<_BootGate> createState() => _BootGateState();
}

enum _Phase { splash, onboarding, app }

const _kOnboardingSeen = 'pk_onboarding_seen';

class _BootGateState extends State<_BootGate> {
  _Phase _phase = _Phase.splash;
  bool? _seen;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      _prefs = prefs;
      setState(() => _seen = prefs.getBool(_kOnboardingSeen) ?? false);
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _seen = false);
    });
  }

  void _afterSplash() {
    setState(() => _phase = (_seen ?? false) ? _Phase.app : _Phase.onboarding);
  }

  void _finishOnboarding() {
    _prefs?.setBool(_kOnboardingSeen, true);
    setState(() => _phase = _Phase.app);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.splash:
        return SplashScreen(onDone: _afterSplash);
      case _Phase.onboarding:
        return OnboardingScreen(onDone: _finishOnboarding);
      case _Phase.app:
        return widget.child;
    }
  }
}
