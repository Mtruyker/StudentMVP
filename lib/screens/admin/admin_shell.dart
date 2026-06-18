import 'package:flutter/material.dart';
import 'package:studentlk/models/user.dart';
import 'package:studentlk/screens/admin/admin_pages.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({
    required this.user,
    required this.onLogout,
    super.key,
  });

  final AppUser user;
  final VoidCallback onLogout;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AdminDashboardPage(),
      AdminSchedulePage(),
      AdminAnnouncementsPage(),
      AdminStudentsPage(),
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
