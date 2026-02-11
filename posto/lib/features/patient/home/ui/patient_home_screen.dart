import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/features/shared/screens/base_page.dart';

import '../../../../core/auth/logic/auth_service.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return BasePage(
      webPage: webPage(context, authService),
      mobilePage: mobilePage(context, authService),
    );
  }

  // =========================
  // WEB
  // =========================
  Widget webPage(BuildContext context, AuthService authService) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFB), Color(0xFFF5F7FA), Color(0xFFF9FAFB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                _buildHeaderWeb(),
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.4,
                    children: [
                      _buildCleanNavigationCard(
                        context,
                        "Lista de Médicos",
                        "Encontre especialistas",
                        Icons.medical_services_outlined,
                        const Color(0xFF3B82F6),
                        () => context.push('/patient/search'),
                      ),
                      _buildCleanNavigationCard(
                        context,
                        "Minhas Consultas",
                        "Agende e gerencie",
                        Icons.calendar_today_outlined,
                        const Color(0xFF10B981),
                        () => context.push('/patient/appointments'),
                      ),
                      _buildCleanNavigationCard(
                        context,
                        "Configurações",
                        "Gerencie seu perfil",
                        Icons.settings_outlined,
                        const Color(0xFF8B5CF6),
                        () => context.push('/patient/profile_settings'),
                      ),
                      _buildCleanNavigationCard(
                        context,
                        "Notificações",
                        "Alertas e lembretes",
                        Icons.notifications_outlined,
                        const Color(0xFFF59E0B),
                        () => context.push('/patient/notifications'),
                      ),
                      _buildCleanNavigationCard(
                        context,
                        "Sair",
                        "Encerrar sessão",
                        Icons.logout_outlined,
                        const Color(0xFFEF4444),
                        () async => await authService.signOut(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWeb() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF64748B),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Portal do Paciente",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Acesse seus serviços médicos de forma rápida e segura",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCleanNavigationCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // MOBILE
  // =========================
  Widget mobilePage(BuildContext context, AuthService authService) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFB), Color(0xFFF5F7FA), Color(0xFFF9FAFB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeaderMobile(),
                _buildCleanMobileNavigationCard(
                  "Lista de Médicos",
                  "Encontre especialistas",
                  Icons.medical_services_outlined,
                  const Color(0xFF3B82F6),
                  () => context.push('/patient/search'),
                ),
                const SizedBox(height: 16),
                _buildCleanMobileNavigationCard(
                  "Minhas Consultas",
                  "Agende e gerencie",
                  Icons.calendar_today_outlined,
                  const Color(0xFF10B981),
                  () => context.push('/patient/appointments'),
                ),
                const SizedBox(height: 16),
                _buildCleanMobileNavigationCard(
                  "Configurações",
                  "Gerencie seu perfil",
                  Icons.settings_outlined,
                  const Color(0xFF8B5CF6),
                  () => context.push('/patient/profile_settings'),
                ),
                const SizedBox(height: 16),
                _buildCleanMobileNavigationCard(
                  "Notificações",
                  "Alertas e lembretes",
                  Icons.notifications_outlined,
                  const Color(0xFFF59E0B),
                  () => context.push('/patient/notifications'),
                ),
                const SizedBox(height: 16),
                _buildCleanMobileNavigationCard(
                  "Sair",
                  "Encerrar sessão",
                  Icons.logout_outlined,
                  const Color(0xFFEF4444),
                  () async => await authService.signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMobile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF64748B),
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Portal do Paciente",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Acesse seus serviços médicos",
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanMobileNavigationCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
