import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/screens/base_page.dart';

/// =======================
/// ENUM
/// =======================
enum NotificationType {
  reminder,
  exam,
  system,
}

/// =======================
/// MODEL
/// =======================
class PatientNotification {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final NotificationType type;
  bool seen;

  PatientNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.seen = false,
  });
}

/// =======================
/// SCREEN
/// =======================
class PatientNotificationsScreen extends StatefulWidget {
  const PatientNotificationsScreen({super.key});

  @override
  State<PatientNotificationsScreen> createState() =>
      _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState
    extends State<PatientNotificationsScreen> {
  String selectedStatus = 'all'; // all | read | unread
  NotificationType? selectedType;

  final List<PatientNotification> notifications = [
    PatientNotification(
      id: '1',
      title: 'Consulta agendada',
      description: 'Você tem uma consulta amanhã às 14h',
      date: DateTime.now(),
      type: NotificationType.exam,
    ),
    PatientNotification(
      id: '2',
      title: 'Exame disponível',
      description: 'Seu exame de sangue já pode ser visualizado',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.exam,
      seen: true,
    ),
    PatientNotification(
      id: '3',
      title: 'Atualização do sistema',
      description: 'Nova versão disponível no aplicativo',
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.system,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BasePage(
      webPage: _page(context),
      mobilePage: _page(context),
    );
  }

  /// =======================
  /// PAGE
  /// =======================
  Widget _page(BuildContext context) {
    final filtered = notifications.where((n) {
      if (selectedStatus == 'read' && !n.seen) return false;
      if (selectedStatus == 'unread' && n.seen) return false;
      if (selectedType != null && n.type != selectedType) return false;
      return true;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Voltar
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Voltar'),
                ),

                const SizedBox(height: 24),

                /// Título
                const Text(
                  'Notificações',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// Filtros
                _filters(),

                const SizedBox(height: 24),

                /// Lista
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma notificação encontrada',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, index) {
                            return _notificationCard(filtered[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// =======================
  /// FILTERS
  /// =======================
  Widget _filters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            _statusChip('Todas', 'all'),
            _statusChip('Não lidas', 'unread'),
            _statusChip('Lidas', 'read'),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _typeChip(
              'Lembretes',
              NotificationType.reminder,
              Icons.alarm,
            ),
            _typeChip(
              'Exames',
              NotificationType.exam,
              Icons.science,
            ),
            _typeChip(
              'Sistema',
              NotificationType.system,
              Icons.settings,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedStatus == value,
      onSelected: (_) => setState(() => selectedStatus = value),
    );
  }

  Widget _typeChip(
    String label,
    NotificationType type,
    IconData icon,
  ) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selectedType == type,
      onSelected: (_) {
        setState(() {
          selectedType = selectedType == type ? null : type;
        });
      },
    );
  }

  /// =======================
  /// CARD
  /// =======================
  Widget _notificationCard(PatientNotification n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: n.seen ? Colors.white : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _iconByType(n.type),
            color: _colorByType(n.type),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!n.seen)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  n.description,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatDate(n.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: n.seen,
            onChanged: (v) => setState(() => n.seen = v ?? false),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// HELPERS
  /// =======================
  IconData _iconByType(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.exam:
        return Icons.science;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  Color _colorByType(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.exam:
        return Colors.green;
      case NotificationType.system:
        return Colors.blueGrey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
