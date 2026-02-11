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
  ConsumerState<ProfessionalProfilesList> createState() =>
      _ProfessionalProfilesListState();
}

class _ProfessionalProfilesListState
    extends ConsumerState<ProfessionalProfilesList> {
  @override
  Widget build(BuildContext context) {
    final String uid = AuthService.getUserUid()!;
    final SearchProfessionalState state =
        ref.watch(searchProfessionalNotifierProvider(uid));
    final SearchProfessionalNotifier notifier =
        ref.read(searchProfessionalNotifierProvider(uid).notifier);
    final profileIds = state.profileIds;

    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Cabeçalho centralizado
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Profissionais disponíveis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // espaço para equilibrar o alinhamento
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: InfiniteScrollList(
                    itemCount: profileIds.length,
                    isLoadingMore: state.isLoadingMore,
                    canLoadMore: notifier.canLoadMore(),
                    fetchMoreData: () async =>
                        await notifier.loadMoreProfessionals(),
                    itemBuilder: (context, index) {
                      final profileId = profileIds[index];
                      final profile = notifier.getProfileFromId(profileId);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                await notifier.loadProfileAppointments(profileId);
                                if (context.mounted) context.push('./appointment');
                              },
                              splashColor:
                                  const Color(0xFF475569).withValues(alpha: 0.1),
                              highlightColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF475569),
                                            Color(0xFF64748B)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF475569)
                                                .withValues(alpha: 0.25),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.health_and_safety,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profile.name,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone_rounded,
                                                  size: 16,
                                                  color: Color(0xFF94A3B8)),
                                              const SizedBox(width: 6),
                                              Text(
                                                profile.contact,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE2E8F0),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              "Ver detalhes",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded,
                                        size: 18, color: Color(0xFFCBD5E1)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
