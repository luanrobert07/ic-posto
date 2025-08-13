import 'package:flutter/material.dart';
import 'package:posto/features/professional/profile_settings/schedule_exceptions/ui/existing_rule_item.dart';

import '../../exceptions_rule_editor/models/exception_rule_model.dart';

class ExistingRulesList extends StatelessWidget {
  final List<ExceptionRuleModel> existingRulesExceptions;
  final void Function(ExceptionRuleModel rule) onEdit;

  const ExistingRulesList({
    super.key,
    required this.existingRulesExceptions,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Text('Existing rules:', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            itemCount: existingRulesExceptions.length,
            itemBuilder: (context, id) {
              final rule = existingRulesExceptions[id];
              return ExistingRuleItem(
                rule: rule,
                onEdit: () {
                  onEdit(rule);
                },
              );
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
