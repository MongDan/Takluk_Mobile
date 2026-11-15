import 'package:flutter/material.dart';

/// Container for the branch navigators of go_router's StatefulShellRoute.
///
/// Every branch stays alive (so each tab keeps its scroll position and state),
/// but switching tabs is animated with a soft fade + slide instead of an
/// instant swap. Motion follows DESIGN.md: "Ganti tab: fade + translate Y".
class AnimatedBranchContainer extends StatelessWidget {
  final int currentIndex;
  final List<Widget> children;

  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  static const Duration _duration = Duration(milliseconds: 240);
  static const Curve _curve = Curves.easeOutCubic;
  static const Offset _hiddenOffset = Offset(0, 0.02);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var index = 0; index < children.length; index++)
          _buildBranch(index),
      ],
    );
  }

  Widget _buildBranch(int index) {
    final isActive = index == currentIndex;

    return IgnorePointer(
      ignoring: !isActive,
      child: ExcludeSemantics(
        excluding: !isActive,
        child: AnimatedOpacity(
          opacity: isActive ? 1 : 0,
          duration: _duration,
          curve: _curve,
          child: AnimatedSlide(
            offset: isActive ? Offset.zero : _hiddenOffset,
            duration: _duration,
            curve: _curve,
            // TickerMode only wraps the branch content so the fade/slide
            // animations above keep running while a tab is switching.
            child: TickerMode(enabled: isActive, child: children[index]),
          ),
        ),
      ),
    );
  }
}
