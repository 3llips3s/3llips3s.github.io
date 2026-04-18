import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../widgets/hero/hero_section.dart';
import '../widgets/registry/project_registry.dart';
import '../widgets/engine_room/terminal_registry.dart';

/// The single-page portfolio, assembled from section widgets.
///
/// Each section (Hero, Registry, Engine Room, Contact, Footer)
/// will be added as a child of the scroll view in later phases.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _registryKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Smooth-scroll to the Project Registry section.
  void _scrollToRegistry() {
    final ctx = _registryKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      final target =
          box.localToGlobal(Offset.zero).dy + _scrollController.offset;
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // ── Hero Section ──
              HeroSection(onSeeMyWork: _scrollToRegistry),

              // ── Project Registry ──
              ProjectRegistry(key: _registryKey),

              // ── Engine Room (Phase 4) ──
              const TerminalRegistry(),

              // ── Contact (Phase 4) ──
              _placeholder('CONTACT', height: 200),

              // ── Footer (Phase 4) ──
              _placeholder('FOOTER', height: 80),
            ],
          ),
        ),
      ),
    );
  }

  /// Temporary placeholder for sections not yet implemented.
  Widget _placeholder(String label, {required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          '[ $label ]',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
        ),
      ),
    );
  }
}
