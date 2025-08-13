import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/features/professional/profile_settings/exceptions_rule_editor/models/exception_rule_model.dart';

import '../../../../shared/widgets/calendar_widget.dart';
import '../../base/state_management/work_period.dart';
import '../models/day_selection_mode.dart';
import '../state_management/rule_editor_provider.dart';
import 'date_selector_button.dart';

class RuleEditor extends ConsumerWidget {
  /// Unique key to separate provider from other instances
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
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

          const SizedBox(height: 20),
          Text('Day selection mode', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 5),
          DropdownButton<DaySelectionMode>(
            value: state.daySelectionMode,
            items: [
              DropdownMenuItem<DaySelectionMode>(
                value: DaySelectionMode.singleDay,
                child: Text('Single day', style: Theme.of(context).textTheme.bodyMedium),
              ),
              DropdownMenuItem<DaySelectionMode>(
                value: DaySelectionMode.multipleDays,
                child: Text('Multiple days', style: Theme.of(context).textTheme.bodyMedium),
              ),
              DropdownMenuItem<DaySelectionMode>(
                value: DaySelectionMode.range,
                child: Text('Day range', style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
            onChanged: (daySelectionMode) {
              notifier.setDaySelectionMode(daySelectionMode);
            },
          ),

          const SizedBox(height: 20),
          Text('Mark selected days as unavailable', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 5),
          Switch(
            value: rule.markDaysAsUnavailable,
            onChanged: (newValue) {
              notifier.setMarkDaysAsUnavailable(newValue);
            },
          ),

          if (!rule.markDaysAsUnavailable) ...[
            const SizedBox(height: 20),
            Text('Insert rules', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              itemCount: rule.workPeriods.length,
              itemBuilder: (context, id) {
                WorkPeriod period = rule.workPeriods[id];

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DateSelectorButton(
                        time: period.begin,
                        onChange: (newTime) {
                          period.begin = newTime;
                          notifier.updatePeriod(id, period);
                        },
                      ),
                      const SizedBox(width: 15),
                      const Text('To'),
                      const SizedBox(width: 15),
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
            const SizedBox(width: 15),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    notifier.addPeriod();
                  },
                  child: const Text('+ Add'),
                ),
                const SizedBox(width: 15),
                if (rule.workPeriods.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      notifier.removePeriod();
                    },
                    child: const Text('- Remove'),
                  ),
              ],
            ),
          ],

          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              notifier.save(editingRule != null);
            },
            child: Text('Save'),
          ),

          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
