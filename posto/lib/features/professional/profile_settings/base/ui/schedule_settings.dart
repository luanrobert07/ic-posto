import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/utils.dart';
import '../state_management/professional_profile_settings_provider.dart';
import '../state_management/work_period.dart';

class ScheduleSettings extends ConsumerWidget {
  const ScheduleSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(professionalProfileSettingsNotifierProvider);
    final notifier = ref.read(professionalProfileSettingsNotifierProvider.notifier);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: 7,
      itemBuilder: (context, day) {
        List<WorkPeriod> periods = state.schedule[day];

        return Card(
          margin: const EdgeInsets.all(15),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Utils.dayIdToName(day)),
                const SizedBox(width: 15),
                if (periods.isEmpty)
                  const Text('OFF'),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: periods.length,
                  itemBuilder: (context, id) {
                    WorkPeriod period = periods[id];

                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          scheduleButton(
                            context,
                            period.begin,
                                (newTime) {
                              period.begin = newTime;
                              notifier.updatePeriod(day, id, period);
                            },
                          ),
                          const SizedBox(width: 15),
                          const Text('To'),
                          const SizedBox(width: 15),
                          scheduleButton(
                            context,
                            period.end,
                                (newTime) {
                              period.end = newTime;
                              notifier.updatePeriod(day, id, period);
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
                        notifier.addPeriod(day);
                      },
                      child: const Text('+ Add'),
                    ),
                    const SizedBox(width: 15),
                    if (periods.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          notifier.removePeriod(day);
                        },
                        child: const Text('- Remove'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget scheduleButton(BuildContext context, TimeOfDay time, Function(TimeOfDay) onChange) {
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
