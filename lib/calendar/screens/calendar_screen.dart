import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test/calendar/domain/calendar_service.dart';
import 'package:test/notifications/data/notification.dart';
import 'package:test/notifications/domain/notification_service.dart';
import 'package:test/user/data/user_action.dart';
import 'package:test/user/domain/user_preferences.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final CalendarService _calendarService = CalendarService();
  Map<DateTime, List<UserAction>> _events = {};
  List<UserAction> _selectedEvents = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ValueNotifier<Set<String>> _approvedVacationIds = ValueNotifier({});
  int _workedDays = 0;

  static const Map<String, Color> eventTypeColors = {
    'vacation': Color(0xFF9C27B0),
    'attendance': Color(0xFF009688),
    'sick_leave': Color(0xFF1976D2),
    'business_trip': Color(0xFFFF9800),
    'overtime': Color(0xFFF44336),
    'unpaid_vacation': Color(0xFF9E9E9E),
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchUserActions(),
      _fetchApprovedVacations(),
    ]);
  }

  Future<void> _fetchUserActions() async {
    DateTime firstDayOfCurrentMonth =
        DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime lastDayOfNextMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0)
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));

    Map<DateTime, List<UserAction>> fetchedEvents =
        await _calendarService.fetchUserActionsForCalendar(
            firstDayOfCurrentMonth, lastDayOfNextMonth);

    final countedDays = <DateTime>{};
    for (final list in fetchedEvents.values) {
      for (final action in list) {
        if (action.type != 'attendance') continue;
        final start = DateTime.parse(action.startDate);
        final end = DateTime.parse(action.endDate);
        for (DateTime day = start;
            !day.isAfter(end);
            day = day.add(const Duration(days: 1))) {
          countedDays.add(DateTime(day.year, day.month, day.day));
        }
      }
    }

    setState(() {
      _events = fetchedEvents;
      _workedDays = countedDays.length;
    });
  }

  Future<void> _fetchApprovedVacations() async {
    final token = await UserPreferences.getToken();
    if (token == null) return;

    final notificationService = NotificationService();
    try {
      final response = await notificationService.fetchNotifications(token);
      final approvedIds = response.notifications
          .where((notif) => notif.type == 'vacation_approved')
          .map((notif) => notif.actionId)
          .toSet();

      _approvedVacationIds.value = approvedIds;
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Календарь',
            style: TextStyle(
                fontFamily: 'CeraPro',
                fontSize: 26,
                fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: _approvedVacationIds,
            builder: (context, approvedIds, _) {
              return TableCalendar<UserAction>(
                locale: 'ru_RU',
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _events[day] ?? [],
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEvents = _events[selectedDay] ?? [];
                  });
                  _showDayDetails(context, selectedDay, _selectedEvents);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _fetchUserActions();
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox.shrink();

                    final eventTypes = <String>{};
                    for (var event in events) {
                      eventTypes.add(event.type);
                    }

                    return Positioned(
                      bottom: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: eventTypes.map((type) {
                          final color = eventTypeColors[type] ?? Colors.grey;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.0),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 22, 79, 148),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Отработано дней: $_workedDays',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: eventTypeColors.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: entry.value,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(_getEventTitleByType(entry.key),
                        style: const TextStyle(fontSize: 14)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetails(
      BuildContext context, DateTime day, List<UserAction> events) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            final uniqueEvents = <String, UserAction>{};
            for (final event in events) {
              uniqueEvents[event.id] = event;
            }
            final filteredEvents = uniqueEvents.values.toList();

            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  height: 4,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'ru_RU').format(day),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredEvents.isEmpty
                      ? const Center(
                          child: Text(
                            'Событий нет',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            final color =
                                eventTypeColors[event.type] ?? Colors.grey;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getEventTitle(event),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${formatDate(event.startDate)} - ${formatDate(event.endDate)}',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getEventTitle(UserAction event) {
    const titles = {
      'vacation': 'Отпуск',
      'attendance': 'Посещение',
      'sick_leave': 'Больничный',
      'business_trip': 'Командировка',
      'overtime': 'Сверхурочные',
      'unpaid_vacation': 'Отпуск без оплаты',
    };
    return titles[event.type] ?? 'Событие';
  }

  static String _getEventTitleByType(String type) {
    const titles = {
      'vacation': 'Отпуск',
      'attendance': 'Посещение',
      'sick_leave': 'Больничный',
      'business_trip': 'Командировка',
      'overtime': 'Сверхурочные',
      'unpaid_vacation': 'Отпуск без оплаты',
    };
    return titles[type] ?? 'Событие';
  }

  String formatDate(String dateStr) {
    final dateTime = DateTime.parse(dateStr);
    final formatter = DateFormat('HH:mm', 'ru_RU');
    return formatter.format(dateTime);
  }
}
