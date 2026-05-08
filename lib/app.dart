import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/home_screen.dart';
import 'widgets/shader_warmup.dart';

/// The root widget of the application that manages the global [ThemeMode].
///
/// Wraps the entire application in a [MaterialApp] and orchestrates the 
/// initial [AppShaderWarmup] transition.
class StudioApp extends StatefulWidget {
  const StudioApp({super.key});

  /// Provides a global notifier for descendants to toggle the current [ThemeMode].
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.dark);

  @override
  State<StudioApp> createState() => _StudioAppState();
}

class _StudioAppState extends State<StudioApp> {
  bool _isWarmedUp = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: StudioApp.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Studio 10200',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: _isWarmedUp
              ? const HomeScreen()
              : Scaffold(
                  backgroundColor: Colors.transparent,
                  body: AppShaderWarmup(
                    onWarmupComplete: () {
                      if (mounted) {
                        setState(() => _isWarmedUp = true);
                      }
                    },
                  ),
                ),
        );
      },
    );
  }
}
