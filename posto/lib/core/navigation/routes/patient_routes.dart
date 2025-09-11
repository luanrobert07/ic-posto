import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/auth/state_management/user_type_provider.dart';
import 'package:posto/features/patient/appointments/ui/patient_appointments_screen.dart';
import 'package:posto/features/patient/book_appointment/ui/book_appointment_screen.dart';
import 'package:posto/features/patient/home/ui/patient_home_screen.dart';
import 'package:posto/features/patient/search_professionals/ui/search_professional_screen.dart';

import '../../../features/patient/chats/ui/patient_chats_screen.dart';
import '../../../features/patient/profile_settings/ui/patient_profile_settings_screen.dart';
import '../../auth/state_management/user_type.dart';
import '../../auth/logic/auth_service.dart';

String? _checkAccess(BuildContext context, GoRouterState state) {
  final ref = ProviderScope.containerOf(context, listen: false);
  final UserType userType = ref.read(userTypeNotifierProvider);
  final notifier = ref.read(authServiceProvider);

  if (userType == UserType.professional) {
    print('Redirecting to professional home');
    return '/professional/home';
  }

  if (userType == UserType.agent) {
    print('Redirecting to agent home');
    return '/agent/home';
  }

  if (userType != UserType.patient) {
    print('Signing out, account type: $userType');
    notifier.signOut();
    return '/auth';
  }

  return null;
}

List<GoRoute> patientRoutes = [
  GoRoute(
    path: '/patient',
    redirect: _checkAccess,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => PopScope(
          canPop: false,
          child: PatientHomeScreen(),
        ),
        redirect: _checkAccess,
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchProfessionalScreen(),
        redirect: _checkAccess,
        routes: [
          GoRoute(
            path: '/appointment',
            builder: (context, state) => const BookAppointmentScreen(),
            redirect: _checkAccess,
          ),
        ]
      ),
      GoRoute(
        path: '/profile_settings',
        builder: (context, state) => const PatientProfileSettingsScreen(),
        redirect: _checkAccess,
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const PatientAppointmentsScreen(),
        redirect: _checkAccess,
      ),
      GoRoute(
        path: '/chats',
        redirect: _checkAccess,
        builder: (context, state) => const PatientChatsScreen(),
      ),
    ],
  ),
];
