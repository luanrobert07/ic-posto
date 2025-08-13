import 'package:flutter/material.dart';

import '../widgets/cross_platform_selector.dart';

class BasePage extends StatelessWidget {
  final Widget webPage;
  final Widget mobilePage;

  const BasePage({
    super.key,
    required this.webPage,
    required this.mobilePage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CrossPlatformSelector(
          mobilePage: mobilePage,
          webPage: webPage,
        ),
      ),
    );
  }
}
