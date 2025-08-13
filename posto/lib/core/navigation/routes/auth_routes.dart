import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/auth/ui/account_role_selection_screen.dart';
import 'package:posto/core/auth/ui/auth_screen.dart';

List<GoRoute> authRoutes = [
  GoRoute(
    path: '/auth',
    builder: (context, state) => PopScope(
      canPop: false,
      child: AuthScreen(),
    ),
  ),
  GoRoute(
    path: '/role_selection',
    builder: (context, state) => PopScope(
      canPop: false,
      child: AccountRoleSelectionScreen(),
    ),
  ),
];
