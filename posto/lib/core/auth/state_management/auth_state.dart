import 'package:flutter/cupertino.dart';

import 'user_type.dart';

class AuthState {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final UserType accountType;

  AuthState({
    TextEditingController? emailController,
    TextEditingController? passwordController,
    this.accountType = UserType.patient,
  })  : emailController = emailController ?? TextEditingController(),
        passwordController = passwordController ?? TextEditingController();

  AuthState copyWith({UserType? accountType}) {
    return AuthState(
      emailController: emailController,
      passwordController: passwordController,
      accountType: accountType ?? this.accountType,
    );
  }
}
