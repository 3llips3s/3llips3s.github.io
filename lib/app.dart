import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/home_screen.dart';

/// Root widget — owns the theme mode state.
class StudioApp extends StatefulWidget {
  const StudioApp({super.key});

  /// Global key so descendants can toggle theme without InheritedWidget.
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.dark);

  @override
  State<StudioApp> createState() => _StudioAppState();
}

class _StudioAppState extends State<StudioApp> {
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
          home: const HomeScreen(),
        );
      },
    );
  }
}
