import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../core/theme/app_theme.dart';
import '../../data/models/tracker_model.dart';

/// Glassmorphic Widget для карток трекерів
/// Реалізує дизайн із матовим скляним ефектом
/// Характеристики:
/// - BackdropFilter з розмиттям (blur)
/// - Напівпрозорі градієнтні фони
/// - Тонкі напівпрозорі межі
/// - Плавні анімації
class GlassmorphicTrackerCard extends StatefulWidget {
  final TrackerModel tracker;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isSelected;

  const GlassmorphicTrackerCard({
    super.key,
    required this.tracker,
    required this.onTap,
    required this.onDelete,
    this.isSelected = false,
  });

  @override
  State<GlassmorphicTrackerCard> createState() =>
      _GlassmorphicTrackerCardState();
}

class _GlassmorphicTrackerCardState extends State<GlassmorphicTrackerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) {
          _animationController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _animationController.reverse(),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: AppShadow.glassDark,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppBorderRadius.lg),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: widget.tracker.isPairTracker
                    ? _buildPairTrackerContent()
                    : _buildSingleTrackerContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Вміст карти для парного трекера
  Widget _buildPairTrackerContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок та дата
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tracker.person1Name ?? 'Людина 1',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.tracker.person2Name ?? 'Людина 2',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Кнопка видалення
              GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Центральна частина: Серце + кількість днів
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  size: 48,
                  color: Color(int.parse('0xFF${widget.tracker.color.replaceFirst('#', '')}')),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${widget.tracker.daysPassed} днів',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonBlue,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.tracker.formattedTimeSpan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Вміст карти для одиночного трекера
  Widget _buildSingleTrackerContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок та видалення
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.tracker.singleTrackerName ?? widget.tracker.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Кнопка видалення
              GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Центральна частина: кількість днів
          Center(
            child: Column(
              children: [
                Text(
                  '${widget.tracker.daysPassed}',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Color(int.parse('0xFF${widget.tracker.color.replaceFirst('#', '')}')),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'днів',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.tracker.formattedTimeSpan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassmorphic кнопка для додавання нового трекера
class GlassmorphicButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;

  const GlassmorphicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95)
            .animate(_animationController),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: AppShadow.glassLight,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppBorderRadius.lg),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonBlue.withValues(alpha: 0.8),
                      AppColors.neonPurple.withValues(alpha: 0.6),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null && !widget.isLoading)
                      Icon(widget.icon, color: Colors.white, size: 20),
                    if (widget.icon != null && !widget.isLoading)
                      const SizedBox(width: AppSpacing.sm),
                    if (widget.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
