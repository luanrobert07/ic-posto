import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/features/professional/profile_settings/schedule_exceptions/state_management/schedule_exceptions_provider.dart';
import 'package:posto/features/professional/profile_settings/schedule_exceptions/ui/existing_rules_list.dart';
import 'package:posto/features/shared/features/dialogs/base_dialog.dart';

import '../../exceptions_rule_editor/ui/rule_editor.dart';

class ScheduleExceptionScreen extends ConsumerWidget {
  const ScheduleExceptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleExceptionNotifierProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            RuleEditor(editorKey: ValueKey('main')),
            const SizedBox(height: 25),
            ExistingRulesList(
              existingRulesExceptions: state.existingRulesExceptions,
              onEdit: (editingRule) async {
                await BaseDialog.show(
                  title: 'Edit rule',
                  body: RuleEditor(
                    editorKey: ValueKey('editing'),
                    editingRule: editingRule,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
