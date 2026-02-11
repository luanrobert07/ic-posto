import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posto/core/encryption/exceptions/key_not_found_exception.dart';
import 'package:posto/features/shared/features/appointment/models/appointment.dart';
import '../../features/shared/features/providers/patient_profile_provider/patient_profile.dart';
import '../../features/shared/features/providers/professional_profile_provider/professional_profile.dart';

final supabase = Supabase.instance.client;

String _getFunctionUrl(String functionName) {
  return '${supabase.supabaseUrl}/functions/v1/$functionName';
}

Map<String, String> _getHeaders() {
  return {
    'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken ?? supabase.supabaseKey}',
    'Content-Type': 'application/json',
  };
}

Future<Map<String, dynamic>> _callFunction(
  String functionName,
  Map<String, dynamic> data, {
  void Function(String)? customError,
}) async {
  try {
    final response = await http.post(
      Uri.parse(_getFunctionUrl(functionName)),
      headers: _getHeaders(),
      body: json.encode(data),
    );

    final responseData = json.decode(response.body) as Map<String, dynamic>;

    if (!responseData['success']) {
      if (customError != null) {
        customError(responseData['message']);
      }
      throw Exception('Error on backend: ${responseData['message']}');
    }

    return responseData;
  } catch (e) {
    print('Error calling $functionName: $e');
    rethrow;
  }
}

Future<void> addPatientRoleAPI(String name, String email) async {
  print('addPatientRoleAPI');
  await _callFunction('user-roles', {
    'action': 'addPatientRole',
    'name': name,
    'email': email,
  });
}

Future<void> addProfessionalRoleAPI(String name, String email) async {
  print('addProfessionalRoleAPI');
  await _callFunction('user-roles', {
    'action': 'addProfessionalRole',
    'name': name,
    'email': email,
  });
}

Future<void> addAgentRoleAPI(String name, String email) async {
  print('addAgentRoleAPI');
  await _callFunction('user-roles', {
    'action': 'addAgentRole',
    'name': name,
    'email': email,
  });
}

Future<Map<String, dynamic>> searchProfessionalsAPI(String? startAfter) async {
  print('searchProfessionalsAPI');
  return await _callFunction('professionals', {
    'action': 'searchProfessionals',
    'startAfter': startAfter,
  });
}

Future<ProfessionalProfile> getProfessionalFromIdAPI(String professionalId) async {
  print('getProfessionalFromIdAPI');
  final data = await _callFunction('professionals', {
    'action': 'getProfessionalFromId',
    'professionalId': professionalId,
  });
  return ProfessionalProfile.fromMap(data['id'], data);
}

Future<void> updateProfessionalProfileAPI(Map<String, dynamic> data) async {
  print('updateProfessionalProfileAPI');
  await _callFunction('professionals', {
    'action': 'updateProfessionalProfile',
    ...data,
  });
}

Future<PatientProfile> getPatientFromIdAPI(String patientId) async {
  print('getPatientFromIdAPI');
  final data = await _callFunction('patients', {
    'action': 'getPatientFromId',
    'patientId': patientId,
  });
  return PatientProfile.fromMap(data['id'], data);
}

Future<void> updatePatientProfileAPI(Map<String, dynamic> data) async {
  print('updatePatientProfileAPI');
  await _callFunction('patients', {
    'action': 'updatePatientProfile',
    ...data,
  });
}

Future<int> getServerTimestampAPI() async {
  print('getServerTimestampAPI');
  final response = await http.post(
    Uri.parse(_getFunctionUrl('misc')),
    headers: _getHeaders(),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['serverTimestamp'] as int;
  } else {
    throw Exception('Failed to get server timestamp: ${response.statusCode}');
  }
}

// Placeholder functions for features not yet migrated
Future<void> requestAppointmentAPI(Appointment appointment) async {
  throw UnimplementedError('Appointments not yet migrated to Supabase');
}

Future<void> acceptPendingAppointmentAPI(Appointment appointment) async {
  throw UnimplementedError('Appointments not yet migrated to Supabase');
}

Future<void> declinePendingAppointmentAPI(Appointment appointment) async {
  throw UnimplementedError('Appointments not yet migrated to Supabase');
}

Future<Map<String, ProfessionalProfile>> getMultipleProfessionalsFromIdsAPI(List<String> userIds) async {
  throw UnimplementedError('Batch queries not yet implemented');
}

Future<Map<String, PatientProfile>> getMultiplePatientsFromIdsAPI(List<String> userIds) async {
  throw UnimplementedError('Batch queries not yet implemented');
}

Future<String> getPublicKeyAPI(String professionalId) async {
  throw UnimplementedError('KMS encryption not yet migrated');
}

Future<void> createPublicKeyAPI() async {
  throw UnimplementedError('KMS encryption not yet migrated');
}

Future<String> decryptDekAPI(String encryptedDek, String publicKey) async {
  throw UnimplementedError('KMS encryption not yet migrated');
}

Future<String> createChatAPI(String participantId, String dek) async {
  throw UnimplementedError('Chat encryption not yet migrated');
}

Future<String> getChatKeyAPI(String chatId, String publicKey) async {
  throw UnimplementedError('Chat encryption not yet migrated');
}

Future<void> sendChatMessageAPI(String chatId, Map<String, dynamic> data) async {
  throw UnimplementedError('Chat not yet migrated');
}

Future<void> removeChatNotificationAPI(String chatId) async {
  throw UnimplementedError('Chat notifications not yet migrated');
}
