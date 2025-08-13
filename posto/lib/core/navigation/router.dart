import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/navigation/routes/agent_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/user_type.dart';
import 'package:posto/core/auth/state_management/user_type_provider.dart';
import 'package:posto/core/navigation/routes/auth_routes.dart';
import 'package:posto/core/navigation/routes/patient_routes.dart';
import 'package:posto/core/navigation/routes/professional_routes.dart';
import 'package:posto/core/navigation/routes/shared_routes.dart';

import '../auth/logic/auth_service.dart';

part 'router.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
class GoRouterNotifier extends _$GoRouterNotifier {
  UserType? _oldUserType;
  UserType? _userType;

  Uri currentRoute() {
    return state.routeInformationProvider.value.uri;
  }

  bool isCurrentRouteIn(List<String> possibleRoutes) {
    final route = currentRoute();
    final path = route.path;
    return possibleRoutes.any((r) => path.contains(r));
  }

  @override
  GoRouter build() {
    final authStateStream = ref.watch(authStreamProvider);
    _oldUserType = _userType;
    _userType = ref.watch(userTypeNotifierProvider);

    return GoRouter(
      initialLocation: '/auth',
      navigatorKey: rootNavigatorKey,
      routes: [
        ...authRoutes,
        ...professionalRoutes,
        ...patientRoutes,
        ...agentRoutes,
        ...sharedRoutes,
      ],
      redirect: (context, state) {
        final user = authStateStream.value;

        // Redirect to auth page anytime the user is not logged in
        if (user == null) {
          print('Redirecting to auth page since no user was found');
          return '/auth';
        }

        if (_userType == UserType.notLoggedIn) {
          print('Redirecting to splash page while usertype is still being fetched');
          return '/splash';
        }

        if (_userType == UserType.none) {
          print('Redirecting to user role selection');
          return '/role_selection';
        }

        if (_oldUserType == UserType.notLoggedIn && _userType != _oldUserType) {
          ref.read(authServiceProvider).onLogin();
          _oldUserType = _userType;
        }

        // Redirect based on user type only when in auth screen
        if (state.fullPath == '/auth') {
          if (_userType == UserType.patient) {
            print('Redirecting to /patient/home');
            return '/patient/home';
          }
          if (_userType == UserType.professional) {
            print('Redirecting to /professional/home');
            return '/professional/home';
          }
          if (_userType == UserType.agent) {
            print('Redirecting to /agent/home');
            return '/agent/home';
          }
        }

        return null;
      },
    );
  }
}
