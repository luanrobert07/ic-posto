import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_professional_state.freezed.dart';

@freezed
abstract class SearchProfessionalState with _$SearchProfessionalState {
  const factory SearchProfessionalState({
    @Default([]) List<String> profileIds,
    @Default(false) bool isLoadingMore,
  }) = _SearchProfessionalState;
}
