import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/features/patient/search_professionals/logic/search_professional_service.dart';
import 'package:posto/features/patient/search_professionals/state_management/search_professional_state.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/professional_profile.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../../core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import '../../book_appointment/state_management/book_appointment_provider.dart';

part 'search_professional_provider.g.dart';

@Riverpod(keepAlive: true)
class SearchProfessionalNotifier extends _$SearchProfessionalNotifier {
  late final _searchProfessionalService = SearchProfessionalService(ref);

  @override
  SearchProfessionalState build(String userId) {
    Future.microtask(() => loadMoreProfessionals());

    return SearchProfessionalState(
      isLoadingMore: true,
    );
  }

  Future<void> loadMoreProfessionals() async {
    if (!state.isLoadingMore) {
      state = state.copyWith(
        isLoadingMore: true,
      );
    }

    await _searchProfessionalService.loadProfessionals();

    state = state.copyWith(
      profileIds: _searchProfessionalService.getProfileIds(),
      isLoadingMore: false,
    );
  }

  ProfessionalProfile getProfileFromId(String profileId) {
    final cache = ref.read(profileCacheServiceProvider);
    return cache[profileId];
  }

  bool canLoadMore() {
    return _searchProfessionalService.canLoadMore;
  }

  Future<void> loadProfileAppointments(String profileId) async {
    final String uid = AuthService.getUserUid()!;
    return ref.read(bookAppointmentNotifierProvider(uid).notifier).setProfessionalProfile(profileId);
  }
}
