import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/auth/domain/auth_notifier.dart';
import 'package:test/auth/screens/auth_screen.dart';
import 'package:test/main.dart';
import 'package:test/profile/screens/edit_profile_page.dart';
import 'package:test/profile/domain/profile_service.dart';
import 'package:test/profile/screens/profile_screen.dart';
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:test/services/screens/abscence_screen.dart';
import 'package:test/services/screens/attendance_screen.dart';
import 'package:test/services/screens/documents_screen.dart';
import 'package:test/services/screens/payments_screen.dart';

class ServicesPage extends ConsumerStatefulWidget {
  ServicesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  final ProfileService _profileService = ProfileService();
  late Future<User?> _fetchUserFuture;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _fetchUserFuture = _profileService.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      body: Column(
        children: [
          FutureBuilder<User?>(
            future: _fetchUserFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  color: Colors.white,
                  child: const Row(
                    children: [
                      CircleAvatar(
                          radius: 24, child: CircularProgressIndicator()),
                      SizedBox(width: 12),
                      Text("Загрузка..."),
                    ],
                  ),
                );
              }

              final user = snapshot.data;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Профиль с аватаром
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (user != null) {
                              ref.read(selectedIndexProvider.notifier).state =
                                  4;
                            }
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: user?.photo_link != null
                                ? NetworkImage(user!.photo_link!)
                                : null,
                            child: user?.photo_link == null
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Добро пожаловать,',
                              style: TextStyle(
                                fontFamily: 'CeraPro',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              user != null
                                  ? '${user.surname} ${user.name}'
                                  : 'Загрузка...',
                              style: const TextStyle(
                                fontFamily: 'CeraPro',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    GestureDetector(
                      onTap: () {
                        ref.read(selectedIndexProvider.notifier).state = 3;
                      },
                      child: const Icon(
                        FontAwesomeIcons.bell,
                        size: 28,
                        color: Color(0xFF164F94),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: SafeArea(
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (RouteSettings settings) {
                  WidgetBuilder builder;
                  switch (settings.name) {
                    case '/':
                      builder = (BuildContext _) => _servicesList(context);
                      break;
                    case '/documents':
                      builder = (BuildContext _) => const DocumentsListScreen();
                      break;
                    case '/absence':
                      builder =
                          (BuildContext _) => const AbsenceRequestScreen();
                      break;
                    // case '/income':
                    //   builder = (BuildContext _) => const PaymentsScreen();
                    //   break;
                    case '/attendance':
                      builder = (BuildContext _) => const AttendanceScreen();
                      break;
                    default:
                      throw Exception('Invalid route: ${settings.name}');
                  }
                  return MaterialPageRoute(
                      builder: builder, settings: settings);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _servicesList(BuildContext context) {
    return FutureBuilder<String?>(
      future: UserPreferences.getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final role = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // _buildServiceTile(
              //   context,
              //   icon: FontAwesomeIcons.moneyCheckDollar,
              //   label: 'Мои доходы',
              //   bgColor: Colors.indigo.shade600,
              //   routeName: '/income',
              // ),
              const SizedBox(height: 16),
              _buildServiceTile(
                context,
                icon: FontAwesomeIcons.fileLines,
                label: 'Мои документы',
                bgColor: Colors.teal.shade600,
                routeName: '/documents',
              ),
              const SizedBox(height: 16),
              _buildServiceTile(
                context,
                icon: FontAwesomeIcons.planeDeparture,
                label: 'Отпуска',
                bgColor: Colors.deepOrange.shade500,
                routeName: '/absence',
              ),
              const SizedBox(height: 16),
              if (role == 'manager')
                _buildServiceTile(
                  context,
                  icon: FontAwesomeIcons.calendarCheck,
                  label: 'Табель',
                  bgColor: Colors.blue.shade700,
                  routeName: '/attendance',
                ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildServiceTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required String routeName,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: bgColor,
      elevation: 3,
      child: InkWell(
        onTap: () => _navigateToLocalRoute(context, routeName),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              FaIcon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'CeraPro',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLocalRoute(BuildContext context, String routeName) {
    final routes = {
      '/income': const PaymentsScreen(),
      '/documents': const DocumentsListScreen(),
      '/absence': const AbsenceRequestScreen(),
      '/attendance': const AttendanceScreen(),
    };

    final target = routes[routeName];
    if (target != null) {
      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (_) => target));
    } else {
      Navigator.of(context).pushNamed(routeName);
    }
  }
}
