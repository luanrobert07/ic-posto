import 'dart:ui';
import 'package:flutter/material.dart';

class CurveShadow extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double sigma;
  final Color color;
  final Offset offset;

  const CurveShadow({
    super.key,
    required this.child,
    this.opacity = 0.32,
    this.sigma = 3,
    this.color = Colors.black,
    this.offset = const Offset(2, 2),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (color.a != 0)
          Transform.translate(
            offset: offset,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                  sigmaY: sigma, sigmaX: sigma, tileMode: TileMode.decal),
              child: Opacity(
                  opacity: opacity,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(color, BlendMode.srcATop),
                    child: child,
                  ),
                ),
            ),
          ),
        child,
      ],
    );
  }
}
