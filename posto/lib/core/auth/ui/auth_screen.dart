import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/core/auth/state_management/auth_provider.dart';
import 'package:posto/features/shared/widgets/edit_text.dart';

import '../../../features/shared/features/dialogs/error_dialog.dart';
import '../state_management/user_type.dart';
import '../state_management/auth_state.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late AuthState state;
  late AuthNotifier notifier;

  void login() async {
    try {
      await notifier.logIn();
    } catch (e) {
      if (mounted) {
        ErrorDialog.show('Occoreu um erro ao logar, tente novamente');
      }
    }
  }

  void singup() async {
    try {
      await notifier.singUp();
    } catch (e) {
      if (mounted) {
        ErrorDialog.show('Occoreu um erro ao criar conta.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    state = ref.watch(authNotifierProvider);
    notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(flex: 1),
            Text(
              "Login",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 40),
            EditText(
              textInputType: TextInputType.emailAddress,
              leftIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
              hint: 'Email',
              controller: state.emailController,
              autofocus: false,
            ),
            EditText(
              isPassword: true,
              leftIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
              hint: 'Senha',
              controller: state.passwordController,
              autofocus: false,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                state.emailController.text = 'victorgorgal@gmail.com';
                state.passwordController.text = 'senha12345';
                login();
              },
              child: const Text("Paciente Auto Log in"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                state.emailController.text = 'victorgorgal2@gmail.com';
                state.passwordController.text = 'senha12345';
                login();
              },
              child: const Text("Medico Auto Log in"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                state.emailController.text = 'victorgorgal3@gmail.com';
                state.passwordController.text = 'senha12345';
                login();
              },
              child: const Text("Agente Auto Log in"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                login();
              },
              child: const Text("Log in"),
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              direction: Axis.vertical,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              isSelected: [
                state.accountType == UserType.patient,
                state.accountType == UserType.professional,
                state.accountType == UserType.agent,
              ],
              onPressed: (int index) {
                if (index == 0) {
                  notifier.setAccountType(UserType.patient);
                  return;
                }
                if (index == 1) {
                  notifier.setAccountType(UserType.professional);
                  return;
                }
                if (index == 2) {
                  notifier.setAccountType(UserType.agent);
                  return;
                }
              },
              children: const [
                Text('Paciente'),
                Text('Medico'),
                Text('Agente'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                singup();
              },
              child: const Text("Sign Up"),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
