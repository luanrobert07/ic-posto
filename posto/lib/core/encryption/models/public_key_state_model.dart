import 'package:freezed_annotation/freezed_annotation.dart';

import 'key_state_enum.dart';

part 'public_key_state_model.freezed.dart';

@freezed
abstract class PublicKeyState with _$PublicKeyState {
  const factory PublicKeyState({
    String? publicKey,
    required KeyState keyState,
    String? errorMessage,
  }) = _PublicKeyState;
}
