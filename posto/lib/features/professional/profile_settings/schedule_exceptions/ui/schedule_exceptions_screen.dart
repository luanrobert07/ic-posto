import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/features/professional/profile_settings/schedule_exceptions/state_management/schedule_exceptions_provider.dart';
import 'package:posto/features/professional/profile_settings/schedule_exceptions/ui/existing_rules_list.dart';
import 'package:posto/features/shared/features/dialogs/base_dialog.dart';

import '../../exceptions_rule_editor/ui/rule_editor.dart';

class MedicalColors {
  static const Color primaryBlue = Color(0xFF2E86AB);
  static const Color lightBlue = Color(0xFFF2F9FF);
  static const Color accentTeal = Color(0xFF39A0CA);
  static const Color softGray = Color(0xFFF8FAFC);
  static const Color darkGray = Color(0xFF64748B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}

class ScheduleExceptionScreen extends ConsumerWidget {
  const ScheduleExceptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleExceptionNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MedicalColors.lightBlue.withValues(alpha: 0.3),
              MedicalColors.white,
              MedicalColors.softGray.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MedicalColors.primaryBlue.withValues(alpha: 0.1),
                      MedicalColors.accentTeal.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            MedicalColors.primaryBlue,
                            MedicalColors.accentTeal,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: MedicalColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: MedicalColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Exceptions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: MedicalColors.primaryBlue,
                          ),
                        ),
                        Text(
                          'Manage your availability rules',
                          style: TextStyle(
                            fontSize: 14,
                            color: MedicalColors.darkGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
