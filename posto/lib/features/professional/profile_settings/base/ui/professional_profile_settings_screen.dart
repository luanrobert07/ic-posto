import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/screens/base_page.dart';
import '../../../../shared/widgets/edit_text.dart';
import '../state_management/professional_profile_settings_provider.dart';
import '../state_management/professional_profile_settings_state.dart';
import 'schedule_settings.dart';

class ProfessionalProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfessionalProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfessionalProfileSettingsScreen> createState() => _ProfessionalProfileSettingsScreenState();
}

class _ProfessionalProfileSettingsScreenState extends ConsumerState<ProfessionalProfileSettingsScreen> {
  late ProfessionalProfileSettingsState state;
  late ProfessionalProfileSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    state = ref.watch(professionalProfileSettingsNotifierProvider);
    notifier = ref.read(professionalProfileSettingsNotifierProvider.notifier);

    return BasePage(
      webPage: webPage(context),
      mobilePage: mobilePage(context),
    );
  }

  Widget webPage(BuildContext context) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),
              EditText(
                controller: state.nameController,
                hint: 'Nome Completo',
              ),
              const SizedBox(height: 25),
              EditText(
                controller: state.contactController,
                hint: 'Contato',
              ),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  context.push('/professional/profile_settings/schedule_exceptions');
                },
                child: const Text("Schedule Exceptions"),
              ),

              const SizedBox(height: 25),
              const ScheduleSettings(),

              const SizedBox(height: 25),
              Row(
                children: [
                  const Spacer(flex: 2),
                  Text('Duração da consulta em minutos: '),
                  const SizedBox(width: 15),
                  Expanded(
                    child: EditText(
                      controller: state.sessionDurationController,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Voltar'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      notifier.save();
                    },
                    child: const Text('Salvar'),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mobilePage(BuildContext context) {
    return const Placeholder();
  }
}
