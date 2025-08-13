import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/professional_profile.dart';

part 'professional_home_state.freezed.dart';

@freezed
abstract class ProfessionalHomeState with _$ProfessionalHomeState {
  const factory ProfessionalHomeState({
    @Default(false) bool example,
    ProfessionalProfile? profile,
  }) = _ProfessionalHomeState;
}
