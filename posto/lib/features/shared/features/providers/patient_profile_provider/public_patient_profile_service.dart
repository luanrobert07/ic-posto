import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/utils/cloud_functions_endpoints.dart';
import 'package:posto/features/shared/features/providers/patient_profile_provider/patient_profile.dart';

import '../../../../../core/services/firestore_service/firestore_service.dart';

part 'public_patient_profile_service.g.dart';

@riverpod
PublicPatientProfileService publicPatientProfileService(Ref ref) {
  return PublicPatientProfileService(ref);
}

class PublicPatientProfileService extends FirestoreService {
  final Ref ref;

  PublicPatientProfileService(this.ref);

  Future<Map<String, PatientProfile>> getMultipleProfilesFromIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    return getMultiplePatientsFromIdsAPI(userIds);
  }

  Future<PatientProfile> getProfileFromId(String id) async {
    return getPatientFromIdAPI(id);
  }
}
