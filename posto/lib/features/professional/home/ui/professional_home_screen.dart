import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/professional/home/state_management/professional_home_state.dart';
import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/screens/base_page.dart';
import '../state_management/professional_home_provider.dart';

class MedicalColors {
  static const primary = Color(0xFF4A90A4);
  static const secondary = Color(0xFF6BA3B0);
  static const accent = Color(0xFF5DADE2);
  static const background = Color(0xFFF8FAFB);
  static const surface = Colors.white;
  static const cardShadow = Color(0x1A4A90A4);
}

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
      webPage: _buildResponsiveLayout(),
      mobilePage: _buildMobileLayout(),
    );
  }

  Widget _buildResponsiveLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth < 1200 && screenWidth >= 768;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return _buildMobileLayout();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MedicalColors.background, Color(0xFFE3F2FD)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 200 : 240,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildSidebar(isTablet),
          ),
          Expanded(
            flex: isTablet ? 3 : 2,
            child: _buildMainContent(isTablet),
          ),
          if (!isTablet)
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: MedicalColors.cardShadow,
                    blurRadius: 20,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: _buildRightSidebar(),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MedicalColors.background, Color(0xFFE3F2FD)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F2937),
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MedicalColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Posto Saúde',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          child: Container(
            color: const Color(0xFF1F2937),
            child: _buildSidebar(false),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo de volta!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MedicalColors.primary,
                    ),
                  ),
                  Text(
                    'Aqui está o resumo do seu dia',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MedicalColors.primary.withValues(alpha: 0.8), MedicalColors.secondary.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'Hoje',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Próximas Consultas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MedicalColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.profile?.bookedAppointments.length ?? 0,
                itemBuilder: (context, id) {
                  final appointment = state.profile!.bookedAppointments[id];
                  return _buildAppointmentCard(
                    cache[appointment.patientId].name,
                    Utils.formatTime(appointment.start.toDate()),
                    Utils.relativeTime(appointment.start),
                    '${Utils.formatTime(appointment.start.toDate())} ${Utils.formatDate(appointment.start.toDate())}',
                    Icons.person,
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Consultas Pendentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MedicalColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.profile?.pendingAppointments.length ?? 0,
                itemBuilder: (context, id) {
                  final item = state.profile!.pendingAppointments[id];
                  return _buildPendingCard(
                    cache[item.patientId].name,
                    '${Utils.formatTime(item.start.toDate())} ${Utils.formatDate(item.start.toDate())}',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isCompact) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isCompact ? 16 : 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MedicalColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 12),
                const Text(
                  'Posto Saúde',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSaaSNavItem(Icons.dashboard_outlined, 'Dashboard', true, isCompact: isCompact, onTap: () {
                }),
                _buildSaaSNavItem(Icons.calendar_today_outlined, 'Agenda', false, isCompact: isCompact, onTap: () {
                  context.push('/professional/appointments');
                }),
                _buildSaaSNavItem(Icons.chat_bubble_outline_rounded, 'Chats', false, isCompact: isCompact, onTap: () {
                  context.push('/professional/chats');
                }),
                _buildSaaSNavItem(Icons.people_outline, 'Pacientes', false, isCompact: isCompact, onTap: () {}),
                _buildSaaSNavItem(Icons.medical_services_outlined, 'Consultas', false, isCompact: isCompact, onTap: () {}),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                const SizedBox(height: 24),
                _buildSaaSNavItem(Icons.settings_outlined, 'Configurações', false, isCompact: isCompact, onTap: () {
                  context.push('/professional/profile_settings');
                }),
                const Spacer(),
                _buildSaaSNavItem(Icons.logout_outlined, 'Sair', false, isLogout: true, isCompact: isCompact, onTap: () async {
                  final authService = ref.read(authServiceProvider);
                  await authService.signOut();
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo de volta!',
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 32,
                        fontWeight: FontWeight.bold,
                        color: MedicalColors.primary,
                      ),
                    ),
                    Text(
                      'Aqui está o resumo do seu dia',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MedicalColors.primary.withValues(alpha: 0.8), MedicalColors.secondary.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: MedicalColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Hoje',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (isTablet) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximas Consultas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MedicalColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: ListView.builder(
                          itemCount: state.profile?.bookedAppointments.length ?? 0,
                          itemBuilder: (context, id) {
                            final appointment = state.profile!.bookedAppointments[id];
                            return _buildAppointmentCard(
                              cache[appointment.patientId].name,
                              Utils.formatTime(appointment.start.toDate()),
                              Utils.relativeTime(appointment.start),
                              '${Utils.formatTime(appointment.start.toDate())} ${Utils.formatDate(appointment.start.toDate())}',
                              Icons.person,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consultas Pendentes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MedicalColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: ListView.builder(
                          itemCount: state.profile?.pendingAppointments.length ?? 0,
                          itemBuilder: (context, id) {
                            final item = state.profile!.pendingAppointments[id];
                            return _buildPendingCard(
                              cache[item.patientId].name,
                              '${Utils.formatTime(item.start.toDate())} ${Utils.formatDate(item.start.toDate())}',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Próximas Consultas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MedicalColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: state.profile?.bookedAppointments.length ?? 0,
                itemBuilder: (context, id) {
                  final appointment = state.profile!.bookedAppointments[id];
                  return _buildAppointmentCard(
                    cache[appointment.patientId].name,
                    Utils.formatTime(appointment.start.toDate()),
                    Utils.relativeTime(appointment.start),
                    '${Utils.formatTime(appointment.start.toDate())} ${Utils.formatDate(appointment.start.toDate())}',
                    Icons.person,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultas Pendentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MedicalColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: state.profile?.pendingAppointments.length ?? 0,
              itemBuilder: (context, id) {
                final item = state.profile!.pendingAppointments[id];
                return _buildPendingCard(
                  cache[item.patientId].name,
                  '${Utils.formatTime(item.start.toDate())} ${Utils.formatDate(item.start.toDate())}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(String name, String time, String relativeTime, String fullDateTime, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MedicalColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MedicalColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: MedicalColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  relativeTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  fullDateTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: MedicalColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: MedicalColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(String name, String dateTime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateTime,
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaaSNavItem(IconData icon, String title, bool isActive, {bool isLogout = false, bool isCompact = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? MedicalColors.primary.withValues(alpha: 0.15) : null,
              borderRadius: BorderRadius.circular(8),
              border: isActive ? Border.all(color: MedicalColors.primary.withValues(alpha: 0.3)) : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive 
                    ? MedicalColors.primary 
                    : (isLogout ? Colors.red[400] : Colors.white.withValues(alpha: 0.85)),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive 
                        ? MedicalColors.primary 
                        : (isLogout ? Colors.red[400] : Colors.white.withValues(alpha: 0.95)),
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
