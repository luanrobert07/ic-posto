import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../../core/services/firestore_service/firestore_service.dart';
import '../../../../../core/utils/cloud_functions_endpoints.dart';
import '../../appointment/models/appointment.dart';
import 'patient_profile.dart';

part 'private_patient_profile_service.g.dart';

@riverpod
PrivatePatientProfileService privatePatientProfileService(Ref ref) {
  ref.keepAlive();
  return PrivatePatientProfileService(ref);
}

class PrivatePatientProfileService extends FirestoreService {
  final Ref ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late CollectionReference collection = _db.collection('patientProfiles');

  StreamSubscription? _profileListener;
  final List<Function(PatientProfile?, PatientProfile?)> _profileListenerCallbacks = [];

  PatientProfile? profile;
  PatientProfile? oldProfile;

  PrivatePatientProfileService(this.ref);

  Future<void> updateProfile(Map<String, dynamic> data) async {
    return updatePatientProfileAPI(data);
  }

  Future<void> updateMessagingToken(String token) async {
    return updateProfile({
      'firebaseMessagingToken': token,
    });
  }

  PatientProfile? getProfile() {
    return profile;
  }

  PatientProfile? getOldProfile() {
    return oldProfile;
  }

  Stream<PatientProfile?> _profileStream() {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    return collection
        .doc(userId)
        .snapshots()
        .map((doc) => PatientProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>));
  }

  Future<void> createProfileListener() async {
    if (_profileListener != null) return;

    final completer = Completer<void>();
    print('Initializing patient profile stream with ${_profileListenerCallbacks.length} callbacks');
    _profileListener = _profileStream().listen((profile) {
      print('Patient profile update');

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

  void addProfileListenerCallback(Function(PatientProfile?, PatientProfile?) callback, {bool triggerOnCreate = false}) {
    _profileListenerCallbacks.add(callback);

    if (triggerOnCreate) callback(oldProfile, profile);
  }

  void removeProfileListenerCallback(Function(PatientProfile?, PatientProfile?) callback) {
    _profileListenerCallbacks.remove(callback);
  }

  Future<PatientProfile?> getProfileFromId(String userId) async {
    return get(collection, userId, PatientProfile.fromMap);
  }

  void startCleanupRoutine() async {
    await _cleanUpProfile();

    Timer timer = Timer.periodic(Duration(minutes: 5), (_) async {
      await _cleanUpProfile();
    });
    ref.onDispose(() => timer.cancel());
  }

  // Cleans appointments that ends in 6 minutes from now (1 + routine period of 5)
  Future<void> _cleanUpProfile() async {
    print('Appointment cleanup routine');
    if (profile!.bookedAppointments.isEmpty && profile!.pendingAppointments.isEmpty) return;

    final List<Appointment> passedAppointments = [];
    final now = Timestamp.fromDate(Timestamp.now().toDate().add(Duration(minutes: 6)));
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

    // move all appointments to history
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    List<Appointment> appointments = [];
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Apply updates in transaction
      transaction.update(collection.doc(userId), {
        'bookedAppointments': FieldValue.arrayRemove(passedAppointments.map((a) => a.toJson()).toList()),
        'pendingAppointments': FieldValue.arrayRemove(expiredAppointments.map((a) => a.toJson()).toList()),
      });

      final now = Timestamp.now();
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

      addAll(
        collection.doc(userId).collection('appointment_history'),
        appointments, (appointment) => appointment.toJson(),
        transaction,
      );
    });

    print('Successfully cleaned ${appointments.length} appointments');
  }
}
