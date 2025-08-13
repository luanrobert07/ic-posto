import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Utils {
  static final List<String> _daysOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static DateTime parseDate(String date) {
    final parts = date.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  // ToDo remove this?
  static String formatTime2(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay parseTime(String time) {
    List<String> parts = time.split(":");
    if (parts.length != 2) {
      throw const FormatException("Invalid time format");
    }

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static DateTime dateNow() {
    return DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  static String dayIdToName(int day) {
    return _daysOfWeek[day];
  }

  static String compressJson(List<Map<String, dynamic>>? jsonObject) {
    final jsonString = jsonEncode(jsonObject);
    final compressed = const GZipEncoder().encode(utf8.encode(jsonString));
    return base64Encode(compressed);
  }

  static List<dynamic> decompressJson(String? compressedString) {
    if (compressedString == null) return [];
    if (compressedString.isEmpty) return [];

    final decoded = base64Decode(compressedString);
    final decompressedBytes = const GZipDecoder().decodeBytes(decoded);
    final decompressedJsonString = utf8.decode(decompressedBytes);
    return jsonDecode(decompressedJsonString);
  }

  static List<T> jsonArrayToList<T>(List<dynamic>? json, T Function(Map<String, dynamic>) fromJson) {
    if (json == null) return [];
    if (json.isEmpty) return [];

    return json.map((e) => fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  static bool isSameDay(DateTime? d1, DateTime? d2) {
    if (d1 == null || d2 == null) return false;
    return d1.day == d2.day && d1.month == d2.month && d1.year == d2.year;
  }

  /// Returns Timestamp object if value is already a Timestamp (returned from firestore),
  /// a timestamp map or a int with the seconds since epoch
  static Timestamp? parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value;

    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'];
      final nanoseconds = value['_nanoseconds'];

      if (seconds is int && nanoseconds is int) {
        return Timestamp(seconds, nanoseconds);
      }
    }

    if (value is int) {
      return Timestamp(value, 0);
    }

    throw FormatException('Invalid timestamp format: $value');
  }

  static int getTimezoneOffset() {
    return DateTime.now().timeZoneOffset.inMinutes;
  }

  static String relativeTime(Timestamp timestamp) {
    final now = DateTime.now();
    final target = timestamp.toDate();

    final difference = target.difference(now);
    final isFuture = !difference.isNegative;
    final diff = difference.abs();

    String prefixo = isFuture ? 'Daqui a' : 'Há';

    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$prefixo $months ${months == 1 ? 'mês' : 'meses'}';
    } else if (diff.inDays >= 1) {
      return '$prefixo ${diff.inDays} ${diff.inDays == 1 ? 'dia' : 'dias'}';
    } else if (diff.inHours >= 1) {
      return '$prefixo ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
    } else if (diff.inMinutes >= 1) {
      return '$prefixo ${diff.inMinutes} ${diff.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else if (diff.inSeconds > 0) {
      return '$prefixo ${diff.inSeconds} segundos';
    } else {
      return 'agora';
    }
  }
}
