import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../features/shared/features/appointment/models/appointment.dart';

part 'notification_state.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default({}) Map<String, dynamic> chatNotifications,
    @Default([]) List<Appointment> pendingAppointments,
  }) = _NotificationState;
}
