import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_theme.dart';

/// Drag a message to the right to reply. Gives haptic feedback once the
/// threshold is crossed and springs back when released.
class SwipeToReply extends StatefulWidget {
  const SwipeToReply({
    super.key,
    required this.child,
    required this.onReply,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback onReply;
  final bool enabled;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  static const _threshold = 64.0;
  static const _maxDrag = 90.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  double _dx = 0;
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _dx = _controller.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate(DragUpdateDetails details) {
    _controller.stop();
    final next = (_dx + details.delta.dx * (_dx > _threshold ? 0.35 : 1)).clamp(
      0.0,
      _maxDrag,
    );
    final armed = next >= _threshold;
    if (armed && !_armed) HapticFeedback.lightImpact();
    setState(() {
      _dx = next;
      _armed = armed;
    });
  }

  void _onEnd(DragEndDetails _) {
    if (_armed) widget.onReply();
    _armed = false;
    _controller.value = _dx;
    _controller.animateTo(0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final progress = min(_dx / _threshold, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _onUpdate,
      onHorizontalDragEnd: _onEnd,
      onHorizontalDragCancel: () => _onEnd(DragEndDetails()),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (_dx > 0)
            Positioned(
              left: 12,
              child: Opacity(
                opacity: progress,
                child: Transform.scale(
                  scale: 0.5 + progress * 0.5,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.chatColors.dateChip.withValues(
                      alpha: 0.9,
                    ),
                    child: Icon(
                      Icons.reply_rounded,
                      size: 20,
                      color: context.chatColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          Transform.translate(offset: Offset(_dx, 0), child: widget.child),
        ],
      ),
    );
  }
}
