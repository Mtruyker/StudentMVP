import 'package:flutter/material.dart';

String formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String weekdayName(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'Понедельник',
    DateTime.tuesday => 'Вторник',
    DateTime.wednesday => 'Среда',
    DateTime.thursday => 'Четверг',
    DateTime.friday => 'Пятница',
    DateTime.saturday => 'Суббота',
    _ => 'Воскресенье',
  };
}
