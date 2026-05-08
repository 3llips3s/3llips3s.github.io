import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../widgets/hero/hero_section.dart';
import '../widgets/registry/project_registry.dart';
import '../widgets/engine_room/terminal_registry.dart';
import '../widgets/contact/contact_section.dart';

/// The primary entry point for the portfolio application.
///
/// Assembles the various sections (Hero, Registry, Engine Room, Contact) 
/// into a single-page scrolling experience.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _registryKey = GlobalKey();
  bool _isTerminalComplete = false;
  bool _isContactAnimComplete = false;

  /// Scrolls the application back to the top of the view.
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Smooth-scrolls the view to the [ProjectRegistry] section.
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
              HeroSection(onSeeMyWork: _scrollToRegistry),
              ProjectRegistry(key: _registryKey),
              TerminalRegistry(
                onComplete: () {
                  if (!mounted) return;
                  setState(() => _isTerminalComplete = true);
                },
              ),
              ContactSection(
                isTerminalComplete: _isTerminalComplete,
                onAnimationComplete: () {
                  if (mounted && !_isContactAnimComplete) {
                    setState(() => _isContactAnimComplete = true);
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 32,
                  top: 40,
                  left: MediaQuery.sizeOf(context).width < 768 ? 32 : 64,
                  right: MediaQuery.sizeOf(context).width < 768 ? 32 : 64,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Scroll-to-top arrow (flush with section headers)
                    AnimatedOpacity(
                      opacity: _isContactAnimComplete ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: IgnorePointer(
                        ignoring: !_isContactAnimComplete,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _scrollToTop,
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  size: 40,
                                  color: AppColors.primaryLight,
                                )
                                .animate(
                                  onPlay:
                                      (controller) =>
                                          controller.repeat(reverse: true),
                                )
                                .moveY(
                                  begin: 0,
                                  end: -60,
                                  duration: 1500.ms,
                                  curve: Curves.easeInOut,
                                )
                                .fade(
                                  begin: 0.0,
                                  end: 1.0,
                                  duration: 1500.ms,
                                  curve: Curves.easeInOut,
                                ),
                          ),
                        ),
                      ),
                    ),
                    // Center: Copyright
                    Expanded(
                      child: Text(
                        '© 2026 Studio 10200',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    // Right: invisible spacer to balance the arrow width (40) for true centering
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
