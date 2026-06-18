import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentlk/models/user.dart';
import 'package:studentlk/store/app_store.dart';
import 'package:studentlk/utils/helpers.dart';
import 'package:studentlk/widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final now = DateTime.now();
    final todayLessons = store.lessonsForGroup(user.groupId ?? '', now.weekday);
    final announcements = store
        .announcementsForGroup(user.groupId)
        .take(2)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        WelcomeHeader(user: user),
        const SizedBox(height: 16),
        SectionTitle(
          title: 'Сегодня',
          action: DateFormat('d MMMM, EEEE', 'ru').format(now),
        ),
        const SizedBox(height: 8),
        if (todayLessons.isEmpty)
          const EmptyState(
            icon: Icons.event_available_outlined,
            title: 'Занятий сегодня нет',
            text: 'Можно проверить объявления учебной части.',
          )
        else
          ...todayLessons.map((lesson) => LessonCard(lesson: lesson)),
        const SizedBox(height: 18),
        const SectionTitle(title: 'Объявления'),
        const SizedBox(height: 8),
        if (announcements.isEmpty)
          const EmptyState(
            icon: Icons.campaign_outlined,
            title: 'Пока нет объявлений',
            text: 'Новые сообщения появятся здесь.',
          )
        else
          ...announcements.map(
            (item) => AnnouncementCard(announcement: item),
          ),
      ],
    );
  }
}

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Text(
                user.firstName.characters.first,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Здравствуйте, ${user.firstName}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.groupName} · ${user.course} курс',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withAlpha(220),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({required this.user, super.key});

  final AppUser user;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late int _selectedDay = DateTime.now().weekday.clamp(
    DateTime.monday,
    DateTime.saturday,
  );

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lessons = store.lessonsForGroup(
      widget.user.groupId ?? '',
      _selectedDay,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionTitle(title: 'Расписание'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('Пн')),
              ButtonSegment(value: 2, label: Text('Вт')),
              ButtonSegment(value: 3, label: Text('Ср')),
              ButtonSegment(value: 4, label: Text('Чт')),
              ButtonSegment(value: 5, label: Text('Пт')),
              ButtonSegment(value: 6, label: Text('Сб')),
            ],
            selected: {_selectedDay},
            onSelectionChanged: (value) =>
                setState(() => _selectedDay = value.first),
          ),
        ),
        const SizedBox(height: 16),
        if (lessons.isEmpty)
          EmptyState(
            icon: Icons.calendar_today_outlined,
            title: '${weekdayName(_selectedDay)} свободен',
            text:
                'Расписание для группы ${widget.user.groupName} не заполнено.',
          )
        else
          ...lessons.map((lesson) => LessonCard(lesson: lesson)),
      ],
    );
  }
}

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({required this.user, super.key});

  final AppUser user;

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  var _importantOnly = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final items = store
        .announcementsForGroup(widget.user.groupId)
        .where((item) {
          return !_importantOnly || item.isImportant;
        })
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        SectionTitle(
          title: 'Объявления',
          trailing: FilterChip(
            label: const Text('Важные'),
            selected: _importantOnly,
            onSelected: (value) => setState(() => _importantOnly = value),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none,
            title: 'Нет объявлений',
            text: 'Попробуйте отключить фильтр важных сообщений.',
          )
        else
          ...items.map((item) => AnnouncementCard(announcement: item)),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.user, required this.onLogout, super.key});

  final AppUser user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionTitle(title: 'Профиль'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProfileRow(
                  icon: Icons.person,
                  label: 'ФИО',
                  value: user.fullName,
                ),
                ProfileRow(
                  icon: Icons.groups,
                  label: 'Группа',
                  value: user.groupName ?? '-',
                ),
                ProfileRow(
                  icon: Icons.school,
                  label: 'Специальность',
                  value: user.specialty ?? '-',
                ),
                ProfileRow(
                  icon: Icons.timeline,
                  label: 'Курс',
                  value: '${user.course ?? '-'}',
                ),
                ProfileRow(
                  icon: Icons.badge,
                  label: 'Студенческий',
                  value: user.studentCard ?? '-',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Выйти из аккаунта'),
        ),
      ],
    );
  }
}
