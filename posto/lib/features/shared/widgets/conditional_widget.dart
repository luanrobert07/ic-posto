import 'package:flutter/cupertino.dart';

class ConditionalWidget extends StatelessWidget {
  final bool condition;
  final WidgetBuilder whenTrue;
  final WidgetBuilder whenFalse;

  const ConditionalWidget({
    super.key,
    required this.condition,
    required this.whenTrue,
    required this.whenFalse,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? whenTrue(context) : whenFalse(context);
  }
}
