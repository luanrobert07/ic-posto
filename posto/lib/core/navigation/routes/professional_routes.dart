import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/auth/logic/auth_service.dart';
import 'package:posto/features/professional/appointments/ui/professional_appointments_screen.dart';

import '../../../features/professional/profile_settings/base/ui/professional_profile_settings_screen.dart';
import '../../../features/professional/profile_settings/schedule_exceptions/ui/schedule_exceptions_screen.dart';
import '../../../features/professional/home/ui/professional_home_screen.dart';
import '../../auth/state_management/user_type.dart';
import '../../auth/state_management/user_type_provider.dart';

String? _checkAccess(BuildContext context, GoRouterState state) {
  final ref = ProviderScope.containerOf(context, listen: false);
  final UserType userType = ref.read(userTypeNotifierProvider);
  final notifier = ref.read(authServiceProvider);

  if (userType == UserType.patient) {
    print('Redirecting to professional home');
    return '/patient/home';
  }

  if (userType == UserType.agent) {
    print('Redirecting to agent home');
    return '/agent/home';
  }

  if (userType != UserType.professional) {
    print('Signing out, account type: $userType');
    notifier.signOut();
    return '/auth';
  }

  return null;
}

List<GoRoute> professionalRoutes = [
  GoRoute(
    path: '/professional',
    redirect: _checkAccess,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => PopScope(
          canPop: false,
          child: ProfessionalHomeScreen(),
        ),
        redirect: _checkAccess,
      ),
      GoRoute(
        path: '/profile_settings',
        builder: (context, state) => const ProfessionalProfileSettingsScreen(),
        redirect: _checkAccess,
        routes: [
          GoRoute(
            path: '/schedule_exceptions',
            redirect: _checkAccess,
            builder: (context, state) => ScheduleExceptionScreen(),
          ),
        ]
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const ProfessionalAppointmentsScreen(),
        redirect: _checkAccess,
      ),
    ],
  ),
];
