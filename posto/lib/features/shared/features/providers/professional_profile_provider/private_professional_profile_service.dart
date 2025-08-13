import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/utils/cloud_functions_endpoints.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/professional_profile.dart';
import 'package:posto/features/shared/features/appointment/models/appointment.dart';

import '../../../../../core/services/firestore_service/firestore_service.dart';
import '../../../../professional/profile_settings/exceptions_rule_editor/models/exception_rule_model.dart';

part 'private_professional_profile_service.g.dart';

@Riverpod(keepAlive: true)
PrivateProfessionalProfileService privateProfessionalProfileService(Ref ref) {
  return PrivateProfessionalProfileService(ref);
}

class PrivateProfessionalProfileService extends FirestoreService {
  final Ref ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late CollectionReference collection = _db.collection('professionalProfiles');

  StreamSubscription? _profileListener;
  final List<Function(ProfessionalProfile?, ProfessionalProfile?)> _profileListenerCallbacks = [];

  ProfessionalProfile? profile;
  ProfessionalProfile? oldProfile;

  PrivateProfessionalProfileService(this.ref);

  /// Updates all fields contained in newData
  Future<void> updateProfile(Map<String, dynamic> newData) async {
    return updateProfessionalProfileAPI(newData);
  }

  Future<void> updateMessagingToken(String token) async {
    return updateProfile({
      'firebaseMessagingToken': token,
    });
  }

  Future<void> updateRecentRecords(List<String> recentRecords) async {
    return updateProfile({
      'recentRecords': recentRecords,
    });
  }

  Future<void> addScheduleRulesExceptions(ExceptionRuleModel newRule) async {
    List<Map<String, dynamic>> rules = profile!.scheduleRulesExceptions.map((rule) => rule.toMap()).toList();
    rules.add(newRule.toMap());

    return updateProfile({
      'scheduleRulesExceptions': rules,
    });
  }

  Future<void> substituteScheduleRulesExceptions(ExceptionRuleModel oldRule, ExceptionRuleModel newRule) async {
    List<ExceptionRuleModel> rules = List<ExceptionRuleModel>.from(profile!.scheduleRulesExceptions);
    rules.removeWhere((rule) => rule == oldRule);
    rules.add(newRule);

    return updateProfile({
      'scheduleRulesExceptions': rules.map((rule) => rule.toMap()).toList(),
    });
  }

  ProfessionalProfile? getProfile() {
    return profile;
  }

  Stream<ProfessionalProfile?> _profileStream() {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    return collection
        .doc(userId)
        .snapshots()
        .map((doc) => ProfessionalProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>));
  }

  Future<void> createProfileListener() async {
    if (_profileListener != null) return;

    final completer = Completer<void>();
    print('Initializing professional profile stream with ${_profileListenerCallbacks.length} callbacks');
    _profileListener = _profileStream().listen((profile) {
      print('Professional profile update:');

      oldProfile = this.profile;
      this.profile = profile;

      if (!completer.isCompleted) completer.complete();

      for (Function callback in _profileListenerCallbacks) {
        callback(oldProfile, profile);
      }
    });
    ref.onDispose(() => _closeProfileListener());

    await completer.future;
  }

  Future<void> _closeProfileListener() async {
    await _profileListener?.cancel();
    _profileListener = null;
    _profileListenerCallbacks.clear();
  }

  void addProfileListenerCallback(Function(ProfessionalProfile?, ProfessionalProfile?) callback, {bool triggerOnCreate = false}) {
    _profileListenerCallbacks.add(callback);

    if (triggerOnCreate) callback(oldProfile, profile);
  }

  void removeProfileListenerCallback(Function(ProfessionalProfile?, ProfessionalProfile?) callback) {
    _profileListenerCallbacks.remove(callback);
  }

  Future<ProfessionalProfile?> getProfileFromId(String userId) async {
    return get(collection, userId, ProfessionalProfile.fromMap);
  }

  Future<void> acceptPendingAppointment(Appointment appointment) async {
    return acceptPendingAppointmentAPI(appointment);
  }

  Future<void> declinePendingAppointment(Appointment appointment) async {
    return declinePendingAppointmentAPI(appointment);
  }

  void startCleanupRoutine() async {
    await _cleanUpProfile();

    Timer timer = Timer.periodic(Duration(minutes: 5), (_) async {
      await _cleanUpProfile();
    });
    ref.onDispose(() => timer.cancel());
  }

  Future<void> _cleanUpProfile() async {
    print('Cleanup routine');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      _cleanUpAppointments(transaction);
      _cleanUpScheduleExceptionRules(transaction);
    });
  }

  /// Cleans appointments that ends in 6 minutes from now (1 + routine period of 5)
  void _cleanUpAppointments(Transaction transaction) {
    if (profile!.bookedAppointments.isEmpty && profile!.pendingAppointments.isEmpty) return;

    final List<Appointment> passedAppointments = [];
    Timestamp now = Timestamp.fromDate(Timestamp.now().toDate().add(Duration(minutes: 6)));
    for (final appointment in profile!.bookedAppointments) {
      // Break if appointment comes after now
      if (appointment.end.compareTo(now) > 0) {
        break;
      }
      passedAppointments.add(appointment);
    }

    final List<Appointment> expiredAppointments = [];
    for (final appointment in profile!.pendingAppointments) {
      // Break if appointment comes after now
      if (appointment.end.compareTo(now) > 0) {
        break;
      }
      expiredAppointments.add(appointment);
    }

    if (passedAppointments.isEmpty && expiredAppointments.isEmpty) return;

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    transaction.update(collection.doc(userId), {
      'bookedAppointments': FieldValue.arrayRemove(passedAppointments.map((a) => a.toJson()).toList()),
      'pendingAppointments': FieldValue.arrayRemove(expiredAppointments.map((a) => a.toJson()).toList()),
    });

    now = Timestamp.now();
    List<Appointment> appointments = [];
    for (final appointment in passedAppointments) {
      appointment.status = 'completed';
      appointment.lastInteractionAt = now;
    }
    for (final appointment in expiredAppointments) {
      appointment.status = 'expired';
      appointment.lastInteractionAt = now;
    }

    appointments = [...passedAppointments, ...expiredAppointments];
    appointments.sort((a, b) => a.start.compareTo(b.start));

    // move all appointments to history
    addAll(
      collection.doc(userId).collection('appointment_history'),
      appointments, (appointment) => appointment.toJson(),
      transaction,
    );

    print('Added ${appointments.length} appointments to cleanup routine');
  }

  /// Cleans schedule exceptions rules that had the last affected day already passed
  void _cleanUpScheduleExceptionRules(Transaction transaction) {
    if (profile!.scheduleRulesExceptions.isEmpty) return;

    // Makes sure the rule has already expired by comparing it to 6 minutes earlier
    DateTime now = DateTime.now().subtract(Duration(minutes: 6));
    final List<ExceptionRuleModel> expiredRules = profile!.scheduleRulesExceptions.where((rule) => rule.hasRuleExpired(now)).toList();

    if (expiredRules.isEmpty) return;

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    transaction.update(collection.doc(userId), {
      'scheduleRulesExceptions': FieldValue.arrayRemove(expiredRules.map((a) => a.toMap()).toList()),
    });

    print('Added ${expiredRules.length} exception rules to cleanup routine');
  }
}
