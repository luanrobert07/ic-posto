import 'package:flutter/material.dart';

import 'base_hero_dialog.dart';

class InformationHeroDialog extends StatelessWidget {
  final String tag;
  final String title;
  final String description;

  const InformationHeroDialog({
    super.key,
    required this.tag,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return BaseHeroDialog(
      tag: tag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
            softWrap: true,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            softWrap: true,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
