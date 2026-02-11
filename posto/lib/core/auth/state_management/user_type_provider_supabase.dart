import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/user_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/supabase_functions_endpoints.dart';

part 'user_type_provider_supabase.g.dart';

@Riverpod(keepAlive: true)
class UserTypeNotifier extends _$UserTypeNotifier {
  @override
  UserType build() {
    Future.microtask(getUserType);

    return UserType.notLoggedIn;
  }

  Future<void> configureUserType(UserType userType, String name, String email) async {
    if (userType == UserType.patient) {
      print('Setting patient custom claim');
      await addPatientRoleAPI(name, email);
    }

    if (userType == UserType.professional) {
      print('Setting professional custom claim');
      await addProfessionalRoleAPI(name, email);
    }

    if (userType == UserType.agent) {
      print('Setting agent custom claim');
      await addAgentRoleAPI(name, email);
    }

    await getUserType();
  }

  Future<void> getUserType() async {
    print('Getting user type');
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      state = UserType.notLoggedIn;
      return;
    }

    // Refresh session to get latest metadata
    try {
      await supabase.auth.refreshSession();
    } catch (e) {
      print('Error refreshing session: $e');
    }

    final metadata = supabase.auth.currentUser?.appMetadata;

    if (metadata == null || !metadata.containsKey('user_type')) {
      print('User has no type');
      state = UserType.none;
      return;
    }

    final userType = metadata['user_type'];
    print('User type: $userType');

    if (userType == 'patient') {
      state = UserType.patient;
      return;
    }
    if (userType == 'professional') {
      state = UserType.professional;
      return;
    }
    if (userType == 'agent') {
      state = UserType.agent;
      return;
    }

    state = UserType.none;
    return;
  }
}
