import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/features/shared/screens/base_page.dart';

import '../../../../core/auth/logic/auth_service.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
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
            ElevatedButton(
              onPressed: () {
                context.push('/patient/search');
              },
              child: const Text("Lista de medicos"),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                context.push('/patient/appointments');
              },
              child: const Text("Consultas"),
            ),
            // const SizedBox(height: 25),
            // ElevatedButton(
            //   onPressed: () {
            //     context.push('/patient/chats');
            //   },
            //   child: const Text("Chats"),
            // ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                context.push('/patient/profile_settings');
              },
              child: const Text("Configurações de perfil"),
            ),
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
    return const Placeholder();
  }
}
