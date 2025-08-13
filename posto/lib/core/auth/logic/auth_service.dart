import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/user_type_provider.dart';
import 'package:posto/core/services/notification_service/notification_service.dart';
import 'package:posto/features/shared/features/dialogs/base_dialog.dart';
import 'package:posto/features/shared/features/providers/patient_profile_provider/private_patient_profile_service.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/private_professional_profile_service.dart';

import '../../utils/cloud_functions_endpoints.dart';
import '../state_management/user_type.dart';

part 'auth_service.g.dart';

@riverpod
Stream<User?> authStream(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
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
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> signUp(String email, String password, UserType userType) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    await auth.createUserWithEmailAndPassword(email: email, password: password);
    await userTypeNotifier.configureUserType(userType, '.', email);
  }

  Future<void> signIn(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signInWithEmailAndPassword(email: email, password: password);
    await userTypeNotifier.getUserType();
  }

  Future<void> signOut() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      print('Singing out');
      await _onBeforeSignOut();
      await auth.signOut();
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
        // ref.read(encryptionNotifierProvider.notifier).loadPublicKey(null);
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
    final serverTime = serverTimestamp.toDate().toUtc();

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
