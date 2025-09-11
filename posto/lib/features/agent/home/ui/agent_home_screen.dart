import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/screens/base_page.dart';

class MedicalColors {
  static const Color primaryBlue = Color(0xFF2E86AB);
  static const Color lightBlue = Color(0xFF4A9FD1);
  static const Color darkBlue = Color(0xFF1B5E7A);
  static const Color accentTeal = Color(0xFF48CAE4);
  static const Color lightTeal = Color(0xFF90E0EF);
  static const Color softGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color darkGray = Color(0xFF495057);
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
}

class AgentHomeScreen extends ConsumerStatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  ConsumerState<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends ConsumerState<AgentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    AuthService authService = ref.watch(authServiceProvider);

    return BasePage(
      webPage: webPage(context, authService),
      mobilePage: mobilePage(context, authService),
    );
  }

  Widget webPage(BuildContext context, AuthService authService) {
    return Scaffold(
      backgroundColor: MedicalColors.softGray,
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: MedicalColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: MedicalColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MedicalColors.softGray,
              MedicalColors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MedicalColors.primaryBlue,
                        MedicalColors.lightBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: MedicalColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.medical_services_rounded,
                        size: 64,
                        color: MedicalColors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bem-vindo, Agente',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: MedicalColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Versão Web - Dashboard Profissional',
                        style: TextStyle(
                          fontSize: 16,
                          color: MedicalColors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: MedicalColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ações Rápidas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: MedicalColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await authService.signOut();
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            "Sair da Conta",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MedicalColors.error,
                            foregroundColor: MedicalColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
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
    );
  }

  Widget mobilePage(BuildContext context, AuthService authService) {
    return Scaffold(
      backgroundColor: MedicalColors.softGray,
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: MedicalColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: MedicalColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MedicalColors.softGray,
              MedicalColors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MedicalColors.primaryBlue,
                        MedicalColors.lightBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: MedicalColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 48,
                        color: MedicalColors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bem-vindo, Agente',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MedicalColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Versão Mobile - App Profissional',
                        style: TextStyle(
                          fontSize: 14,
                          color: MedicalColors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MedicalColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ações Rápidas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: MedicalColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await authService.signOut();
                          },
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text(
                            "Sair da Conta",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MedicalColors.error,
                            foregroundColor: MedicalColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
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
    );
  }
}
