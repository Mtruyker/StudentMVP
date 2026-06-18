import 'package:flutter/material.dart';
import 'package:studentlk/models/user.dart';
import 'package:studentlk/models/student_group.dart';
import 'package:studentlk/models/lesson.dart';
import 'package:studentlk/models/announcement.dart';

class AppStore extends ChangeNotifier {
  AppStore({
    required this.users,
    required this.groups,
    required this.lessons,
    required this.announcements,
  });

  final List<AppUser> users;
  final List<StudentGroup> groups;
  final List<Lesson> lessons;
  final List<Announcement> announcements;

  static AppStore demo() {
    const groups = [
      StudentGroup(
        id: 'g-11',
        name: 'АТ-11',
        course: 1,
        specialty: 'Агрономия',
      ),
      StudentGroup(
        id: 'g-21',
        name: 'М-21',
        course: 2,
        specialty: 'Механизация сельского хозяйства',
      ),
      StudentGroup(
        id: 'g-31',
        name: 'Э-31',
        course: 3,
        specialty: 'Экономика и бухгалтерский учет',
      ),
    ];

    return AppStore(
      groups: groups,
      users: const [
        AppUser(
          id: 'student-1',
          fullName: 'Алексей Смирнов',
          role: UserRole.student,
          groupId: 'g-21',
          groupName: 'М-21',
          specialty: 'Механизация сельского хозяйства',
          course: 2,
          studentCard: 'НАТТ-2026-021',
        ),
        AppUser(
          id: 'student-2',
          fullName: 'Мария Кузнецова',
          role: UserRole.student,
          groupId: 'g-11',
          groupName: 'АТ-11',
          specialty: 'Агрономия',
          course: 1,
          studentCard: 'НАТТ-2026-011',
        ),
        AppUser(id: 'admin-1', fullName: 'Учебная часть', role: UserRole.admin),
      ],
      lessons: const [
        Lesson(
          id: 'l-1',
          groupId: 'g-21',
          weekday: DateTime.monday,
          lessonNumber: 1,
          startTime: TimeOfDay(hour: 8, minute: 30),
          endTime: TimeOfDay(hour: 10, minute: 0),
          subject: 'Техническая механика',
          teacher: 'Петров В.И.',
          classroom: '204',
        ),
        Lesson(
          id: 'l-2',
          groupId: 'g-21',
          weekday: DateTime.monday,
          lessonNumber: 2,
          startTime: TimeOfDay(hour: 10, minute: 10),
          endTime: TimeOfDay(hour: 11, minute: 40),
          subject: 'Материаловедение',
          teacher: 'Иванова Н.А.',
          classroom: '112',
        ),
        Lesson(
          id: 'l-3',
          groupId: 'g-21',
          weekday: DateTime.tuesday,
          lessonNumber: 1,
          startTime: TimeOfDay(hour: 8, minute: 30),
          endTime: TimeOfDay(hour: 10, minute: 0),
          subject: 'Иностранный язык',
          teacher: 'Сафонова Е.П.',
          classroom: '305',
        ),
        Lesson(
          id: 'l-4',
          groupId: 'g-21',
          weekday: DateTime.wednesday,
          lessonNumber: 2,
          startTime: TimeOfDay(hour: 10, minute: 10),
          endTime: TimeOfDay(hour: 11, minute: 40),
          subject: 'Устройство тракторов',
          teacher: 'Андреев С.К.',
          classroom: 'Лаб. 2',
        ),
        Lesson(
          id: 'l-5',
          groupId: 'g-11',
          weekday: DateTime.monday,
          lessonNumber: 1,
          startTime: TimeOfDay(hour: 8, minute: 30),
          endTime: TimeOfDay(hour: 10, minute: 0),
          subject: 'Ботаника',
          teacher: 'Николаева Т.В.',
          classroom: '109',
        ),
      ],
      announcements: [
        Announcement(
          id: 'a-1',
          title: 'Изменение расписания',
          body: 'Во вторник первая пара пройдет в кабинете 305.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isImportant: true,
          targetGroupId: 'g-21',
        ),
        Announcement(
          id: 'a-2',
          title: 'Собрание старост',
          body: 'Собрание состоится в актовом зале после третьей пары.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isImportant: false,
        ),
      ],
    );
  }

  AppUser get demoStudent =>
      users.firstWhere((user) => user.role == UserRole.student);

  AppUser get demoAdmin =>
      users.firstWhere((user) => user.role == UserRole.admin);

  List<Lesson> lessonsForGroup(String groupId, int weekday) {
    final result =
        lessons
            .where(
              (lesson) =>
                  lesson.groupId == groupId && lesson.weekday == weekday,
            )
            .toList()
          ..sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
    return result;
  }

  List<Lesson> allLessonsForGroup(String groupId) {
    final result = lessons.where((lesson) => lesson.groupId == groupId).toList()
      ..sort((a, b) {
        final dayCompare = a.weekday.compareTo(b.weekday);
        return dayCompare == 0
            ? a.lessonNumber.compareTo(b.lessonNumber)
            : dayCompare;
      });
    return result;
  }

  List<Announcement> announcementsForGroup(String? groupId) {
    final result = announcements.where((announcement) {
      return announcement.targetGroupId == null ||
          announcement.targetGroupId == groupId;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  void addAnnouncement({
    required String title,
    required String body,
    required bool isImportant,
    String? targetGroupId,
  }) {
    announcements.insert(
      0,
      Announcement(
        id: 'a-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        createdAt: DateTime.now(),
        isImportant: isImportant,
        targetGroupId: targetGroupId,
      ),
    );
    notifyListeners();
  }

  void addLesson({
    required String groupId,
    required int weekday,
    required String subject,
    required String teacher,
    required String classroom,
  }) {
    final dayLessons = lessonsForGroup(groupId, weekday);
    lessons.add(
      Lesson(
        id: 'l-${DateTime.now().microsecondsSinceEpoch}',
        groupId: groupId,
        weekday: weekday,
        lessonNumber: dayLessons.length + 1,
        startTime: const TimeOfDay(hour: 12, minute: 10),
        endTime: const TimeOfDay(hour: 13, minute: 40),
        subject: subject,
        teacher: teacher,
        classroom: classroom,
      ),
    );
    notifyListeners();
  }
}
