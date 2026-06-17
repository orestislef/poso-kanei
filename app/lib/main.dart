import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/onboarding_screen.dart';
import 'screens/root_shell.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        child: MaterialApp(
          title: 'πόσο κάνει',
          debugShowCheckedModeBanner: false,
          theme: PkTheme.light,
          darkTheme: PkTheme.dark,
          themeMode: _state.themeMode,
          home: const _Boot(),
        ),
      ),
    );
  }
}

/// Splash → onboarding → app.
class _Boot extends StatefulWidget {
  const _Boot();
  @override
  State<_Boot> createState() => _BootState();
}

enum _Phase { splash, onboarding, app }

const _kOnboardingSeen = 'pk_onboarding_seen';

class _BootState extends State<_Boot> {
  _Phase _phase = _Phase.splash;

  // Loaded while the splash plays; null until known.
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
      setState(() => _seen = false); // storage unavailable → show onboarding
    });
  }

  void _afterSplash() {
    // If prefs haven't resolved yet, treat as not-seen (show onboarding).
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
        return const RootShell();
    }
  }
}
