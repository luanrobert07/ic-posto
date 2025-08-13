import 'package:flutter/material.dart';

import '../../../../core/navigation/router.dart';
import 'notification_card.dart';

class BaseNotification {
  static final BaseNotification _instance = BaseNotification._internal();
  factory BaseNotification() => _instance;
  BaseNotification._internal();

  final List<OverlayEntry> _activeNotifications = [];

  void show({
    required Widget child,
    Duration duration = const Duration(seconds: 5),
    double margin = 10,
    double width = 300,
    Function(BuildContext)? onTap,
  }) {
    final BuildContext? context = rootNavigatorKey.currentContext;

    if (context == null) {
      print('Cant show notification');
      return;
    }

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        final index = _activeNotifications.indexWhere((entry) => entry == overlayEntry);
        final bottomOffset = index * 60.0 + margin;
        return Positioned(
          right: margin,
          bottom: bottomOffset,
          child: NotificationCard(
            duration: duration,
            onTap: onTap,
            onDismissed: () {
              _remove(overlayEntry);
            },
            child: child,
          ),
        );
      },
    );

    _activeNotifications.insert(0, overlayEntry);

    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    if (overlay == null) {
      print('No overlay found');
      return;
    }

    overlay.insert(overlayEntry);
  }

  void _remove(OverlayEntry entry) {
    entry.remove();
    _activeNotifications.remove(entry);
    _rebuildOverlay();
  }

  void _rebuildOverlay() {
    for (var entry in _activeNotifications) {
      entry.markNeedsBuild();
    }
  }
}
