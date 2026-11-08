import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant { primary, accent, secondary }

class TaklukButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  const TaklukButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  @override
  State<TaklukButton> createState() => _TaklukButtonState();
}

class _TaklukButtonState extends State<TaklukButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color get _bgColor {
    if (widget.onPressed == null) return TaklukColors.muted.withOpacity(0.4);
    switch (widget.variant) {
      case ButtonVariant.primary:
        return TaklukColors.primary;
      case ButtonVariant.accent:
        return TaklukColors.accent;
      case ButtonVariant.secondary:
        return TaklukColors.tint;
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.accent:
        return Colors.white;
      case ButtonVariant.secondary:
        return TaklukColors.primary;
    }
  }

  List<BoxShadow> get _shadows {
    if (widget.onPressed == null) return [];
    if (widget.variant == ButtonVariant.primary) {
      return [
        BoxShadow(
          color: TaklukColors.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [];
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
        onTapDown: (_) {
          if (widget.onPressed != null && !widget.isLoading) {
            _scaleController.forward();
          }
        },
        onTapUp: (_) {
          _scaleController.reverse();
          if (widget.onPressed != null && !widget.isLoading) {
            widget.onPressed!();
          }
        },
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          height: 52,
          padding:
              EdgeInsets.symmetric(horizontal: widget.fullWidth ? 0 : 24),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: TaklukRadius.cardBR,
            boxShadow: _shadows,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: _textColor, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
