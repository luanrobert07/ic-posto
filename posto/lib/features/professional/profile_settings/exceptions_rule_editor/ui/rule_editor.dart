import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/features/professional/profile_settings/exceptions_rule_editor/models/exception_rule_model.dart';

import '../../../../shared/widgets/calendar_widget.dart';
import '../../base/state_management/work_period.dart';
import '../models/day_selection_mode.dart';
import '../state_management/rule_editor_provider.dart';
import 'date_selector_button.dart';

class MedicalColors {
  static const Color primary = Color(0xFF2E7D8F);
  static const Color primaryLight = Color(0xFF4A9BAE);
  static const Color secondary = Color(0xFF8FBC8F);
  static const Color accent = Color(0xFFE8F4F8);
  static const Color background = Color(0xFFF8FFFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
}

class RuleEditor extends ConsumerWidget {
  final Key editorKey;
  final ExceptionRuleModel? editingRule;

  const RuleEditor({
    super.key,
    required this.editorKey,
    this.editingRule,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ruleEditorNotifierProvider(editorKey));
    final notifier = ref.read(ruleEditorNotifierProvider(editorKey).notifier);
    final rule = state.rule;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.loadRule(editingRule);
    });

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MedicalColors.background,
            MedicalColors.accent.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: MedicalColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MedicalColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CalendarWidget(
                  focusedDay: state.focusedDay,
                  calendarStartDay: state.calendarStartDay,
                  calendarEndDay: state.calendarEndDay,
                  rangeStartDay: rule.rangeStartDay,
                  rangeEndDay: rule.rangeEndDay,
                  dayRangeEnable: state.daySelectionMode == DaySelectionMode.range,
                  highlightDays: rule.selectedDays ?? [],
                  isDayAvailableForAppointments: (_) => true,
                  onPageChanged: (newFocusedDay) {
                    notifier.setFocusedDay(newFocusedDay);
                  },
                  onDaySelected: (day) {
                    notifier.selectDay(day);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MedicalColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MedicalColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day Selection Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MedicalColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: MedicalColors.accent.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MedicalColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: DropdownButton<DaySelectionMode>(
                      value: state.daySelectionMode,
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: TextStyle(
                        color: MedicalColors.textPrimary,
                        fontSize: 14,
                      ),
                      items: [
                        DropdownMenuItem<DaySelectionMode>(
                          value: DaySelectionMode.singleDay,
                          child: Text('Single day'),
                        ),
                        DropdownMenuItem<DaySelectionMode>(
                          value: DaySelectionMode.multipleDays,
                          child: Text('Multiple days'),
                        ),
                        DropdownMenuItem<DaySelectionMode>(
                          value: DaySelectionMode.range,
                          child: Text('Day range'),
                        ),
                      ],
                      onChanged: (daySelectionMode) {
                        notifier.setDaySelectionMode(daySelectionMode);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MedicalColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MedicalColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Mark selected days as unavailable',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: MedicalColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: rule.markDaysAsUnavailable,
                    activeTrackColor: MedicalColors.primary.withValues(alpha: 0.3),
                    onChanged: (newValue) {
                      notifier.setMarkDaysAsUnavailable(newValue);
                    },
                  ),
                ],
              ),
            ),

            if (!rule.markDaysAsUnavailable) ...[
              const SizedBox(height: 20),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MedicalColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: MedicalColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Periods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MedicalColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rule.workPeriods.length,
                      itemBuilder: (context, id) {
                        WorkPeriod period = rule.workPeriods[id];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MedicalColors.accent.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: MedicalColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DateSelectorButton(
                                time: period.begin,
                                onChange: (newTime) {
                                  period.begin = newTime;
                                  notifier.updatePeriod(id, period);
                                },
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: MedicalColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'To',
                                  style: TextStyle(
                                    color: MedicalColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              DateSelectorButton(
                                time: period.end,
                                onChange: (newTime) {
                                  period.end = newTime;
                                  notifier.updatePeriod(id, period);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [MedicalColors.secondary, MedicalColors.secondary.withValues(alpha: 0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: MedicalColors.secondary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              notifier.addPeriod();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Add Period',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (rule.workPeriods.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: MedicalColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: MedicalColors.error.withValues(alpha: 0.3)),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                notifier.removePeriod();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove, color: MedicalColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: MedicalColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MedicalColors.primary, MedicalColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MedicalColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  notifier.save(editingRule != null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Save Rule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
