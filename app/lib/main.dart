import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'screens/root_shell.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
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

class _BootState extends State<_Boot> {
  _Phase _phase = _Phase.splash;

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.splash:
        return SplashScreen(onDone: () => setState(() => _phase = _Phase.onboarding));
      case _Phase.onboarding:
        return OnboardingScreen(onDone: () => setState(() => _phase = _Phase.app));
      case _Phase.app:
        return const RootShell();
    }
  }
}
