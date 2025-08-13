import 'dart:async';

import 'package:flutter/material.dart';

class NotificationCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onDismissed;
  final Function(BuildContext)? onTap;

  const NotificationCard({
    super.key,
    required this.child,
    required this.duration,
    required this.onDismissed,
    required this.onTap,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(1.0, 0), // Start off screen to the right
      end: Offset(0, 0), // Slide to position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (!mounted) return;

    _controller.reverse().then((_) {
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _dismiss();
        if (widget.onTap != null) {
          widget.onTap!(context);
        }
      },
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Card(
            color: Theme.of(context).cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
