import 'package:flutter/material.dart';

class NarrationToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final String startTooltip;
  final String stopTooltip;
  final BorderRadius borderRadius;
  final double size;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final Duration animationDuration;

  const NarrationToggleButton({
    super.key,
    required this.isActive,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    required this.startTooltip,
    required this.stopTooltip,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.size = 44,
    this.padding = const EdgeInsets.all(8),
    this.iconSize = 22,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final tooltip = isActive ? stopTooltip : startTooltip;
    return Semantics(
      button: true,
      label: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          constraints: BoxConstraints.tightFor(width: size, height: size),
          padding: padding,
          icon: AnimatedSwitcher(
            duration: animationDuration,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              isActive ? Icons.stop_rounded : Icons.volume_up_rounded,
              key: ValueKey<bool>(isActive),
              color: iconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
