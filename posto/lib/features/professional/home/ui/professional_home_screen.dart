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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState
    extends ConsumerState<ProfessionalHomeScreen> {
  late ProfessionalHomeState state;
  late ProfessionalHomeNotifier notifier;
  late Map<String, dynamic> cache;

  // ===== NOVA COMUNICAÇÃO (estado isolado) =====
  final TextEditingController _commTitleController = TextEditingController();
  final TextEditingController _commMessageController = TextEditingController();
  final TextEditingController _commPatientController = TextEditingController();
  String _commType = 'Aviso';
  String _commAudience = 'Todos';

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

  // ================= RESPONSIVE =================
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

  // ================= MOBILE =================
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
              _buildMobileAgenda(),
              const SizedBox(height: 32),
              _buildProfessionalCommunicationCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAgenda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  // ================= SIDEBAR =================
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
                _buildSaaSNavItem(Icons.dashboard_outlined, 'Dashboard', true,
                    isCompact: isCompact),
                _buildSaaSNavItem(Icons.calendar_today_outlined, 'Agenda', false,
                    isCompact: isCompact,
                    onTap: () =>
                        context.push('/professional/appointments')),
                _buildSaaSNavItem(Icons.chat_bubble_outline_rounded, 'Chats',
                    false,
                    isCompact: isCompact,
                    onTap: () => context.push('/professional/chats')),
                const Spacer(),
                _buildSaaSNavItem(Icons.logout_outlined, 'Sair', false,
                    isLogout: true,
                    isCompact: isCompact, onTap: () async {
                  await ref.read(authServiceProvider).signOut();
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= MAIN CONTENT =================
  Widget _buildMainContent(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximas Consultas',
            style: TextStyle(
              fontSize: isTablet ? 24 : 28,
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
          const SizedBox(height: 32),
          _buildProfessionalCommunicationCard(),
        ],
      ),
    );
  }

  // ================= RIGHT SIDEBAR =================
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

  // ================= NOVA COMUNICAÇÃO =================
  Widget _buildProfessionalCommunicationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: MedicalColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Educação em Saúde',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _commLabel('Tipo'),
          _commChips(['Aviso', 'Lembrete', 'Campanha', 'Educação'], _commType,
              (v) => setState(() => _commType = v)),

          const SizedBox(height: 16),

          _commLabel('Enviar para'),
          _commChips(['Todos', 'Paciente'], _commAudience,
              (v) => setState(() => _commAudience = v)),

          if (_commAudience == 'Paciente') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _commPatientController,
              decoration: _commInput('Paciente'),
            ),
          ],

          const SizedBox(height: 16),
          TextField(
            controller: _commTitleController,
            decoration: _commInput('Título'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commMessageController,
            maxLines: 4,
            decoration: _commInput('Mensagem'),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendCommunication,
              style: ElevatedButton.styleFrom(
                backgroundColor: MedicalColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Enviar comunicação',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendCommunication() {
    _commTitleController.clear();
    _commMessageController.clear();
    _commPatientController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comunicação enviada')),
    );
  }

  // ================= HELPERS =================
  Widget _commLabel(String text) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text));

  Widget _commChips(
    List<String> values,
    String selected,
    void Function(String) onSelect,
  ) {
    return Wrap(
      spacing: 8,
      children: values
          .map((v) => ChoiceChip(
                label: Text(v),
                selected: v == selected,
                onSelected: (_) => onSelect(v),
              ))
          .toList(),
    );
  }

  InputDecoration _commInput(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: MedicalColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  // ================= CARDS EXISTENTES =================
  Widget _buildAppointmentCard(String name, String time, String relativeTime,
      String fullDateTime, IconData icon) {
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
          Icon(icon, color: MedicalColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(relativeTime,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(name),
                Text(fullDateTime,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(
                  color: MedicalColors.accent,
                  fontWeight: FontWeight.w600)),
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
          Text(name,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(dateTime,
              style:
                  TextStyle(fontSize: 12, color: Colors.amber[900])),
        ],
      ),
    );
  }

  Widget _buildSaaSNavItem(IconData icon, String title, bool isActive,
      {bool isLogout = false,
      bool isCompact = false,
      VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? MedicalColors.primary.withValues(alpha: 0.15)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 18,
                    color: isActive
                        ? MedicalColors.primary
                        : (isLogout
                            ? Colors.red[400]
                            : Colors.white.withValues(alpha: 0.85))),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive
                          ? MedicalColors.primary
                          : (isLogout
                              ? Colors.red[400]
                              : Colors.white.withValues(alpha: 0.95)),
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
