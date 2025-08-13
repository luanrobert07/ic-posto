import 'package:flutter/material.dart';

import '../../../../core/navigation/routes/hero_dialog_route.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_rect_tween.dart';

class HeroDialogSource extends StatelessWidget {
  final String tag;
  final Widget icon;
  final WidgetBuilder heroDialogBuilder;
  final double? splashRadius;

  const HeroDialogSource({
    super.key,
    this.splashRadius,
    required this.tag,
    required this.icon,
    required this.heroDialogBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (begin, end) => CustomRectTween(begin: begin!, end: end!),
      child: CustomIconButton(
        splashRadius: splashRadius,
        icon: icon,
        onPressed: () {
          Navigator.push(context, HeroDialogRoute(
            builder: heroDialogBuilder,
          ));
        },
      ),
    );
  }
}
