import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/screens/base_page.dart';
import '../state_management/professional_profile_settings_provider.dart';
import '../state_management/professional_profile_settings_state.dart';
import 'schedule_settings.dart';

class MedicalColors {
  static const primary = Color(0xFF4A90A4);
  static const secondary = Color(0xFF6BA3B0);
  static const accent = Color(0xFF5DADE2);
  static const background = Color(0xFFF8FAFB);
  static const surface = Colors.white;
  static const cardShadow = Color(0x1A4A90A4);
}

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
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [MedicalColors.background, Color(0xFFE3F2FD)],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(MedicalColors.primary),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MedicalColors.background, Color(0xFFE3F2FD)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: MedicalColors.cardShadow,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MedicalColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.settings,
                            color: MedicalColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Configurações do Perfil',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: MedicalColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gerencie suas informações profissionais e configurações de consulta',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: MedicalColors.cardShadow,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Informações Pessoais', Icons.person_outline),
                        const SizedBox(height: 24),
                        
                        _buildStyledTextField(
                          controller: state.nameController,
                          label: 'Nome Completo',
                          icon: Icons.person,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildStyledTextField(
                          controller: state.contactController,
                          label: 'Contato',
                          icon: Icons.phone,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        _buildSectionHeader('Configurações de Agenda', Icons.schedule),
                        const SizedBox(height: 24),
                        
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: MedicalColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: MedicalColors.primary.withValues(alpha: 0.1)),
                          ),
                          child: const ScheduleSettings(),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        _buildSectionHeader('Duração da Consulta', Icons.timer_outlined),
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Duração da consulta em minutos:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStyledTextField(
                                controller: state.sessionDurationController,
                                label: 'Minutos',
                                icon: Icons.access_time,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: MedicalColors.cardShadow,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStyledButton(
                            onPressed: () => context.pop(),
                            text: 'Voltar',
                            isSecondary: true,
                            icon: Icons.arrow_back,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildStyledButton(
                            onPressed: () async => notifier.save(),
                            text: 'Salvar Alterações',
                            icon: Icons.save,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MedicalColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: MedicalColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MedicalColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: MedicalColors.cardShadow.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: MedicalColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MedicalColors.primary.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MedicalColors.primary.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MedicalColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: MedicalColors.primary),
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    bool isSecondary = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isSecondary ? Colors.grey : MedicalColors.primary).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.grey[100] : MedicalColors.primary,
          foregroundColor: isSecondary ? Colors.grey[800] : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget mobilePage(BuildContext context) {
    return const Placeholder();
  }
}
