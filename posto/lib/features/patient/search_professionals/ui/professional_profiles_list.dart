import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/features/patient/search_professionals/state_management/search_professional_provider.dart';
import 'package:posto/features/shared/widgets/infinite_scroll_list.dart';

import '../../../../core/auth/logic/auth_service.dart';
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
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await notifier.loadProfileAppointments(profileId);
                      if (context.mounted) {
                        context.push('./appointment');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF475569), Color(0xFF64748B)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF475569).withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      profile.contact,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
