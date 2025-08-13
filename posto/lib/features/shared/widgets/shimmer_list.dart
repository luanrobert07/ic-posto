import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  final int shimmerCount;
  final Widget child;

  const ShimmerList({
    super.key,
    this.shimmerCount = 8,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shimmerCount,
      itemBuilder: (context, id) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceDim,
          highlightColor: Theme.of(context).colorScheme.surfaceBright,
          child: child,
        );
      },
    );
  }
}
