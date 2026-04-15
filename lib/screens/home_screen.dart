import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../widgets/hero/hero_section.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              const HeroSection(),

              // ── Project Registry (Phase 3) ──
              _placeholder('PROJECT REGISTRY', height: 400),

              // ── Engine Room (Phase 4) ──
              _placeholder('ENGINE ROOM', height: 300),

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
