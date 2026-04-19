import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../services/feedback_service.dart';
import '../../utils/device_info_helper.dart';

/// Radiant, inviting feedback dialog matching the Studio aesthetic.
///
/// Triggered from project card secondary actions. The [projectName]
/// is displayed as a non-editable pill badge at the top of the dialog.
class FeedbackDialog extends StatefulWidget {
  final String projectName;

  const FeedbackDialog({super.key, required this.projectName});

  /// Convenience method to show the dialog from any context.
  static void show(BuildContext context, {required String projectName}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Feedback',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Center(
            child: SingleChildScrollView(
              child: FeedbackDialog(projectName: projectName),
            ),
          ),
        );
      },
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageFocusNode = FocusNode();

  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final success = await FeedbackService.submit(
      message: message,
      projectName: widget.projectName,
      contactEmail: email.isNotEmpty ? email : null,
      deviceInfo: DeviceInfoHelper.collect(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });
      // Auto-dismiss after showing success state.
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      // Silent failure — dismiss without error UI.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double dialogWidth =
        screenWidth < 768
            ? screenWidth -
                80 // Matches native AlertDialog horizontal inset padding precisely
            : 400; // Narrower max width

    // ── Radiant color palette ──────────────────────────────────────
    final Color dialogBg =
        isDark
            ? const Color(
              0xFF2A2438,
            ) // Brighter, lifted purple-tinted dark surface
            : Colors.white;
    final Color fieldFill =
        isDark
            ? const Color(0xFF352F44) // Lighter field fill
            : const Color(0xFFF8F6FC); // Very light purple-white tint
    final Color textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color hintColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color borderColor =
        isDark
            ? AppColors.primary.withValues(alpha: 0.25) // Brighter border
            : AppColors.primary.withValues(alpha: 0.12);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          decoration: BoxDecoration(
            color: dialogBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOut,
            child:
                _isSuccess
                    ? _buildSuccessState(textColor)
                    : _buildForm(
                      isDark: isDark,
                      textColor: textColor,
                      hintColor: hintColor,
                      fieldFill: fieldFill,
                      borderColor: borderColor,
                    ),
          ),
        ),
      ),
    );
  }

  // ── Success State ──────────────────────────────────────────────────

  Widget _buildSuccessState(Color textColor) {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppColors.primaryLight,
            )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 16),
        Text(
          'thank you',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textColor.withValues(alpha: 0.8),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Form State ─────────────────────────────────────────────────────

  Widget _buildForm({
    required bool isDark,
    required Color textColor,
    required Color hintColor,
    required Color fieldFill,
    required Color borderColor,
  }) {
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Project Title ──
        Text(
          widget.projectName,
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 24),

        // ── Message Field ──
        TextField(
          controller: _messageController,
          focusNode: _messageFocusNode,
          maxLines: 6,
          minLines: 3,
          onTap: () => _messageFocusNode.requestFocus(),
          textInputAction: TextInputAction.newline,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'your feedback...',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: hintColor.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: fieldFill,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Email Field (optional) ──
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'email (optional)',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: hintColor.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Actions ──
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Cancel
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                'cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: hintColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Submit
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isSubmitting
                      ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      )
                      : Text(
                        'share',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ],
        ),
      ],
    );
  }
}
