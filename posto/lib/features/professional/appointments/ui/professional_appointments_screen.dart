import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/professional/appointments/state_management/professional_appointments_provider.dart';
import 'package:posto/features/professional/appointments/state_management/professional_appointments_state.dart';
import 'package:posto/features/shared/features/dialogs/base_dialog.dart';
import 'package:posto/features/shared/features/dialogs/hero_dialog_source.dart';
import 'package:posto/features/shared/widgets/edit_text.dart';

import '../../../shared/features/dialogs/information_hero_dialog.dart';
import '../../../shared/features/providers/patient_profile_provider/patient_profile.dart';
import '../../../shared/screens/base_page.dart';

class ProfessionalAppointmentsScreen extends ConsumerStatefulWidget {
  const ProfessionalAppointmentsScreen({super.key});

  @override
  ConsumerState<ProfessionalAppointmentsScreen> createState() => _ProfessionalAppointmentsScreenState();
}

class _ProfessionalAppointmentsScreenState extends ConsumerState<ProfessionalAppointmentsScreen> {
  late ProfessionalAppointmentsState state;
  late ProfessionalAppointmentsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    state = ref.watch(professionalAppointmentsNotifierProvider);
    notifier = ref.read(professionalAppointmentsNotifierProvider.notifier);

    return BasePage(
      webPage: webPage(),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage() {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Pedidos pendentes:'),
                  const SizedBox(height: 25),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.pendingAppointments.length,
                      itemBuilder: (context, id) {
                        final appointment = state.pendingAppointments[id];
                        final user = notifier.getPatientProfileFromId(appointment.patientId!);

                        return ListTile(
                          title: Row(
                            children: [
                              Expanded(child: Text(user.name)),
                              if (appointment.hasConflict)
                                const Icon(Icons.warning, color: Colors.amber),
                            ],
                          ),
                          subtitle: Text('${appointment.start.toDate()} - ${appointment.end.toDate()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await notifier.declinePendingAppointment(appointment);
                                },
                                child: const Text('Decline'),
                              ),
                              const SizedBox(width: 15),
                              ElevatedButton(
                                onPressed: () async {
                                  await notifier.acceptPendingAppointment(appointment);
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Pedidos aceitos:'),
                    const SizedBox(height: 25),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.bookedAppointments.length,
                      itemBuilder: (context, id) {
                        final appointment = state.bookedAppointments[id];
                        final user = notifier.getPatientProfileFromId(appointment.patientId!);
                
                        return ListTile(
                          title: Row(
                            children: [
                              Text(user.name),
                              const SizedBox(width: 25),
                
                              if (appointment.hasConflict)
                                HeroDialogSource(
                                  tag: '${appointment.start.seconds}',
                                  splashRadius: 24,
                                  icon: Icon(Icons.error_outline, color: Colors.amber),
                                    heroDialogBuilder: (context) {
                                    return InformationHeroDialog(
                                      tag: '${appointment.start.seconds}',
                                      title: 'Appointment Conflict',
                                      description:
                                      'This appointment conflicts with one of your holiday rules. If it is still pending, you can decline it and ask the patient to choose another time.\n'
                                          'If the appointment is already booked, you can choose to cancel it, although this is not recommended.\n\n'
                                          'If no action is taken, the appointment will proceed as normal.',
                                    );
                                  },
                                ),
                            ],
                          ),
                          subtitle: Text('${appointment.start.toDate()} - ${appointment.end.toDate()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  BaseDialog.show(
                                    title: 'Cancel Appointment',
                                    body: Column(
                                      children: [
                                        Text(
                                          'Are you sure you want to cancel this appointment? You can write a message that will be sent to the '
                                              'patient explaining the reason for this decision.\n\n'
                                              'Please note that frequent cancellations may result in a warning being displayed on your profile, '
                                              'informing others that you tend to cancel appointments.',
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        EditText(),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                    cancelText: 'Back',
                                    cancelCallback: (context) {
                                      context.pop();
                                    },
                                    confirmText: 'Confirm',
                                    confirmCallback: (context) {
                                      context.pop();
                                    },
                                  );
                                },
                                child: const Text('Cancel Appointment'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget mobilePage() {
    return const Placeholder();
  }
}
