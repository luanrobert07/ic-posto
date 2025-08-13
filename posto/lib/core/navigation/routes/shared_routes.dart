import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/features/shared/screens/splash_screen.dart';

List<GoRoute> sharedRoutes = [
  GoRoute(
    path: '/splash',
    builder: (context, state) => PopScope(
      canPop: false,
      child: SplashScreen(),
    ),
  ),
];
