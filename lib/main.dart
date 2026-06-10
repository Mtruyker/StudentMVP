import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  Intl.defaultLocale = 'ru';

  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
  }

  runApp(StudentCabinetApp(store: AppStore.demo()));
}

class StudentCabinetApp extends StatelessWidget {
  const StudentCabinetApp({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F6B4F),
      primary: const Color(0xFF1E6A4A),
      secondary: const Color(0xFF2D6CDF),
      tertiary: const Color(0xFFF2B705),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Личный кабинет НАТТ',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8F5),
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E8DE)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDDE5D7)),
          ),
        ),
      ),
      home: AuthGate(store: store),
    );
  }
}

enum UserRole { student, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.role,
    this.groupId,
    this.groupName,
    this.specialty,
    this.course,
    this.studentCard,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String? groupId;
  final String? groupName;
  final String? specialty;
  final int? course;
  final String? studentCard;

  String get firstName => fullName.split(' ').first;
}

class StudentGroup {
  const StudentGroup({
    required this.id,
    required this.name,
    required this.course,
    required this.specialty,
  });

  final String id;
  final String name;
  final int course;
  final String specialty;
}

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

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isImportant,
    this.targetGroupId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isImportant;
  final String? targetGroupId;
}

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

class AuthGate extends StatefulWidget {
  const AuthGate({required this.store, super.key});

  final AppStore store;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AppUser? _currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user == null) {
      return LoginScreen(
        store: widget.store,
        onLogin: (user) => setState(() => _currentUser = user),
      );
    }

    if (user.role == UserRole.admin) {
      return AdminShell(
        store: widget.store,
        user: user,
        onLogout: () => setState(() => _currentUser = null),
      );
    }

    return StudentShell(
      store: widget.store,
      user: user,
      onLogout: () => setState(() => _currentUser = null),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.store, required this.onLogin, super.key});

  final AppStore store;
  final ValueChanged<AppUser> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _role = UserRole.student;
  final _loginController = TextEditingController(text: 'НАТТ-2026-021');
  final _passwordController = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    widget.onLogin(
      _role == UserRole.student
          ? widget.store.demoStudent
          : widget.store.demoAdmin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 42,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Личный кабинет студента',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ГАПОУ СО "Новоузенский агротехнологический техникум"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(
                        value: UserRole.student,
                        label: Text('Студент'),
                        icon: Icon(Icons.person_outline),
                      ),
                      ButtonSegment(
                        value: UserRole.admin,
                        label: Text('Админ'),
                        icon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                    ],
                    selected: {_role},
                    onSelectionChanged: (value) {
                      setState(() => _role = value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _loginController,
                    decoration: const InputDecoration(
                      labelText: 'Логин',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _login,
                    icon: const Icon(Icons.login),
                    label: const Text('Войти'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MVP работает на демо-данных. Supabase подключается через SUPABASE_URL и SUPABASE_ANON_KEY.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}

class StudentShell extends StatefulWidget {
  const StudentShell({
    required this.store,
    required this.user,
    required this.onLogout,
    super.key,
  });

  final AppStore store;
  final AppUser user;
  final VoidCallback onLogout;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(store: widget.store, user: widget.user),
      SchedulePage(store: widget.store, user: widget.user),
      AnnouncementsPage(store: widget.store, user: widget.user),
      ProfilePage(user: widget.user, onLogout: widget.onLogout),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('НАТТ'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Расписание',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Объявления',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.store, required this.user, super.key});

  final AppStore store;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayLessons = store.lessonsForGroup(user.groupId ?? '', now.weekday);
    final announcements = store
        .announcementsForGroup(user.groupId)
        .take(2)
        .toList();

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
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
      },
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
  const SchedulePage({required this.store, required this.user, super.key});

  final AppStore store;
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
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final lessons = widget.store.lessonsForGroup(
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
      },
    );
  }
}

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({required this.store, required this.user, super.key});

  final AppStore store;
  final AppUser user;

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  var _importantOnly = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final items = widget.store
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
      },
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

class AdminShell extends StatefulWidget {
  const AdminShell({
    required this.store,
    required this.user,
    required this.onLogout,
    super.key,
  });

  final AppStore store;
  final AppUser user;
  final VoidCallback onLogout;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboardPage(store: widget.store),
      AdminSchedulePage(store: widget.store),
      AdminAnnouncementsPage(store: widget.store),
      AdminStudentsPage(store: widget.store),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Обзор',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Пары',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            label: 'Новости',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Студенты',
          ),
        ],
      ),
    );
  }
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
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
      },
    );
  }
}

class AdminSchedulePage extends StatelessWidget {
  const AdminSchedulePage({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
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
      },
    );
  }
}

class AdminAnnouncementsPage extends StatelessWidget {
  const AdminAnnouncementsPage({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
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
      },
    );
  }
}

class AdminStudentsPage extends StatelessWidget {
  const AdminStudentsPage({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
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

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    this.action,
    this.trailing,
    super.key,
  });

  final String title;
  final String? action;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ?trailing,
      ],
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard({required this.lesson, this.subtitle, super.key});

  final Lesson lesson;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${lesson.lessonNumber}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.subject,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatTime(lesson.startTime)} - ${formatTime(lesson.endTime)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subtitle ?? lesson.teacher} · каб. ${lesson.classroom}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({required this.announcement, super.key});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  announcement.isImportant
                      ? Icons.priority_high_rounded
                      : Icons.campaign_outlined,
                  color: announcement.isImportant
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(announcement.body),
            const SizedBox(height: 10),
            Text(
              DateFormat('d MMMM, HH:mm', 'ru').format(announcement.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 38, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
