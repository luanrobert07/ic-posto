import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/screens/base_page.dart';

class AgentHomeScreen extends ConsumerStatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  ConsumerState<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends ConsumerState<AgentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    AuthService authService = ref.watch(authServiceProvider);

    return BasePage(
      webPage: webPage(context, authService),
      mobilePage: mobilePage(context, authService),
    );
  }

  Widget webPage(BuildContext context, AuthService authService) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          children: [
            Text('AGENTE WEB'),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                await authService.signOut();
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget mobilePage(BuildContext context, AuthService authService) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          children: [
            Text('AGENTE MOBILE'),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                await authService.signOut();
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
