import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/calendar/screens/calendar_screen.dart';
import 'package:test/main.dart';
import 'package:test/notifications/screens/notification_screen.dart';
import 'package:test/profile/screens/profile_screen.dart';
import 'package:test/search/screens/search_screen.dart';
import 'package:test/services/screens/services_screen.dart';

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  final List<Widget> screens = [
    ServicesPage(),
    const SearchPage(),
    const CalendarPage(),
    const NoticePage(),
    const ProfileContent(),
  ];

  final List<IconData> icons = [
    Icons.home,
    Icons.search,
    FontAwesomeIcons.calendarCheck,
    FontAwesomeIcons.bell,
    FontAwesomeIcons.user,
  ];

  final List<String> fullLabels = [
    'Сервисы',
    'Поиск',
    'Календарь',
    'Уведом-я',
    'Профиль',
  ];

  final List<String> shortLabels = [
    'Сервисы',
    'Поиск',
    'Календ.',
    'Уведом-я',
    'Профиль',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final Color mainColor = const Color(0xFF164F94);
    final Color inactiveColor = const Color.fromARGB(255, 106, 106, 106);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: selectedIndex,
        height: 50,
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: mainColor,
        animationDuration: const Duration(milliseconds: 450),
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        items: List.generate(icons.length, (index) {
          final bool isSelected = selectedIndex == index;

          final String label = (index == 3 || index == 2 && isSelected)
              ? shortLabels[index]
              : fullLabels[index];
          final Color color = isSelected ? Colors.white : inactiveColor;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icons[index],
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: 'CeraPro',
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
