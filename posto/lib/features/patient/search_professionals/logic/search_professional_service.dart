import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import 'package:posto/core/services/firestore_service/firestore_service.dart';

import '../../../../core/utils/cloud_functions_endpoints.dart';
import '../../../shared/features/providers/professional_profile_provider/professional_profile.dart';

class SearchProfessionalService extends FirestoreService {
  final Ref _ref;
  String? _lastProfileId;
  final List<String> _profileIds = [];
  bool canLoadMore = true;

  SearchProfessionalService(this._ref);

  Future<void> loadProfessionals() async {
    if (!canLoadMore) return;

    final data = await searchProfessionalsAPI(_lastProfileId);
    if (data['lastDocId'] != null) {
      _lastProfileId = data['lastDocId'];
    }

    canLoadMore = data['canLoadMore'];

    final Map<String, ProfessionalProfile> profiles = Map.fromEntries(
      (data['professionals'] as List)
          .map((map) => MapEntry(map['id'], ProfessionalProfile.fromMap(map['id'], map))),
    );

    _ref.read(profileCacheServiceProvider.notifier).addProfiles(profiles);
    _profileIds.addAll(profiles.keys);
  }

  List<String> getProfileIds() {
    return _profileIds;
  }
}
