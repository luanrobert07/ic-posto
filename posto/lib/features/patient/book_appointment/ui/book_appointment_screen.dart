import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/patient/book_appointment/state_management/book_appointment_provider.dart';
import 'package:posto/features/patient/book_appointment/state_management/book_appointment_state.dart';
import 'package:posto/features/shared/widgets/calendar_widget.dart';
import 'package:posto/features/shared/screens/base_page.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/features/dialogs/error_dialog.dart';
import '../../chats/state_management/patient_chats_provider.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  late BookAppointmentState state;
  late BookAppointmentNotifier notifier;
  List<DateTime> availableSlots = [];

  @override
  Widget build(BuildContext context) {
    final String uid = AuthService.getUserUid()!;
    state = ref.watch(bookAppointmentNotifierProvider(uid));
    notifier = ref.read(bookAppointmentNotifierProvider(uid).notifier);

    availableSlots = notifier.getAppointmentsSlots(state.selectedDay);

    return BasePage(
      webPage: webPage(),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage() {
    if (state.isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFB), Color(0xFFE3F2FD)],
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
          colors: [Color(0xFFF8FAFB), Color(0xFFE3F2FD)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF475569),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF475569).withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Agendar Consulta',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Selecione uma data e horário disponível para sua consulta',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      final String uid = AuthService.getUserUid()!;
                      ref.read(patientChatsNotifierProvider(uid).notifier).setTempChat(state.profile!);
                      context.push('/patient/chats');
                    },
                    child: Text('Open chat'),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informações do Paciente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              state.profile!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              state.profile!.contact,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecionar Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Theme(
                          data: Theme.of(context).copyWith(
                            textTheme: Theme.of(context).textTheme.copyWith(
                              bodyLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                              bodyMedium: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                              bodySmall: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                              headlineSmall: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20),
                              titleMedium: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                              titleSmall: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                              labelLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                              headlineMedium: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 22),
                              titleLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              onSurface: Colors.black,
                              primary: const Color(0xFF475569),
                              onPrimary: Colors.white,
                              surface: Colors.white,
                            ),
                            iconTheme: const IconThemeData(color: Colors.black, size: 24),
                            appBarTheme: const AppBarTheme(
                              foregroundColor: Colors.black,
                              iconTheme: IconThemeData(color: Colors.black),
                              titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20),
                            ),
                          ),
                          child: CalendarWidget(
                            focusedDay: state.focusedDay,
                            calendarStartDay: state.calendarStartDay,
                            calendarEndDay: state.calendarEndDay,
                            isDayAvailableForAppointments: ref.read(bookAppointmentNotifierProvider(AuthService.getUserUid()!).notifier).isDayAvailableForAppointments,
                            highlightDays: [state.selectedDay],
                            onPageChanged: (newFocusedDay) {
                              notifier.setFocusedDay(newFocusedDay);
                            },
                            onDaySelected: (day) {
                              notifier.selectDay(day);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecionar Horário',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.white,
                              cardColor: Colors.white,
                            ),
                            child: DropdownButton<DateTime>(
                              value: state.selectedSlot,
                              hint: Text(
                                availableSlots.isEmpty ? 'Nenhum horário disponível' : 'Selecione um horário',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                ),
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF64748B),
                              ),
                              dropdownColor: Colors.white,
                              items: availableSlots.map((slot) {
                                return DropdownMenuItem<DateTime>(
                                  value: slot,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      Utils.formatTime(slot),
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: notifier.selectAppointmentSlot,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await notifier.requestAppointment();
                        } catch (e, _) {
                          if (mounted) {
                            ErrorDialog.show('Ocorreu um erro ao marcar sessão, tente novamente mais tarde.');
                          }
                          return;
                        }

                        if (!mounted) {
                          return;
                        }

                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: const EdgeInsets.all(24),
                            title: const Text(
                              'Sucesso',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            content: const Text(
                              'Pedido foi enviado!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF475569),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (!mounted) {
                          return;
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF475569),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFF475569).withValues(alpha: 0.3),
                      ),
                      child: const Text(
                        'Confirmar Agendamento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget mobilePage() {
    if (state.isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFB), Color(0xFFE3F2FD)],
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
          colors: [Color(0xFFF8FAFB), Color(0xFFE3F2FD)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF475569).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Agendar Consulta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Selecione data e horário',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paciente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: Color(0xFF64748B), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.profile!.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, color: Color(0xFF64748B), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          state.profile!.contact,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: Theme.of(context).textTheme.copyWith(
                          bodyLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          bodyMedium: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          bodySmall: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          headlineSmall: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
                          titleMedium: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                          titleSmall: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12),
                          labelLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                          headlineMedium: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20),
                          titleLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          onSurface: Colors.black,
                          primary: const Color(0xFF475569),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                        ),
                        iconTheme: const IconThemeData(color: Colors.black, size: 20),
                        appBarTheme: const AppBarTheme(
                          foregroundColor: Colors.black,
                          iconTheme: IconThemeData(color: Colors.black),
                          titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                      child: CalendarWidget(
                        focusedDay: state.focusedDay,
                        calendarStartDay: state.calendarStartDay,
                        calendarEndDay: state.calendarEndDay,
                        isDayAvailableForAppointments: ref.read(bookAppointmentNotifierProvider(AuthService.getUserUid()!).notifier).isDayAvailableForAppointments,
                        highlightDays: [state.selectedDay],
                        onPageChanged: (newFocusedDay) {
                          notifier.setFocusedDay(newFocusedDay);
                        },
                        onDaySelected: (day) {
                          notifier.selectDay(day);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Horário',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.white,
                          cardColor: Colors.white,
                        ),
                        child: DropdownButton<DateTime>(
                          value: state.selectedSlot,
                          hint: Text(
                            availableSlots.isEmpty ? 'Nenhum horário disponível' : 'Selecione um horário',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 20),
                          dropdownColor: Colors.white,
                          items: availableSlots.map((slot) {
                            return DropdownMenuItem<DateTime>(
                              value: slot,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  Utils.formatTime(slot),
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: notifier.selectAppointmentSlot,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await notifier.requestAppointment();
                    } catch (e, _) {
                      if (mounted) {
                        ErrorDialog.show('Ocorreu um erro ao marcar sessão, tente novamente mais tarde.');
                      }
                      return;
                    }

                    if (!mounted) {
                      return;
                    }

                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(20),
                        title: const Text(
                          'Sucesso',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        content: const Text(
                          'Pedido foi enviado!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF475569),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (!mounted) {
                      return;
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF475569),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                    shadowColor: const Color(0xFF475569).withValues(alpha: 0.3),
                  ),
                  child: const Text(
                    'Confirmar Agendamento',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
