import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'curve_shadow.dart';

class CustomAnimatedCurve extends StatefulWidget {
  final bool enableAnimation;
  final AnimationController? controller;
  final Alignment growthAlignment;
  final bool animateXAxis;
  final Color color;
  final String svgAssetPath;
  final ShadowDirection shadowDirection;
  final bool enableShadow;

  const CustomAnimatedCurve({
    super.key,
    required this.svgAssetPath,
    required this.color,
    this.controller,
    this.growthAlignment = Alignment.bottomCenter,
    this.shadowDirection = ShadowDirection.up,
    this.enableAnimation = true,
    this.animateXAxis = false,
    this.enableShadow = false,
  });

  @override
  State<CustomAnimatedCurve> createState() => _CustomAnimatedCurveState();
}

class _CustomAnimatedCurveState extends State<CustomAnimatedCurve> with SingleTickerProviderStateMixin {
  late final AnimationController? _controller;
  late final Animation<double> _animation;
  bool _isControllerDisposed = false;

  Widget _getCurveWithShadow() {
    return CurveShadow(
      offset: _getShadowOffset(widget.shadowDirection),
      child: _getRawCurve(),
    );
  }

  Widget _getRawCurve() {
    return SvgPicture.asset(
      widget.svgAssetPath,
      clipBehavior: Clip.none,
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(widget.color, BlendMode.srcATop),
    );
  }

  Widget _getCurve() {
    if (widget.enableShadow) {
      return _getCurveWithShadow();
    } else {
      return _getRawCurve();
    }
  }

  Offset _getShadowOffset(ShadowDirection shadowDirection) {
    switch(shadowDirection) {
      case ShadowDirection.up:
        return const Offset(0, -4);
      case ShadowDirection.down:
        return const Offset(0, 4);
      case ShadowDirection.left:
        return const Offset(-4, 0);
      case ShadowDirection.right:
        return const Offset(4, 0);
    }
  }

  Future _animate() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_isControllerDisposed) {
      _controller!.forward(from: 0);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    } else {
      _controller = widget.controller;
    }

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));

    if (widget.enableAnimation) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _animate();
      });
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
      _isControllerDisposed = true;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimation) {
      return _getCurve();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scaleY: _animation.value,
          scaleX: widget.animateXAxis ? _animation.value : 1,
          alignment: widget.growthAlignment,
          child: _getCurve(),
        );
      },
      child: _getCurve(),
    );
  }
}

enum ShadowDirection {
  up,
  down,
  left,
  right,
}
