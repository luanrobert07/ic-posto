import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/user_type_provider.dart';
import 'package:posto/core/services/notification_service/notification_service.dart';
import 'package:posto/features/shared/features/dialogs/base_dialog.dart';
import 'package:posto/features/shared/features/providers/patient_profile_provider/private_patient_profile_service.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/private_professional_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/cloud_functions_endpoints.dart';
import '../state_management/user_type.dart';

part 'auth_service_supabase.g.dart';

@riverpod
Stream<User?> authStream(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((data) => data.session?.user);
}

@riverpod
AuthService authService(Ref ref) {
  return AuthService(ref);
}

class AuthService {
  KeepAliveLink? _link;
  final Ref ref;
  late final UserTypeNotifier userTypeNotifier = ref.read(userTypeNotifierProvider.notifier);

  AuthService(this.ref) {
    print('Building AuthService');
    _link = ref.keepAlive();
  }

  static String? getUserUid() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  Future<void> signUp(String email, String password, UserType userType) async {
    final supabase = Supabase.instance.client;

    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to create user');
    }

    await userTypeNotifier.configureUserType(userType, '.', email);
  }

  Future<void> signIn(String email, String password) async {
    final supabase = Supabase.instance.client;

    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    await userTypeNotifier.getUserType();
  }

  Future<void> signOut() async {
    final supabase = Supabase.instance.client;

    try {
      print('Signing out');
      await _onBeforeSignOut();
      await supabase.auth.signOut();
      await _onAfterSignOut();
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }

  void onLogin() async {
    print('On App Startup');

    await Future.delayed(Duration.zero);

    if (!await _isDeviceTimeCorrect()) return;

    switch (ref.read(userTypeNotifierProvider)) {
      case UserType.patient:
        await ref.read(privatePatientProfileServiceProvider).createProfileListener();
        ref.read(privatePatientProfileServiceProvider).startCleanupRoutine();
        break;
      case UserType.professional:
        await ref.read(privateProfessionalProfileServiceProvider).createProfileListener();
        ref.read(privateProfessionalProfileServiceProvider).startCleanupRoutine();
        break;
      default:
        break;
    }
  }

  Future<void> _onBeforeSignOut() async {
    ref.read(notificationServiceProvider.notifier).stopListening();
    ref.invalidate(privatePatientProfileServiceProvider);
    ref.invalidate(privateProfessionalProfileServiceProvider);
  }

  Future<void> _onAfterSignOut() async {
    userTypeNotifier.getUserType();
  }

  Future<bool> _isDeviceTimeCorrect() async {
    final serverTimestamp = await getServerTimestampAPI();
    final serverTime = DateTime.fromMillisecondsSinceEpoch(serverTimestamp * 1000).toUtc();

    final localTime = DateTime.now().toUtc();

    final difference = localTime.difference(serverTime).abs();

    if (difference.inMinutes < 10) {
      return true;
    }

    await BaseDialog.show(
      title: 'Erro de sincronização',
      body: Text('Horário do dispositivo está errado.'),
    );
    await signOut();

    return false;
  }
}
