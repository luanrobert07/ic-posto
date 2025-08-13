import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/utils/cloud_functions_endpoints.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/professional_profile.dart';
import 'package:posto/features/shared/features/appointment/models/appointment.dart';
import '../../../../../core/services/firestore_service/firestore_service.dart';
import '../../dialogs/error_dialog.dart';

part 'public_professional_profile_service.g.dart';

@riverpod
PublicProfessionalProfileService publicProfessionalProfileService(Ref ref) {
  return PublicProfessionalProfileService(ref);
}

class PublicProfessionalProfileService extends FirestoreService {
  final Ref ref;

  PublicProfessionalProfileService(this.ref);

  Future<void> requestAppointment(Appointment appointment) async {
    return requestAppointmentAPI(appointment);
  }

  Future<Map<String, ProfessionalProfile>> getMultipleProfilesFromIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    return getMultipleProfessionalsFromIdsAPI(userIds);
  }

  Future<ProfessionalProfile> getProfileFromId(String professionalId) async {
    return getProfessionalFromIdAPI(professionalId);
  }
}
