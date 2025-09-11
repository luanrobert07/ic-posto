import 'package:flutter/material.dart';

import '../../../../../core/utils/utils.dart';

class MedicalColors {
  static const Color primary = Color(0xFF2E7D8F);
  static const Color primaryLight = Color(0xFF4A9BAE);
  static const Color secondary = Color(0xFF8FBC8F);
  static const Color accent = Color(0xFFE8F4F8);
  static const Color background = Color(0xFFF8FFFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color border = Color(0xFFE1E8ED);
}

class DateSelectorButton extends StatelessWidget {
  final TimeOfDay time;
  final Function(TimeOfDay) onChange;

  const DateSelectorButton({
    super.key,
    required this.time,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: MedicalColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          TimeOfDay? newTime = await showTimePicker(
            context: context,
            initialTime: time,
            initialEntryMode: TimePickerEntryMode.dial,
          );
          if (newTime != null) {
            onChange(newTime);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: MedicalColors.surface,
          foregroundColor: MedicalColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: MedicalColors.border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              color: MedicalColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              Utils.formatTime2(time),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: MedicalColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
