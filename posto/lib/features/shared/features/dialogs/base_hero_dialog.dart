import 'package:flutter/material.dart';

import '../../widgets/custom_rect_tween.dart';

class BaseHeroDialog extends StatelessWidget {
  final String tag;
  final Widget child;

  const BaseHeroDialog({
    super.key,
    required this.tag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: tag,
        createRectTween: (begin, end) => CustomRectTween(begin: begin!, end: end!),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
