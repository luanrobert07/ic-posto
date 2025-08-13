import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/features/providers/professional_profile_provider/professional_profile.dart';

part 'book_appointment_state.freezed.dart';

@freezed
abstract class BookAppointmentState with _$BookAppointmentState {
  const factory BookAppointmentState({
    ProfessionalProfile? profile,
    required DateTime focusedDay,
    required DateTime selectedDay,
    required DateTime calendarStartDay,
    required DateTime calendarEndDay,
    DateTime? selectedSlot,
    @Default(false) bool isLoading,
  }) = _BookAppointmentState;
}
