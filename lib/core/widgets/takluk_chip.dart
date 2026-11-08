import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TaklukChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const TaklukChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<TaklukChip> createState() => _TaklukChipState();
}

class _TaklukChipState extends State<TaklukChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.96).animate(_controller),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? TaklukColors.primary
                : TaklukColors.surface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: widget.isActive
                  ? TaklukColors.primary
                  : TaklukColors.line,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color:
                  widget.isActive ? Colors.white : TaklukColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
