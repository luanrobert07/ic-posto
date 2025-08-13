import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/features/shared/screens/base_page.dart';

import '../../../core/auth/logic/auth_service.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return BasePage(
      webPage: webPage(authService),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage(AuthService authService) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  Widget mobilePage() {
    return const Placeholder();
  }
}
