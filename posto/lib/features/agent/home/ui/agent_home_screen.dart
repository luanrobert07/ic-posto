import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/screens/base_page.dart';

/// =======================
/// DESIGN SYSTEM
/// =======================
class MedicalColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primarySoft = Color(0xFFDBEAFE);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color danger = Color(0xFFDC2626);
}

/// =======================
/// ENUMS
/// =======================
enum NoticeType { general, reminder, exam, campaign }
enum NoticeAudience { group, individual }
enum NoticeMediaType { none, image, video, link }

/// =======================
/// MODELS
/// =======================
class AgentData {
  final String name;
  final int groupSize;
  final int appointments;
  final int visits;

  AgentData({
    required this.name,
    required this.groupSize,
    required this.appointments,
    required this.visits,
  });
}

class Notice {
  final String id;
  final String title;
  final String message;
  final NoticeType type;
  final NoticeAudience audience;
  final NoticeMediaType mediaType;
  final String? mediaName;
  final Uint8List? mediaBytes;

  Notice({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.audience,
    required this.mediaType,
    this.mediaName,
    this.mediaBytes,
  });
}

/// =======================
/// PROVIDERS
/// =======================
final agentDataProvider = Provider(
  (_) => AgentData(
    name: 'João Silva',
    groupSize: 45,
    appointments: 8,
    visits: 5,
  ),
);

final noticesProvider = StateProvider<List<Notice>>((_) => []);

/// =======================
/// NOTIFICAÇÕES
/// =======================
final notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await notificationsPlugin.initialize(
    const InitializationSettings(android: androidInit),
  );
}

Future<void> showNotification(String title, String message) async {
  const details = AndroidNotificationDetails(
    'notice_channel',
    'Informativos',
    importance: Importance.max,
    priority: Priority.high,
  );

  await notificationsPlugin.show(
    0,
    title,
    message,
    const NotificationDetails(android: details),
  );
}

/// =======================
/// SCREEN
/// =======================
class AgentDashboardScreen extends ConsumerStatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  ConsumerState<AgentDashboardScreen> createState() =>
      _AgentDashboardScreenState();
}

class _AgentDashboardScreenState
    extends ConsumerState<AgentDashboardScreen> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final patientController = TextEditingController();

  NoticeType selectedType = NoticeType.general;
  NoticeAudience selectedAudience = NoticeAudience.group;
  NoticeMediaType selectedMediaType = NoticeMediaType.none;

  Uint8List? uploadedFile;
  String? uploadedFileName;

  @override
  void initState() {
    super.initState();
    initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return BasePage(
      webPage: _page(context, authService),
      mobilePage: _page(context, authService),
    );
  }

  Widget _page(BuildContext context, AuthService authService) {
    final agent = ref.watch(agentDataProvider);
    final notices = ref.watch(noticesProvider);

    return Scaffold(
      backgroundColor: MedicalColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MedicalColors.background,
        foregroundColor: MedicalColors.textPrimary,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(agent),
                const SizedBox(height: 32),
                _stats(agent),
                const SizedBox(height: 40),
                _sentNotices(notices),
                const SizedBox(height: 40),
                _communicationCenter(),
                const SizedBox(height: 48),
                TextButton.icon(
                  onPressed: authService.signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da conta'),
                  style: TextButton.styleFrom(
                    foregroundColor: MedicalColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ======================= UI =======================

  Widget _header(AgentData agent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, ${agent.name}',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Você gerencia ${agent.groupSize} pacientes',
          style: const TextStyle(color: MedicalColors.textSecondary),
        ),
      ],
    );
  }

  Widget _stats(AgentData agent) {
    return Row(
      children: [
        _stat('Pacientes', agent.groupSize),
        _stat('Consultas', agent.appointments),
        _stat('Visitas', agent.visits),
      ],
    );
  }

  Widget _stat(String label, int value) {
    return Expanded(
      child: _surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(label,
                style:
                    const TextStyle(color: MedicalColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _sentNotices(List<Notice> notices) {
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informativos enviados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (notices.isEmpty)
            const Text(
              'Nenhum informativo enviado ainda.',
              style: TextStyle(color: MedicalColors.textSecondary),
            )
          else
            ...notices.map(
              (n) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.campaign_outlined),
                title: Text(n.title),
                subtitle: Text(
                  n.mediaName != null
                      ? '${n.message}\n📎 ${n.mediaName}'
                      : n.message,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _communicationCenter() {
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nova comunicação',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          _label('Tipo'),
          _chipRow(
            NoticeType.values,
            selectedType,
            (v) => setState(() => selectedType = v),
            ['Geral', 'Lembrete', 'Exame', 'Campanha'],
          ),

          const SizedBox(height: 20),

          _label('Enviar para'),
          _chipRow(
            NoticeAudience.values,
            selectedAudience,
            (v) => setState(() => selectedAudience = v),
            ['Grupo', 'Individual'],
          ),

          if (selectedAudience == NoticeAudience.individual)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: patientController,
                decoration: _input('Paciente'),
              ),
            ),

          const SizedBox(height: 20),

          TextField(
            controller: titleController,
            decoration: _input('Título'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            maxLines: 4,
            decoration: _input('Mensagem'),
          ),

          const SizedBox(height: 20),

          _label('Mídia'),
          _chipRow(
            NoticeMediaType.values,
            selectedMediaType,
            (v) => setState(() => selectedMediaType = v),
            ['Nenhuma', 'Imagem', 'Vídeo', 'Link'],
          ),

          if (selectedMediaType != NoticeMediaType.none &&
              selectedMediaType != NoticeMediaType.link)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  uploadedFileName ?? 'Selecionar arquivo',
                ),
              ),
            ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendNotice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: MedicalColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Enviar comunicação',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: selectedMediaType == NoticeMediaType.image
          ? FileType.image
          : FileType.video,
    );

    if (result != null) {
      setState(() {
        uploadedFile = result.files.first.bytes;
        uploadedFileName = result.files.first.name;
      });
    }
  }

  void _sendNotice() async {
    final notice = Notice(
      id: DateTime.now().toString(),
      title: titleController.text,
      message: messageController.text,
      type: selectedType,
      audience: selectedAudience,
      mediaType: selectedMediaType,
      mediaBytes: uploadedFile,
      mediaName: uploadedFileName,
    );

    ref.read(noticesProvider.notifier).update((s) => [...s, notice]);
    await showNotification(notice.title, notice.message);

    titleController.clear();
    messageController.clear();
    patientController.clear();
    uploadedFile = null;
    uploadedFileName = null;
    setState(() {
      selectedType = NoticeType.general;
      selectedAudience = NoticeAudience.group;
      selectedMediaType = NoticeMediaType.none;
    });
  }

  /// ======================= HELPERS =======================

  Widget _surface({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: MedicalColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MedicalColors.border),
      ),
      child: child,
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: MedicalColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: MedicalColors.textSecondary,
        ),
      ),
    );
  }

  Widget _chipRow<T>(
    List<T> values,
    T selected,
    void Function(T) onSelect,
    List<String> labels,
  ) {
    return Wrap(
      spacing: 8,
      children: values.map((v) {
        final index = values.indexOf(v);
        return ChoiceChip(
          label: Text(labels[index]),
          selected: v == selected,
          selectedColor: MedicalColors.primarySoft,
          onSelected: (_) => onSelect(v),
        );
      }).toList(),
    );
  }
}
