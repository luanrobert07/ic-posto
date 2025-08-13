import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final Function() onPressed;
  final double? splashRadius;

  const CustomIconButton({
    super.key,
    this.splashRadius,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double radius;
    if (splashRadius != null) {
      radius = splashRadius!;
    } else {
      radius = 26;
    }

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: radius * 2,
        child: IconButton(
          icon: icon,
          splashRadius: radius,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
