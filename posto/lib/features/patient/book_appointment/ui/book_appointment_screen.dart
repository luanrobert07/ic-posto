import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/patient/book_appointment/state_management/book_appointment_provider.dart';
import 'package:posto/features/patient/book_appointment/state_management/book_appointment_state.dart';
import 'package:posto/features/shared/widgets/calendar_widget.dart';
import 'package:posto/features/shared/screens/base_page.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/features/dialogs/base_dialog.dart';
import '../../../shared/features/dialogs/error_dialog.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  late BookAppointmentState state;
  late BookAppointmentNotifier notifier;
  List<DateTime> availableSlots = [];

  @override
  Widget build(BuildContext context) {
    final String uid = AuthService.getUserUid()!;
    state = ref.watch(bookAppointmentNotifierProvider(uid));
    notifier = ref.read(bookAppointmentNotifierProvider(uid).notifier);

    availableSlots = notifier.getAppointmentsSlots(state.selectedDay);

    return BasePage(
      webPage: webPage(),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage() {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final String uid = AuthService.getUserUid()!;
    return Card(
      margin: EdgeInsets.all(25),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.profile!.name),
            Text(state.profile!.contact),
            CalendarWidget(
              focusedDay: state.focusedDay,
              calendarStartDay: state.calendarStartDay,
              calendarEndDay: state.calendarEndDay,
              isDayAvailableForAppointments: ref.read(bookAppointmentNotifierProvider(uid).notifier).isDayAvailableForAppointments,
              highlightDays: [state.selectedDay],
              onPageChanged: (newFocusedDay) {
                notifier.setFocusedDay(newFocusedDay);
              },
              onDaySelected: (day) {
                notifier.selectDay(day);
              },
            ),
            DropdownButton<DateTime>(
              value: state.selectedSlot,
              hint: Text(availableSlots.isEmpty ? 'Nenhum horario disponivel' : 'Selecione Horario', style: Theme.of(context).textTheme.bodyMedium),
              items: availableSlots.map((slot) {
                return DropdownMenuItem<DateTime>(
                  value: slot,
                  child: Text(Utils.formatTime(slot), style: Theme.of(context).textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: notifier.selectAppointmentSlot,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                try {
                  await notifier.requestAppointment();
                } catch (e, st) {
                  if (mounted) {
                    print(e);
                    print(st);
                    ErrorDialog.show('Occoreu um erro ao marcar sessão, tente novamente mais tarde.');
                  }

                  return;
                }

                if (!mounted) {
                  return;
                }

                await BaseDialog.show(title: 'Sucesso', body: Text('Pedido foi enviado!'));

                if (!mounted) {
                  return;
                }

                Navigator.pop(context);
              },
              child: const Text('Marcar consulta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget mobilePage() {
    return const Placeholder();
  }
}
