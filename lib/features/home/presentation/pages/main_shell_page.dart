import 'package:flutter/material.dart';
import 'package:waqf_insight/features/home/presentation/pages/assets_tab_page.dart';
import 'package:waqf_insight/features/home/presentation/widgets/main_shell_scope.dart';
import 'package:waqf_insight/features/staff/presentation/pages/staff_tab_page.dart';
import 'package:waqf_insight/features/home/presentation/pages/home_tab_page.dart';
import 'package:waqf_insight/features/profile/presentation/pages/profile_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  static const _tabs = [
    _NavTab(
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard_rounded,
      label: 'الرئيسية',
    ),
    _NavTab(
      icon: Icons.domain_rounded,
      activeIcon: Icons.domain_rounded,
      label: 'الأملاك',
    ),
    _NavTab(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      label: 'الموظفون',
    ),
    _NavTab(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'حسابي',
    ),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomeTabPage(),
      AssetsTabPage(),
      StaffTabPage(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MainShellScope(
      selectTab: (index) => setState(() => _currentIndex = index),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        extendBody: true,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                height: 68,
                elevation: 0,
                backgroundColor: colorScheme.surfaceContainerHighest,
                indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                destinations: [
                  for (final tab in _tabs)
                    NavigationDestination(
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(
                        tab.activeIcon,
                        color: colorScheme.primary,
                      ),
                      label: tab.label,
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

class _NavTab {
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
