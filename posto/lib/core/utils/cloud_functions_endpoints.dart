import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:posto/core/encryption/exceptions/key_not_found_exception.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/shared/features/appointment/models/appointment.dart';

import '../../features/shared/features/providers/patient_profile_provider/patient_profile.dart';
import '../../features/shared/features/providers/professional_profile_provider/professional_profile.dart';

final functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');

Map<String, dynamic> _getData(final result, {void Function(String)? customError}) {
  final data = result.data as Map<String, dynamic>;

  if (!data['success']) {
    if (customError != null) {
      customError(data['message']);
    }

    throw Exception('Error on backend: ${data['message']}');
  }

  return data;
}

Future<void> addPatientRoleAPI(String name, String email) async {
  print('addPatientRoleAPI');
  final result = await functions.httpsCallable('addPatientRole').call({
    'name': name,
    'email': email,
  });
  _getData(result);
}

Future<void> addProfessionalRoleAPI(String name, String email) async {
  print('addProfessionalRoleAPI');
  final result = await functions.httpsCallable('addProfessionalRole').call({
    'name': name,
    'email': email,
  });
  _getData(result);
}

Future<void> addAgentRoleAPI(String name, String email) async {
  print('addAgentRoleAPI');
  final result = await functions.httpsCallable('addAgentRole').call({
    'name': name,
    'email': email,
  });
  _getData(result);
}

Future<void> requestAppointmentAPI(Appointment appointment) async {
  print('requestAppointmentAPI');
  final result = await functions.httpsCallable('requestAppointment').call(appointment.toJson());
  _getData(result);
}

Future<void> acceptPendingAppointmentAPI(Appointment appointment) async {
  print('acceptPendingAppointmentAPI');
  final result = await functions.httpsCallable('acceptPendingAppointment').call({
    'appointment': appointment.toCloudFunctionJson(),
  });
  _getData(result);
}

Future<void> declinePendingAppointmentAPI(Appointment appointment) async {
  print('declinePendingAppointmentAPI');
  final result = await functions.httpsCallable('declinePendingAppointment').call({
    'appointment': appointment.toCloudFunctionJson(),
  });
  _getData(result);
}

Future<Map<String, dynamic>> searchProfessionalsAPI(String? startAfter) async {
  print('searchProfessionalsAPI');
  final result = await functions.httpsCallable('searchProfessionals').call({
    'startAfter': startAfter,
  });
  return _getData(result);
}

Future<ProfessionalProfile> getProfessionalFromIdAPI(String professionalId) async {
  print('getProfessionalFromIdAPI');
  final result = await functions.httpsCallable('getProfessionalFromId').call({
    'professionalId': professionalId,
  });
  final data = _getData(result);
  return ProfessionalProfile.fromMap(data['id'], data);
}

Future<Map<String, ProfessionalProfile>> getMultipleProfessionalsFromIdsAPI(List<String> userIds) async {
  print('getMultipleProfessionalsFromIdsAPI (${userIds.length})');
  final result = await functions.httpsCallable('getMultipleProfessionalsFromIds').call({
    'professionalIds': userIds,
  });
  final data = _getData(result);
  final userMap = <String, ProfessionalProfile>{};

  for (final user in data['professionals']) {
    userMap[user['id']] = ProfessionalProfile.fromMap(user['id'], Map<String, dynamic>.from(user as Map));
  }

  return userMap;
}

Future<Map<String, PatientProfile>> getMultiplePatientsFromIdsAPI(List<String> userIds) async {
  print('getMultiplePatientsFromIdsAPI (${userIds.length})');
  final result = await functions.httpsCallable('getMultiplePatientsFromIds').call({
    'patientIds': userIds,
  });
  final data = _getData(result);
  final userMap = <String, PatientProfile>{};

  for (final user in data['patients']) {
    userMap[user['id']] = PatientProfile.fromMap(user['id'], Map<String, dynamic>.from(user as Map));
  }

  return userMap;
}

Future<PatientProfile> getPatientFromIdAPI(String patientId) async {
  print('getPatientFromIdAPI');
  final result = await functions.httpsCallable('getPatientFromId').call({
    'patientId': patientId,
  });
  final data = _getData(result);
  return PatientProfile.fromMap(data['id'], data);
}

Future<void> updateProfessionalProfileAPI(Map<String, dynamic> data) async {
  print('updateProfessionalProfileAPI');
  final result = await functions.httpsCallable('updateProfessionalProfile').call(data);
  _getData(result);
}

Future<void> updatePatientProfileAPI(Map<String, dynamic> data) async {
  print('updatePatientProfileAPI');
  final result = await functions.httpsCallable('updatePatientProfile').call(data);
  _getData(result);
}

Future<String> getPublicKeyAPI(String professionalId) async {
  print('getPublicKeyAPI');
  final result = await functions.httpsCallable('getPublicKey').call({
    'professionalId': professionalId,
  });
  final data = _getData(result, customError: (error) {
    if (error == KeyNotFoundException.error) {
      throw KeyNotFoundException();
    }
  });
  return data['publicKey'];
}

Future<void> createPublicKeyAPI() async {
  print('createPublicKeyAPI');
  final result = await functions.httpsCallable('createPublicKey').call();
  _getData(result);
}

Future<String> decryptDekAPI(String encryptedDek, String publicKey) async {
  print('decryptDekAPI');
  final result = await functions.httpsCallable('decryptDek').call({
    'encryptedDek': encryptedDek,
    'publicKey': publicKey,
  });
  final data = _getData(result);
  return data['dek'];
}

Future<String> createChatAPI(String participantId, String dek) async {
  print('createChatAPI');
  final result = await functions.httpsCallable('createChat').call({
    'participantId': participantId,
    'dek': dek,
  });
  final data = _getData(result);
  return data['id'];
}

Future<String> getChatKeyAPI(String chatId, String publicKey) async {
  print('getChatKeyAPI');
  final result = await functions.httpsCallable('getChatKey').call({
    'chatId': chatId,
    'publicKey': publicKey,
  });
  final data = _getData(result);
  return data['dek'];
}

Future<void> sendChatMessageAPI(String chatId, Map<String, dynamic> data) async {
  print('sendChatMessageAPI');
  final result = await functions.httpsCallable('sendChatMessage').call({
    'chatId': chatId,
    'data': data,
  });
  _getData(result);
}

Future<void> removeChatNotificationAPI(String chatId) async {
  print('removeChatNotificationAPI');
  final result = await functions.httpsCallable('removeChatNotification').call({
    'chatId': chatId,
  });
  _getData(result);
}

Future<Timestamp> getServerTimestampAPI() async {
  print('getServerTimestampAPI');
  final result = await functions.httpsCallable('getServerTimestamp').call();
  final data = _getData(result);
  return Utils.parseTimestamp(data['serverTimestamp'])!;
}
