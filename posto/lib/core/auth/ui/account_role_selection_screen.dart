import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/core/auth/logic/auth_service.dart';
import 'package:posto/core/auth/state_management/user_type.dart';
import 'package:posto/core/auth/state_management/user_type_provider.dart';
import 'package:posto/features/shared/screens/base_page.dart';

import '../../../features/shared/features/dialogs/error_dialog.dart';

class AccountRoleSelectionScreen extends ConsumerStatefulWidget {
  const AccountRoleSelectionScreen({super.key});

  @override
  ConsumerState<AccountRoleSelectionScreen> createState() => _AccountRoleSelectionScreenState();
}

class _AccountRoleSelectionScreenState extends ConsumerState<AccountRoleSelectionScreen> {
  late AuthService authService;
  late UserTypeNotifier userTypeNotifier;

  @override
  Widget build(BuildContext context) {
    authService = ref.read(authServiceProvider);
    userTypeNotifier = ref.read(userTypeNotifierProvider.notifier);

    return BasePage(
      webPage: webPage(),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage() {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your account needs a few extra steps before it is ready'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                try {
                  await userTypeNotifier.configureUserType(UserType.patient, '.', '.');
                } catch (e) {
                  print(e);
                  if (mounted) {
                    ErrorDialog.show('Occoreu um erro ao configurar conta.');
                  }
                }
              },
              child: const Text("Configure account as patient"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await userTypeNotifier.configureUserType(UserType.professional, '.', '.');
                } catch (e) {
                  print(e);
                  if (mounted) {
                    ErrorDialog.show('Occoreu um erro ao configurar conta.');
                  }
                }
              },
              child: const Text("Configure account as professional"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authService.signOut();
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget mobilePage() {
    return const Placeholder();
  }
}
