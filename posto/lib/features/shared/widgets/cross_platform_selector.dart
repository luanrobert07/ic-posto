import 'package:flutter/material.dart';

class CrossPlatformSelector extends StatelessWidget {
  final Widget webPage;
  final Widget mobilePage;
  final double aspectRatioThreshold;

  const CrossPlatformSelector({
    super.key,
    required this.webPage,
    required this.mobilePage,
    this.aspectRatioThreshold = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final aspectRatio = MediaQuery.of(context).size.aspectRatio;

    return aspectRatio > aspectRatioThreshold ? webPage : mobilePage;
  }
}
