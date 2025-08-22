import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posto/core/auth/state_management/auth_provider.dart';
import '../../../features/shared/features/dialogs/error_dialog.dart';
import '../state_management/user_type.dart';
import '../state_management/auth_state.dart';

class MedicalColors {
  static const primary = Color(0xFF64748B); 
  static const secondary = Color(0xFF94A3B8); 
  static const accent = Color(0xFF6B7280); 
  static const background = Color(0xFFF8FAFC); 
  static const error = Color(0xFFDC2626); 
  static const success = Color(0xFF059669);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const purple = Color(0xFF7C3AED); 
  static const orange = Color(0xFFEA580C); 
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late AuthState state;
  late AuthNotifier notifier;

  void login() async {
    try {
      await notifier.logIn();
    } catch (e) {
      if (mounted) {
        ErrorDialog.show('Ocorreu um erro ao logar, tente novamente');
      }
    }
  }

  void singup() async {
    try {
      await notifier.singUp();
    } catch (e) {
      if (mounted) {
        ErrorDialog.show('Ocorreu um erro ao criar conta.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    state = ref.watch(authNotifierProvider);
    notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF1F5F9), 
              Color(0xFFF8FAFB), 
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: MedicalColors.background,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: MedicalColors.primary.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: MedicalColors.accent.withValues(alpha: 0.1),
                        blurRadius: 50,
                        offset: const Offset(0, 25),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildLeftSide(),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              flex: 3,
                              child: _buildFormSide(),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLeftSide(),
                            const SizedBox(height: 32),
                            _buildFormSide(),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [MedicalColors.primary, MedicalColors.secondary, MedicalColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: MedicalColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Posto Saúde",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [MedicalColors.primary, MedicalColors.purple],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Sistema integrado de gestão médica e hospitalar",
          style: TextStyle(
            fontSize: 16,
            color: MedicalColors.textSecondary,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureCard(Icons.security, "Seguro", MedicalColors.primary),
            _buildFeatureCard(Icons.speed, "Rápido", MedicalColors.accent),
            _buildFeatureCard(Icons.verified, "Confiável", MedicalColors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MedicalColors.primary.withValues(alpha: 0.1), MedicalColors.accent.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: MedicalColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    color: MedicalColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Acesso Profissional",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: MedicalColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Entre com suas credenciais seguras",
                style: TextStyle(
                  fontSize: 14,
                  color: MedicalColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildProfessionalTextField(
          controller: state.emailController,
          hint: 'Email Profissional',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildProfessionalTextField(
          controller: state.passwordController,
          hint: 'Senha Segura',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 20),

        Text(
          "Tipo de Acesso",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: MedicalColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ToggleButtons(
          borderRadius: BorderRadius.circular(16),
          selectedColor: Colors.white,
          fillColor: MedicalColors.primary,
          color: MedicalColors.textSecondary,
          selectedBorderColor: MedicalColors.primary,
          borderColor: MedicalColors.primary.withValues(alpha: 0.3),
          borderWidth: 1.5,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 85),
          isSelected: [
            state.accountType == UserType.patient,
            state.accountType == UserType.professional,
            state.accountType == UserType.agent,
          ],
          onPressed: (int index) {
            if (index == 0) notifier.setAccountType(UserType.patient);
            if (index == 1) notifier.setAccountType(UserType.professional);
            if (index == 2) notifier.setAccountType(UserType.agent);
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Paciente', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Médico', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Agente', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: MedicalColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: MedicalColors.primary.withValues(alpha: 0.4),
                ),
                onPressed: login,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.login, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Entrar",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: MedicalColors.accent, width: 2),
                  foregroundColor: MedicalColors.accent,
                ),
                onPressed: singup,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.person_add, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Criar Conta",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[25] ?? Colors.orange[50]!, Colors.amber[25] ?? Colors.amber[50]!],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MedicalColors.orange.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.developer_mode, color: MedicalColors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Acesso Rápido - Dev",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MedicalColors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildQuickAccessButton("Paciente", "victorgorgal@gmail.com", "senha12345", Icons.person, MedicalColors.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAccessButton("Médico", "victorgorgal2@gmail.com", "senha12345", Icons.medical_services, MedicalColors.accent)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAccessButton("Agente", "victorgorgal3@gmail.com", "senha12345", Icons.admin_panel_settings, MedicalColors.purple)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MedicalColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A), 
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: MedicalColors.textSecondary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: MedicalColors.primary, size: 24),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: MedicalColors.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: MedicalColors.primary, width: 2.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(String label, String email, String password, IconData icon, Color color) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          state.emailController.text = email;
          state.passwordController.text = password;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credenciais de $label preenchidas automaticamente'),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        Future.delayed(const Duration(milliseconds: 500), () {
          login();
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        backgroundColor: color.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
