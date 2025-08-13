import 'package:freezed_annotation/freezed_annotation.dart';

import 'models/public_key_state_model.dart';

part 'encryption_state.freezed.dart';

@freezed
abstract class EncryptionState with _$EncryptionState {
  const factory EncryptionState({
    @Default({}) Map<String, PublicKeyState> publicKeyStates,
  }) = _EncryptionState;
}
