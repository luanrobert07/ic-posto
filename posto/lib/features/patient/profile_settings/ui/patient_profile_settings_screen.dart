// patient_profile_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:posto/features/patient/profile_settings/state_management/patient_profile_settings_provider.dart';
import 'package:posto/features/patient/profile_settings/state_management/patient_profile_settings_state.dart';
import 'package:posto/features/shared/screens/base_page.dart';

/// Tela: Perfil e Informativos
/// Tudo em um único arquivo. Informativos são mock locais e ações são visuais.

class MedicalColors {
  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color darkGray = Color(0xFF444444);
  static const Color white = Colors.white;
  static const Color success = Color(0xFF28A745);
}

/// Modelo local para informativo (mock)
class Informativo {
  final String id;
  final String titulo;
  final String mensagem;
  bool lido;
  bool favorito;

  Informativo({
    required this.id,
    required this.titulo,
    required this.mensagem,
    this.lido = false,
    this.favorito = false,
  });
}

/// Provider local para informativos (mockados para esta tela)
final informativosProvider = StateProvider<List<Informativo>>((ref) => [
      Informativo(
        id: 'i1',
        titulo: 'Vacinação contra gripe',
        mensagem:
            'A campanha de vacinação contra gripe começa nesta segunda-feira. Procure o posto mais próximo entre 8h e 16h.',
      ),
      Informativo(
        id: 'i2',
        titulo: 'Consulta agendada',
        mensagem: 'Sua consulta está marcada para 15/11 às 14:00. Compareça com 15 minutos de antecedência.',
      ),
      Informativo(
        id: 'i3',
        titulo: 'Dica de saúde',
        mensagem:
            'Mantenha-se hidratado nos dias quentes. Evite exposição ao sol entre 11h e 15h.',
      ),
    ]);

class PatientProfileSettingsScreen extends ConsumerStatefulWidget {
  const PatientProfileSettingsScreen({super.key});

  @override
  ConsumerState<PatientProfileSettingsScreen> createState() =>
      _PatientProfileSettingsScreenState();
}

class _PatientProfileSettingsScreenState
    extends ConsumerState<PatientProfileSettingsScreen> {
  late PatientProfileSettingsState state;
  late PatientProfileSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    state = ref.watch(patientProfileSettingsNotifierProvider);
    notifier = ref.read(patientProfileSettingsNotifierProvider.notifier);

    return BasePage(
      webPage: _webPage(context),
      mobilePage: _mobilePage(context),
    );
  }

  Widget _webPage(BuildContext context) {
    if (state.isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFB), Color(0xFFE8F4F8)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF475569)),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFB), Color(0xFFE8F4F8)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildProfileCard(context),
                  const SizedBox(height: 20),
                  _buildSettingsCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobilePage(BuildContext context) {
    // Reutiliza layout web com ajustes menores para mobile
    return _webPage(context);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF475569).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Color(0xFF475569),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Perfil e Informativos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MedicalColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF475569).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Color(0xFF475569), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'Usuário',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Email',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MedicalColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações do Perfil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          // Nome
          const Text(
            'Nome Completo',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: state.nameController,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Digite seu nome completo',
                hintStyle:
                    TextStyle(fontSize: 16, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF475569), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Contato
          const Text(
            'Contato',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: state.contactController,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Telefone ou email',
                hintStyle:
                    TextStyle(fontSize: 16, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF475569), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: BorderSide(
                        color: const Color(0xFF475569).withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await notifier.save();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF475569),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Salvar',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  
}
