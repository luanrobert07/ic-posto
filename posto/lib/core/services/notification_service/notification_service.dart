import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/user_type.dart';
import 'package:posto/core/auth/state_management/user_type_provider.dart';
import 'package:posto/core/services/notification_service/notification_state.dart';

import '../../../features/shared/features/notifications/base_notification.dart';
import '../../../features/shared/features/providers/patient_profile_provider/patient_profile.dart';
import '../../../features/shared/features/providers/patient_profile_provider/private_patient_profile_service.dart';
import '../../../features/shared/features/providers/professional_profile_provider/private_professional_profile_service.dart';
import '../../../features/shared/features/providers/professional_profile_provider/professional_profile.dart';
import '../../navigation/router.dart';
import '../../utils/cloud_functions_endpoints.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  @override
  NotificationState build() {
    return NotificationState();
  }

  void createMessagingTokenListener() {
    if (kIsWeb) return;

    print('Creating messaging token listener');
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("FCM token refreshed: $newToken");
      _updateMessagingToken(newToken);
    });

    FirebaseMessaging.instance.getToken().then((token) {
      print("Current FCM token: $token");
      _updateMessagingToken(token);
    });

    _setupOnClickNotification();
  }

  void _setupOnClickNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleOnClickNotification(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      _handleOnClickNotification(message);
    });
  }

  void _handleOnClickNotification(RemoteMessage? message) {
    if (message == null) return;

    final userType = ref.read(userTypeNotifierProvider);
    final screen = message.data['screen'];

    // ToDo
  }

  Future<void> _updateMessagingToken(String? newToken) async {
    if (newToken == null) return;

    final userType = ref.read(userTypeNotifierProvider);

    final dynamic profileProvider = switch (userType) {
      UserType.patient => ref.read(privatePatientProfileServiceProvider),
      UserType.professional => ref.read(privateProfessionalProfileServiceProvider),
      _ => null,
    };
    if (profileProvider == null) return;

    final dynamic profile = profileProvider.getProfile();
    if (profile?.firebaseMessagingToken == newToken) return;

    print('Updating messaging token');
    return profileProvider.updateMessagingToken(newToken);
  }

  Future<void> createFirestoreNotificationListener() async {
    final userType = ref.read(userTypeNotifierProvider);

    switch (userType) {
      case UserType.patient:
        return ref.read(privatePatientProfileServiceProvider).addProfileListenerCallback(_patientProfileHandler);
      case UserType.professional:
        return ref.read(privateProfessionalProfileServiceProvider).addProfileListenerCallback(_professionalProfileHandler);
      default:
        print('ERROR while configuring profile listener');
    }
  }

  void stopListening() {
    ref.read(privatePatientProfileServiceProvider).removeProfileListenerCallback(_patientProfileHandler);
    ref.read(privateProfessionalProfileServiceProvider).removeProfileListenerCallback(_professionalProfileHandler);
  }

  Future<void> removeChatNotifications(String chatId) async {
    final userType = ref.read(userTypeNotifierProvider);

    switch (userType) {
      case UserType.patient:
      case UserType.professional:
        return removeChatNotificationAPI(chatId);

      default:
        print('ERROR while removing chat notifications, wrong usertype');
    }
  }

  void _patientProfileHandler(PatientProfile? oldProfile, PatientProfile? profile) {
    if (profile == null) return;

    print('notification patient handler');

    state = state.copyWith(
      chatNotifications: profile.chatNotifications,
    );
  }

  void _professionalProfileHandler(ProfessionalProfile? oldProfile, ProfessionalProfile? profile) {
    if (profile == null) return;

    print('notification professional handler');

    // if (_hasPendingAppointments(oldProfile, profile)) {
    //   _showAppointmentNotification();
    // }

    state = state.copyWith(
      chatNotifications: profile.chatNotifications,
      pendingAppointments: profile.pendingAppointments,
    );
  }

  bool _hasPendingAppointments(ProfessionalProfile? oldProfile, ProfessionalProfile? profile) {
    try {
      final oldProfileNotifications = oldProfile?.pendingAppointments.length ?? 0;
      final newProfileNotifications = profile?.pendingAppointments.length ?? 0;

      return newProfileNotifications > oldProfileNotifications;
    } catch (e) {
      print('Notification error 2: $e');
      return false;
    }
  }

  void _showAppointmentNotification() {
    print('Received appointment notification');

    final blockedRoutes = ['/appointments'];
    if (_isOnRoute(blockedRoutes)) return;

    BaseNotification().show(child: Text('Received appointment notification'));
  }

  bool _isOnRoute(List<String> possibleRoutes) {
    return ref.read(goRouterNotifierProvider.notifier).isCurrentRouteIn(possibleRoutes);
  }
}
