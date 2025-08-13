import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/features/patient/book_appointment/state_management/book_appointment_provider.dart';
import 'package:posto/features/patient/search_professionals/state_management/search_professional_provider.dart';
import 'package:posto/features/shared/widgets/infinite_scroll_list.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/features/providers/professional_profile_provider/professional_profile.dart';
import '../state_management/search_professional_state.dart';

class ProfessionalProfilesList extends ConsumerStatefulWidget {
  const ProfessionalProfilesList({super.key});

  @override
  ConsumerState<ProfessionalProfilesList> createState() => _ProfessionalProfilesListState();
}

class _ProfessionalProfilesListState extends ConsumerState<ProfessionalProfilesList> {
  @override
  Widget build(BuildContext context) {
    final String uid = AuthService.getUserUid()!;
    final SearchProfessionalState state = ref.watch(searchProfessionalNotifierProvider(uid));
    final SearchProfessionalNotifier notifier = ref.read(searchProfessionalNotifierProvider(uid).notifier);
    final profileIds = state.profileIds;

    return Expanded(
      child: InfiniteScrollList(
        itemCount: profileIds.length,
        isLoadingMore: state.isLoadingMore,
        canLoadMore: notifier.canLoadMore(),
        fetchMoreData: () async {
          await notifier.loadMoreProfessionals();
        },
        itemBuilder: (context, id) {
          String profileId = profileIds[id];
          final profile = notifier.getProfileFromId(profileId);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await notifier.loadProfileAppointments(profileId);
                if (context.mounted) {
                  context.push('./appointment');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(profile.name),
                    Text(profile.contact),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
