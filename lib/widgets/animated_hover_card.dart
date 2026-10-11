import 'package:flutter/material.dart';

class AnimatedHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleAmount;
  final double elevationOffset;

  const AnimatedHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleAmount = 1.025,
    this.elevationOffset = -4.0,
  });

  @override
  State<AnimatedHoverCard> createState() => _AnimatedHoverCardState();
}

class _AnimatedHoverCardState extends State<AnimatedHoverCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final dy = _isPressed ? 1.0 : (_isHovered ? widget.elevationOffset : 0.0);
    final s = _isPressed ? 0.98 : (_isHovered ? widget.scaleAmount : 1.0);

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transformAlignment: Alignment.center,
          transform: Matrix4.diagonal3Values(s, s, 1.0)
            ..setTranslationRaw(0.0, dy, 0.0),
          child: widget.child,
        ),
      ),
    );
  }
}
