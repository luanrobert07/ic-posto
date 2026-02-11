import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/agent/home/ui/agent_home_screen.dart';
import '../../auth/state_management/user_type.dart';
import '../../auth/logic/auth_service.dart';
import '../../auth/state_management/user_type_provider.dart';

String? _checkAccess(BuildContext context, GoRouterState state) {
  final ref = ProviderScope.containerOf(context, listen: false);
  final UserType userType = ref.read(userTypeNotifierProvider);

  if (userType == UserType.patient) {
    print('Redirecting to patient home');
    return '/doctor/home';
  }

  if (userType == UserType.professional) {
    print('Redirecting to doctor home');
    return '/agent/home';
  }

  if (userType != UserType.agent) {
    print('Signing out, account type: $userType');
    ref.read(authServiceProvider).signOut();
    return '/auth';
  }

  return null;
}

List<GoRoute> agentRoutes = [
  GoRoute(
    path: '/agent',
    redirect: _checkAccess,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const AgentDashboardScreen(),
        redirect: _checkAccess,
      ),
    ],
  ),
];
