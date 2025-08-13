import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/user_type.dart';
import 'package:posto/core/utils/cloud_functions_endpoints.dart';

import '../auth/state_management/user_type_provider.dart';

part 'kms_provider.g.dart';

@riverpod
KmsService kmsService(Ref ref) {
  return KmsService(ref);
}

class KmsService {
  final Ref ref;

  KmsService(this.ref);

  Future<String> getPublicKey(String professionalId) async {
    return getPublicKeyAPI(professionalId);
  }

  Future<void> createPublicKey() async {
    final userType = ref.read(userTypeNotifierProvider);
    if (userType != UserType.professional) {
      throw Exception('Only professionals can create public keys');
    }

    return createPublicKeyAPI();
  }
}
