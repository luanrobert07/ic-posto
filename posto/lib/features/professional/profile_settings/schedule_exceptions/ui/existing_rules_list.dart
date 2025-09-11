import 'package:flutter/material.dart';
import 'package:posto/features/professional/profile_settings/schedule_exceptions/ui/existing_rule_item.dart';

import '../../exceptions_rule_editor/models/exception_rule_model.dart';

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
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MedicalColors.white,
            MedicalColors.softGray,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MedicalColors.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: MedicalColors.primaryBlue.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MedicalColors.primaryBlue.withValues(alpha: 0.1),
                  MedicalColors.accentTeal.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MedicalColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.rule,
                    color: MedicalColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Existing Rules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MedicalColors.primaryBlue,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: MedicalColors.accentTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${existingRulesExceptions.length}',
                    style: const TextStyle(
                      color: MedicalColors.accentTeal,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (existingRulesExceptions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.rule_outlined,
                    size: 48,
                    color: MedicalColors.darkGray.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No rules created yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: MedicalColors.darkGray.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
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
        ],
      ),
    );
  }
}
