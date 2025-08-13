import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/auth_state.dart';

import 'user_type.dart';
import '../logic/auth_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return AuthState();
  }

  void setAccountType(UserType accountType) {
    UserType oldType = state.accountType;

    if (oldType == accountType) return;

    state = state.copyWith(accountType: accountType);
  }

  Future<void> logIn() async {
    return ref.read(authServiceProvider).signIn(state.emailController.text, state.passwordController.text);
  }

  Future<void> singUp() async {
    return ref.read(authServiceProvider).signUp(state.emailController.text, state.passwordController.text, state.accountType);
  }

  Future<void> signOut() async {
    return ref.read(authServiceProvider).signOut();
  }
}
