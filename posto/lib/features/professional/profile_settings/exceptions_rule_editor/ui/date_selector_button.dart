import 'package:flutter/material.dart';

import '../../../../../core/utils/utils.dart';

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
    return ElevatedButton(
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
      child: Text(Utils.formatTime2(time)),
    );
  }
}
