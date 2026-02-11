import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/auth/state_management/user_type.dart';

import '../../utils/cloud_functions_endpoints.dart';

part 'user_type_provider.g.dart';

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
    if (FirebaseAuth.instance.currentUser == null) {
      state = UserType.notLoggedIn;
      return;
    }

    final idTokenResult = await FirebaseAuth.instance.currentUser!.getIdTokenResult(true);
    final claims = idTokenResult.claims;

    if (claims == null) {
      throw Exception('No claims found');
    }

    if (!claims.containsKey('userType')) {
      print('User has no type');
      state = UserType.none;
      return;
    }

    print('User type: ${claims['userType']}');
    if (claims['userType'] == 'patient') {
      state = UserType.patient;
      return;
    }
    if (claims['userType'] == 'professional') {
      state = UserType.professional;
      return;
    }
    if (claims['userType'] == 'agent') {
      state = UserType.agent;
      return;
    }

    state = UserType.none;
    return;
  }
}
