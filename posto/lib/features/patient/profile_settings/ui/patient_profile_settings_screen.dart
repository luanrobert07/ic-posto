import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/features/patient/profile_settings/state_management/patient_profile_settings_provider.dart';
import 'package:posto/features/patient/profile_settings/state_management/patient_profile_settings_state.dart';
import 'package:posto/features/shared/screens/base_page.dart';

import '../../../shared/widgets/edit_text.dart';

class PatientProfileSettingsScreen extends ConsumerStatefulWidget {
  const PatientProfileSettingsScreen({super.key});

  @override
  ConsumerState<PatientProfileSettingsScreen> createState() => _PatientProfileSettingsScreenState();
}

class _PatientProfileSettingsScreenState extends ConsumerState<PatientProfileSettingsScreen> {
  late PatientProfileSettingsState state;
  late PatientProfileSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    state = ref.watch(patientProfileSettingsNotifierProvider);
    notifier = ref.read(patientProfileSettingsNotifierProvider.notifier);

    return BasePage(
      webPage: webPage(),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage() {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
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
                    await notifier.save();
                  },
                  child: const Text('Salvar'),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget mobilePage() {
    return const Placeholder();
  }
}
