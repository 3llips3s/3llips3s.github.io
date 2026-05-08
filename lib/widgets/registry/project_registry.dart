import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../config/app_colors.dart';
import '../../config/project_data.dart';
import 'project_card.dart';

/// A section that displays the portfolio projects in an adaptive grid.
///
/// Automatically switches between a single-column layout for mobile and a 
/// multi-column layout for desktop viewports.
class ProjectRegistry extends StatelessWidget {
  const ProjectRegistry({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

    return Padding(
      padding: EdgeInsets.only(
        top: 120,
        bottom: 80,
        left: isMobile ? 0 : 24,
        right: isMobile ? 0 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'P R O J E C T S',
                  style: TextStyle(fontFamily: 'JetBrainsMono', 
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          if (isMobile)
            ...List.generate(ProjectData.projects.length, (index) {
              return _AnimatedProjectCard(
                project: ProjectData.projects[index],
                imageOnLeft: index % 2 == 0,
                duration: 1200.ms,
                delay: 0.ms,
                slideBegin: 0.15,
              );
            })
          else
            ...List.generate((ProjectData.projects.length / 2).ceil(), (rowIndex) {
              final int firstIndex = rowIndex * 2;
              final int secondIndex = firstIndex + 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _AnimatedProjectCard(
                      project: ProjectData.projects[firstIndex],
                      imageOnLeft: firstIndex % 2 == 0,
                      duration: 1000.ms,
                      delay: 0.ms,
                      slideBegin: 0.05,
                    ),
                  ),
                  if (secondIndex < ProjectData.projects.length)
                    Expanded(
                      child: _AnimatedProjectCard(
                        project: ProjectData.projects[secondIndex],
                        imageOnLeft: secondIndex % 2 == 0,
                        duration: 1000.ms,
                        delay: 0.ms,
                        slideBegin: 0.05,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _AnimatedProjectCard extends StatefulWidget {
  final ProjectInfo project;
  final bool imageOnLeft;
  final Duration duration;
  final Duration delay;
  final double slideBegin;

  const _AnimatedProjectCard({
    required this.project,
    required this.imageOnLeft,
    required this.duration,
    required this.delay,
    required this.slideBegin,
  });

  @override
  State<_AnimatedProjectCard> createState() => _AnimatedProjectCardState();
}

class _AnimatedProjectCardState extends State<_AnimatedProjectCard> {
  static final Queue<VoidCallback> _pendingAnimations = Queue();
  static bool _isProcessingQueue = false;

  bool _isVisible = false;
  bool _queued = false;

  static void _processQueue() {
    if (_isProcessingQueue || _pendingAnimations.isEmpty) return;
    _isProcessingQueue = true;

    final nextAnimation = _pendingAnimations.removeFirst();
    nextAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.project.name),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.15 && !_isVisible && !_queued) {
          _queued = true;
          _pendingAnimations.addLast(() {
            if (mounted) setState(() => _isVisible = true);
            
            // Stagger the next animation. Wait for the duration of this animation,
            // minus 200ms to create a slight overlapping cascade.
            final nextDelay = widget.duration - const Duration(milliseconds: 200);
            Future.delayed(nextDelay, () {
              _isProcessingQueue = false;
              _processQueue();
            });
          });
          _processQueue();
        }
      },
      child: RepaintBoundary(
        child: ProjectCard(
          project: widget.project,
          imageOnLeft: widget.imageOnLeft,
        ),
      )
      .animate(target: _isVisible ? 1 : 0)
      .fadeIn(duration: widget.duration, delay: widget.delay)
      .slideY(
        begin: widget.slideBegin,
        end: 0,
        duration: widget.duration,
        delay: widget.delay,
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
