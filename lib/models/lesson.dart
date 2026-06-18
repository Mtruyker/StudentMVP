import 'package:flutter/material.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.groupId,
    required this.weekday,
    required this.lessonNumber,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.teacher,
    required this.classroom,
  });

  final String id;
  final String groupId;
  final int weekday;
  final int lessonNumber;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String subject;
  final String teacher;
  final String classroom;
}
