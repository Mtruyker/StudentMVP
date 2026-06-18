import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentlk/models/user.dart';
import 'package:studentlk/store/app_store.dart';
import 'package:studentlk/utils/helpers.dart';
import 'package:studentlk/widgets/widgets.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionTitle(title: 'Обзор MVP'),
        const SizedBox(height: 12),
        MetricGrid(
          metrics: [
            MetricData(
              'Группы',
              '${store.groups.length}',
              Icons.groups_outlined,
            ),
            MetricData(
              'Студенты',
              '${store.users.where((user) => user.role == UserRole.student).length}',
              Icons.people_outline,
            ),
            MetricData(
              'Пары',
              '${store.lessons.length}',
              Icons.event_note_outlined,
            ),
            MetricData(
              'Объявления',
              '${store.announcements.length}',
              Icons.campaign_outlined,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionTitle(title: 'Группы'),
        const SizedBox(height: 8),
        ...store.groups.map((group) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.class_outlined),
              title: Text(group.name),
              subtitle: Text('${group.course} курс · ${group.specialty}'),
            ),
          );
        }),
      ],
    );
  }
}

class AdminSchedulePage extends StatelessWidget {
  const AdminSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          const SectionTitle(title: 'Расписание групп'),
          const SizedBox(height: 12),
          for (final group in store.groups) ...[
            Text(
              group.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ...store.allLessonsForGroup(group.id).map((lesson) {
              return LessonCard(
                lesson: lesson,
                subtitle: weekdayName(lesson.weekday),
              );
            }),
            if (store.allLessonsForGroup(group.id).isEmpty)
              const EmptyState(
                icon: Icons.calendar_today_outlined,
                title: 'Расписание не заполнено',
                text: 'Добавьте первую пару через кнопку ниже.',
              ),
            const SizedBox(height: 16),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddLessonSheet(context, store),
        icon: const Icon(Icons.add),
        label: const Text('Пара'),
      ),
    );
  }
}

class AdminAnnouncementsPage extends StatelessWidget {
  const AdminAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          const SectionTitle(title: 'Объявления'),
          const SizedBox(height: 12),
          if (store.announcements.isEmpty)
            const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'Нет объявлений',
              text: 'Опубликуйте первое сообщение для студентов.',
            )
          else
            ...store.announcements.map(
              (item) => AnnouncementCard(announcement: item),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddAnnouncementSheet(context, store),
        icon: const Icon(Icons.add),
        label: const Text('Новость'),
      ),
    );
  }
}

class AdminStudentsPage extends StatelessWidget {
  const AdminStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final students = store.users
        .where((user) => user.role == UserRole.student)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionTitle(title: 'Студенты'),
        const SizedBox(height: 12),
        ...students.map((student) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(student.firstName.characters.first),
              ),
              title: Text(student.fullName),
              subtitle: Text('${student.groupName} · ${student.specialty}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        }),
      ],
    );
  }
}

class MetricData {
  const MetricData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({required this.metrics, super.key});

  final List<MetricData> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        return GridView.builder(
          itemCount: metrics.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 4 : 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: wide ? 2.25 : 1.65,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            final theme = Theme.of(context);

            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(metric.icon, color: theme.colorScheme.primary),
                    Text(
                      metric.value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      metric.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Future<void> showAddAnnouncementSheet(
  BuildContext context,
  AppStore store,
) async {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  var isImportant = false;
  String? targetGroupId;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Новое объявление',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Заголовок'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Текст'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  initialValue: targetGroupId,
                  decoration: const InputDecoration(labelText: 'Получатели'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Все группы'),
                    ),
                    ...store.groups.map(
                      (group) => DropdownMenuItem<String?>(
                        value: group.id,
                        child: Text(group.name),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setSheetState(() => targetGroupId = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Важное объявление'),
                  value: isImportant,
                  onChanged: (value) =>
                      setSheetState(() => isImportant = value),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        bodyController.text.trim().isEmpty) {
                      return;
                    }
                    store.addAnnouncement(
                      title: titleController.text.trim(),
                      body: bodyController.text.trim(),
                      isImportant: isImportant,
                      targetGroupId: targetGroupId,
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Опубликовать'),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  titleController.dispose();
  bodyController.dispose();
}

Future<void> showAddLessonSheet(BuildContext context, AppStore store) async {
  final subjectController = TextEditingController();
  final teacherController = TextEditingController();
  final classroomController = TextEditingController();
  var groupId = store.groups.first.id;
  var weekday = DateTime.monday;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Добавить пару',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: groupId,
                  decoration: const InputDecoration(labelText: 'Группа'),
                  items: store.groups
                      .map(
                        (group) => DropdownMenuItem(
                          value: group.id,
                          child: Text(group.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setSheetState(() => groupId = value ?? groupId),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: weekday,
                  decoration: const InputDecoration(labelText: 'День недели'),
                  items: List.generate(6, (index) {
                    final day = index + 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text(weekdayName(day)),
                    );
                  }),
                  onChanged: (value) =>
                      setSheetState(() => weekday = value ?? weekday),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Предмет'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: teacherController,
                  decoration: const InputDecoration(labelText: 'Преподаватель'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: classroomController,
                  decoration: const InputDecoration(labelText: 'Кабинет'),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    if (subjectController.text.trim().isEmpty ||
                        teacherController.text.trim().isEmpty ||
                        classroomController.text.trim().isEmpty) {
                      return;
                    }
                    store.addLesson(
                      groupId: groupId,
                      weekday: weekday,
                      subject: subjectController.text.trim(),
                      teacher: teacherController.text.trim(),
                      classroom: classroomController.text.trim(),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить'),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  subjectController.dispose();
  teacherController.dispose();
  classroomController.dispose();
}
