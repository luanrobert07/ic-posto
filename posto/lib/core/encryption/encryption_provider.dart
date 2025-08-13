import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/encryption/encryption_service.dart';
import 'package:posto/core/encryption/encryption_state.dart';
import 'package:posto/core/encryption/kms_provider.dart';

import '../auth/state_management/user_type.dart';
import '../auth/state_management/user_type_provider.dart';
import 'exceptions/key_not_found_exception.dart';
import 'models/key_state_enum.dart';
import 'models/public_key_state_model.dart';

part 'encryption_provider.g.dart';

@Riverpod(keepAlive: true)
class EncryptionNotifier extends _$EncryptionNotifier {
  // Cant be on state class since there is no need to update listeners on change
  KeyPair? _localKeyPair;
  KeyState? _localKeyState;

  @override
  EncryptionState build() {
    return EncryptionState();
  }

  void _updateKeyState(String professionalId, PublicKeyState publicKeyState) {
    final newPublicKeyStates = Map<String, PublicKeyState>.from(state.publicKeyStates);
    newPublicKeyStates[professionalId] = publicKeyState;
    state = state.copyWith(publicKeyStates: newPublicKeyStates);
  }

  Future<void> loadPublicKey(String? professionalId) async {
    professionalId ??= FirebaseAuth.instance.currentUser?.uid;
    PublicKeyState? keyState = state.publicKeyStates[professionalId];

    if (keyState != null && keyState.keyState != KeyState.error) return;

    keyState = PublicKeyState(keyState: KeyState.retrieving);
    _updateKeyState(professionalId!, keyState);
    print('Getting public key');
    final kmsService = ref.read(kmsServiceProvider);

    try {
      final key = await kmsService.getPublicKey(professionalId);
      _updateKeyState(
        professionalId,
        keyState.copyWith(publicKey: key, keyState: KeyState.ready),
      );
      print('Got key');

    } on KeyNotFoundException catch (_) {
      final userType = ref.read(userTypeNotifierProvider);
      if (userType != UserType.patient) {
        _updateKeyState(
          professionalId,
          keyState.copyWith(keyState: KeyState.error, errorMessage: 'Could not get encryption key, try again later'),
        );
        return;
      }

      print('Creating key');
      _updateKeyState(
        professionalId,
        keyState.copyWith(keyState: KeyState.creating),
      );

      await kmsService.createPublicKey();
      String? key;
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(seconds: 1));

        try {
          key = await kmsService.getPublicKey(professionalId);
          break;
        } on KeyNotFoundException {
          // Try again
        }
      }

      if (key == null) {
        _updateKeyState(
          professionalId,
          keyState.copyWith(keyState: KeyState.error, errorMessage: 'Could not retrieve encryption key, try logging out and in again'),
        );
        return;
      }
      
      state = state.copyWith();
      print('Got key');

    } catch (e) {
      print('Error while getting key: ${e.toString()}');
      _updateKeyState(
        professionalId,
        keyState.copyWith(keyState: KeyState.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> generateLocalKeyPair() async {
    print('Generating local key pair');
    _localKeyState = KeyState.creating;
    EncryptionService encryptionService = EncryptionService();
    _localKeyPair = await encryptionService.generateRsaKeyPair();
    _localKeyState = KeyState.ready;
  }

  Future<KeyPair> getLocalKeyPair() async {
    for (int i = 0; i < 5; i++) {
      if (_localKeyState == KeyState.ready) {
        break;
      }
      print('Waiting for local key creation');
      await Future.delayed(Duration(seconds: 1));
    }

    if (_localKeyState != KeyState.ready) {
      throw Exception('Local key was not generated before usage');
    }

    return _localKeyPair!;
  }

  PublicKeyState getPublicKeyState(String? professionalId) {
    professionalId ??= FirebaseAuth.instance.currentUser?.uid;

    return state.publicKeyStates[professionalId]!;
  }
}
