import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import 'package:posto/features/patient/book_appointment/state_management/book_appointment_state.dart';
import 'package:posto/features/shared/features/appointment/models/appointment.dart';

import '../../../../core/utils/utils.dart';
import '../../../shared/features/providers/professional_profile_provider/public_professional_profile_service.dart';
import '../logic/slot_generator.dart';

part 'book_appointment_provider.g.dart';

@riverpod
class BookAppointmentNotifier extends _$BookAppointmentNotifier {
  KeepAliveLink? _link;
  late SlotGenerator _slotGenerator;

  @override
  BookAppointmentState build(String userId) {
    print('Building book appt for user $userId');
    _link = ref.keepAlive();
    ref.onDispose(() => _link?.close());

    DateTime now = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    return BookAppointmentState(
      focusedDay: now,
      selectedDay: now,
      calendarStartDay: now,
      calendarEndDay: now.add(Duration(days: 180)),
    );
  }

  Future<void> setProfessionalProfile(String profileId) async {
    state = state.copyWith(isLoading: true);

    final profile = await ref.read(publicProfessionalProfileServiceProvider).getProfileFromId(profileId);
    ref.read(profileCacheServiceProvider.notifier).addProfile(profile.id, profile);

    print('Setting slot generator');
    _slotGenerator = SlotGenerator.fromProfile(profile);

    state = state.copyWith(
      profile: profile,
      calendarEndDay: DateTime.now().add(Duration(days: 180)),
      isLoading: false,
    );
  }

  void selectDay(DateTime day) {
    if (Utils.isSameDay(state.selectedDay, day)) return;

    state = state.copyWith(
      selectedDay: day,
      selectedSlot: null,
    );
  }

  void setFocusedDay(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
  }

  bool isDayAvailableForAppointments(DateTime day) {
    if (!_slotGenerator.isDayAvailableForAppointments(day)) return false;
    if (getAppointmentsSlots(day).isEmpty) return false;

    return true;
  }

  List<DateTime> getAppointmentsSlots(DateTime? selectedDay) {
    return _slotGenerator.getSlotsForDay(selectedDay);
  }

  void selectAppointmentSlot(DateTime? slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  Future<void> requestAppointment() async {
    if (state.selectedSlot == null) return;

    state = state.copyWith(isLoading: true);
    DateTime start = state.selectedSlot!;
    DateTime end = start.add(Duration(minutes: state.profile!.sessionDuration));

    Appointment appointment = Appointment.createRequest(state.profile!.id, Timestamp.fromDate(start), Timestamp.fromDate(end));

    try {
      await ref.read(publicProfessionalProfileServiceProvider).requestAppointment(appointment);
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(
        selectedSlot: null,
        isLoading: false,
      );
    }

    state.profile!.pendingAppointments.add(appointment);
  }
}
