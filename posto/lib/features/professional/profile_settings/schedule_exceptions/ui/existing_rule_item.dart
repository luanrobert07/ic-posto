import 'package:flutter/material.dart';

import '../../../../../core/utils/utils.dart';
import '../../exceptions_rule_editor/models/exception_rule_model.dart';

class ExistingRuleItem extends StatelessWidget {
  final ExceptionRuleModel rule;
  final void Function() onEdit;

  const ExistingRuleItem({
    super.key,
    required this.rule,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rule.selectedDays != null)
                  Text(rule.selectedDays!.map((timestamp) => Utils.formatDate(timestamp)).toString()),
                if (rule.rangeStartDay != null)
                  Text('${Utils.formatDate(rule.rangeStartDay!)} - ${Utils.formatDate(rule.rangeEndDay!)}'),

                if (rule.workPeriods.isEmpty)
                  Text('Day unavailable'),
                if (rule.workPeriods.isNotEmpty)
                  Text(rule.workPeriods.toString()),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onEdit,
              child: Text('Edit'),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
