import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/professional/home/state_management/professional_home_state.dart';
import 'package:posto/features/shared/widgets/custom_icon_button.dart';

import '../../../../core/auth/logic/auth_service.dart';

import '../../../shared/screens/base_page.dart';
import '../state_management/professional_home_provider.dart';

class ProfessionalHomeScreen extends ConsumerStatefulWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends ConsumerState<ProfessionalHomeScreen> {
  late ProfessionalHomeState state;
  late ProfessionalHomeNotifier notifier;
  late Map<String, dynamic> cache;
  
  @override
  Widget build(BuildContext context) {
    state = ref.watch(professionalHomeNotifierProvider);
    notifier = ref.read(professionalHomeNotifierProvider.notifier);
    cache = ref.read(profileCacheServiceProvider);


    return BasePage(
      webPage: webPage(),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Column(
            children: [
              CustomIconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  print('Botão pressionado!');
                },
              ),
              CustomIconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  context.push('/professional/appointments');
                },
              ),
              CustomIconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.push('/professional/profile_settings');
                },
              ),
              CustomIconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final authService = ref.read(authServiceProvider);
                  await authService.signOut();
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Proximas consultas',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: state.profile?.bookedAppointments.length ?? 0,
                          itemBuilder: (context, id) {
                            final appointment = state.profile!.bookedAppointments[id];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(Utils.relativeTime(appointment.start),
                                      style: Theme.of(context).textTheme.bodyLarge,),
                                    Text(cache[appointment.patientId].name),
                                    Text(
                                      '${Utils.formatTime(appointment.start.toDate())}  ${Utils.formatDate(appointment.start.toDate())}',
                                      style: Theme.of(context).textTheme.displayMedium,
                                    ),
                                  ],
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
            ],
          ),
        ),

        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          "Consultas pendentes",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: state.profile?.pendingAppointments.length ?? 0,
                          itemBuilder: (context, id) {
                            final item = state.profile!.pendingAppointments[id];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cache[item.patientId].name),
                                    Text(
                                      '${Utils.formatTime(item.start.toDate())}  ${Utils.formatDate(item.start.toDate())}',
                                      style: Theme.of(context).textTheme.displayMedium,
                                    ),
                                  ],
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
            ],
          ),
        )
      ],
    );
  }

  Widget mobilePage() {
    return const Placeholder();
  }
}
