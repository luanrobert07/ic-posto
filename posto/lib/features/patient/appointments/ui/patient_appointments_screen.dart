import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/features/patient/appointments/state_management/patient_appointments_state.dart';
import 'package:posto/features/shared/widgets/conditional_widget.dart';

import '../../../shared/screens/base_page.dart';
import '../state_management/patient_appointments_provider.dart';

class PatientAppointmentsScreen extends ConsumerStatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  ConsumerState<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends ConsumerState<PatientAppointmentsScreen> {
  late PatientAppointmentsState state;
  late PatientAppointmentsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    state = ref.watch(patientAppointmentsNotifierProvider);
    notifier = ref.read(patientAppointmentsNotifierProvider.notifier);

    return BasePage(
      webPage: webPage(),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage() {
    return ConditionalWidget(
      condition: state.isLoadingProfiles,
      whenTrue: (context) {
        return const Center(child: CircularProgressIndicator());
      },
      whenFalse: (context) {
        final appointments = state.profile!.bookedAppointments;

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: appointments.length,
          itemBuilder: (context, id) {
            final appointment = appointments[id];
            final user = notifier.getProfessionalProfileFromId(appointment.professionalId!);

            return Text('${user.name}: ${appointment.start.toDate()}-${appointment.end.toDate()}');
          },
        );
      },
    );
  }

  Widget mobilePage() {
    return const Placeholder();
  }
}
