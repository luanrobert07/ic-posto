import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_cache_service.g.dart';

@Riverpod(keepAlive: true)
class ProfileCacheService extends _$ProfileCacheService {
  @override
  Map<String, dynamic> build() => {};

  void addProfiles<T>(Map<String, T> profiles) {
    if (profiles.isEmpty) return;

    final updated = Map<String, dynamic>.from(state);
    updated.addAll(profiles);
    state = updated;
  }

  void addProfile<T>(String id, T profile) {
    final updated = Map<String, dynamic>.from(state);
    updated[id] = profile;
    state = updated;
  }

  /// Remove all ids from the given list that are already in cache
  List<String> filterIdsForNewOnes(List<String> allIds) {
    if (allIds.isEmpty) return [];

    for (final profileId in state.keys) {
      allIds.remove(profileId);
    }
    return allIds;
  }

  List<T> getProfilesFromIds<T>(List<String> ids) {
    return ids
        .map((id) => getProfile<T>(id))
        .whereType<T>()
        .toList();
  }

  T? getProfile<T>(String id) {
    final value = state[id];
    return value is T ? value : null;
  }

  List<T> getProfilesOfType<T>() {
    return state.values.whereType<T>().toList();
  }
}
