import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/utils.dart';
import '../state_management/professional_profile_settings_provider.dart';
import '../state_management/work_period.dart';

class MedicalColors {
  static const Color primary = Color(0xFF2E7D8F);
  static const Color primaryLight = Color(0xFF4A9BAE);
  static const Color secondary = Color(0xFF1A5F6F);
  static const Color accent = Color(0xFF00BCD4);
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFDFDFD);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color border = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
}

class ScheduleSettings extends ConsumerWidget {
  const ScheduleSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(professionalProfileSettingsNotifierProvider);
    final notifier = ref.read(professionalProfileSettingsNotifierProvider.notifier);

    return Container(
      color: MedicalColors.background,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (context, day) {
          List<WorkPeriod> periods = state.schedule[day];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: MedicalColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: MedicalColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [MedicalColors.primary, MedicalColors.primaryLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      Utils.dayIdToName(day),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (periods.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: MedicalColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: MedicalColors.border),
                      ),
                      child: const Text(
                        'OFF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MedicalColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: periods.length,
                    itemBuilder: (context, id) {
                      WorkPeriod period = periods[id];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MedicalColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: MedicalColors.border.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildStyledTimeButton(
                                context,
                                period.begin,
                                (newTime) {
                                  period.begin = newTime;
                                  notifier.updatePeriod(day, id, period);
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: MedicalColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'To',
                                style: TextStyle(
                                  color: MedicalColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildStyledTimeButton(
                                context,
                                period.end,
                                (newTime) {
                                  period.end = newTime;
                                  notifier.updatePeriod(day, id, period);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildStyledActionButton(
                          onPressed: () => notifier.addPeriod(day),
                          label: '+ Add Period',
                          isPrimary: true,
                        ),
                      ),
                      if (periods.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStyledActionButton(
                            onPressed: () => notifier.removePeriod(day),
                            label: '- Remove',
                            isPrimary: false,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStyledTimeButton(BuildContext context, TimeOfDay time, Function(TimeOfDay) onChange) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MedicalColors.primary, MedicalColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: MedicalColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            TimeOfDay? newTime = await showTimePicker(
              context: context,
              initialTime: time,
              initialEntryMode: TimePickerEntryMode.dial,
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: MedicalColors.primary,
                      onPrimary: Colors.white,
                      secondary: MedicalColors.accent,
                      onSecondary: Colors.white,
                      surface: MedicalColors.surface,
                      onSurface: MedicalColors.textPrimary,
                    ),
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: MedicalColors.surface,
                      hourMinuteTextColor: MedicalColors.textPrimary,
                      hourMinuteColor: MedicalColors.cardBackground,
                      dayPeriodTextColor: MedicalColors.textPrimary,
                      dayPeriodColor: MedicalColors.cardBackground,
                      dialHandColor: MedicalColors.primary,
                      dialBackgroundColor: MedicalColors.cardBackground,
                      dialTextColor: MedicalColors.textPrimary,
                      entryModeIconColor: MedicalColors.primary,
                      helpTextStyle: TextStyle(
                        color: MedicalColors.textSecondary,
                        fontSize: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (newTime != null) {
              onChange(newTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              Utils.formatTime2(time),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledActionButton({
    required VoidCallback onPressed,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [MedicalColors.accent, MedicalColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : MedicalColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: MedicalColors.border),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: MedicalColors.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isPrimary ? Colors.white : MedicalColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
