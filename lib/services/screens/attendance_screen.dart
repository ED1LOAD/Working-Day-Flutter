import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:test/services/data/attendance.dart';
import 'package:test/services/domain/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

class AttendanceScreenState extends State<AttendanceScreen> {
  final List<AttendanceRecord> _attendances = [];
  bool _isLoading = false;
  DateTime? _selectedDate;

  final Map<String, TextEditingController> _hoursWorkedControllers = {};
  final Map<String, bool> _absenceStatus = {};
  final Map<String, TextEditingController> _startTimeControllers = {};
  final Map<String, TextEditingController> _endTimeControllers = {};
  final Map<String, bool> _isTimeRangeMode = {};
  final Map<String, bool> _isSaveButtonEnabled = {};

  @override
  void dispose() {
    _hoursWorkedControllers.forEach((_, controller) => controller.dispose());
    _startTimeControllers.forEach((_, controller) => controller.dispose());
    _endTimeControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveAttendance(String employeeId) async {
    final startTimeText = _startTimeControllers[employeeId]?.text ?? '';
    final endTimeText = _endTimeControllers[employeeId]?.text ?? '';
    int hoursWorked = 0;

    if (_isTimeRangeMode[employeeId] == true &&
        startTimeText.isNotEmpty &&
        endTimeText.isNotEmpty) {
      try {
        final start = DateFormat('HH:mm').parse(startTimeText);
        final end = DateFormat('HH:mm').parse(endTimeText);
        hoursWorked = end.difference(start).inHours;
      } catch (e) {
        _showErrorDialog('Ошибка в формате времени');
        return;
      }
    } else {
      final hoursWorkedText = _hoursWorkedControllers[employeeId]?.text ?? '';
      hoursWorked = int.tryParse(hoursWorkedText) ?? 0;
    }

    if (_absenceStatus[employeeId] == true) {
      _showErrorDialog('Сотрудник отсутствовал, сохранение не требуется.');
      return;
    }

    try {
      DateTime startDate = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 9);
      DateTime endDate = startDate.add(Duration(hours: hoursWorked));

      String formattedStart =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate);
      String formattedEnd = DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate);
      await AttendanceService.addAttendance(
          employeeId, formattedStart, formattedEnd);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные успешно сохранены!'),
          backgroundColor: Color.fromARGB(255, 22, 79, 148),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      setState(() {
        _isSaveButtonEnabled[employeeId] = false;
      });
    } catch (e) {
      _showErrorDialog('Ошибка добавления посещения: $e');
    }
  }

  void _toggleAbsence(String employeeId) {
    setState(() {
      _absenceStatus[employeeId] = !(_absenceStatus[employeeId] ?? false);
      _isSaveButtonEnabled[employeeId] =
          !_absenceStatus[employeeId]!; // Блокировка кнопки при отсутствии
    });
  }

  void _toggleTimeMode(String employeeId) {
    setState(() {
      _isTimeRangeMode[employeeId] = !_isTimeRangeMode[employeeId]!;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    if (_selectedDate == null) {
      _showErrorDialog('Дата не выбрана.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String start = DateFormat('yyyy-MM-ddT00:00:00').format(_selectedDate!);
      String end = DateFormat('yyyy-MM-ddT23:59:59').format(_selectedDate!);

      List<AttendanceRecord> attendances =
          await AttendanceService.fetchAllAttendances(start, end);

      setState(() {
        _attendances.clear();
        _attendances.addAll(attendances);
        for (var attendance in _attendances) {
          int hoursWorked = 0;
          if (attendance.startDate != null && attendance.endDate != null) {
            Duration difference =
                attendance.endDate!.difference(attendance.startDate!);
            hoursWorked = difference.inHours;
          }
          _hoursWorkedControllers[attendance.employeeId] =
              TextEditingController(text: hoursWorked.toString());
          _startTimeControllers[attendance.employeeId] =
              TextEditingController();
          _endTimeControllers[attendance.employeeId] = TextEditingController();
          _isTimeRangeMode[attendance.employeeId] = false;
          _absenceStatus[attendance.employeeId] = false;
          _isSaveButtonEnabled[attendance.employeeId] = true;
        }
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Табель',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () => _selectDate(context),
                      child: Text(
                        'Дата: ${_selectedDate?.day.toString().padLeft(2, '0')}-${_selectedDate?.month.toString().padLeft(2, '0')}-${_selectedDate?.year}',
                        style: const TextStyle(
                          fontFamily: 'CeraPro',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 22, 79, 148),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _loadAttendances,
                  child: const Text(
                    'Загрузить табель',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _attendances.length,
                      itemBuilder: (context, index) {
                        var attendance = _attendances[index];
                        var employeeId = attendance.employeeId;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: _absenceStatus[employeeId] == true
                                  ? Colors.red
                                  : const Color.fromARGB(255, 22, 79, 148),
                              width: 1.0,
                            ),
                          ),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${attendance.surname} ${attendance.name} ${attendance.patronymic ?? ""}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Color.fromARGB(255, 22, 79, 148),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Отработано часов:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _isTimeRangeMode[employeeId]!
                                          ? Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _startTimeControllers[
                                                            employeeId],
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Часы',
                                                      hintText: '09:00',
                                                      labelStyle: TextStyle(
                                                          fontFamily:
                                                              'CeraPro'),
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text('до'),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _endTimeControllers[
                                                            employeeId],
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Часы',
                                                      hintText: '17:00',
                                                      labelStyle: TextStyle(
                                                          fontFamily:
                                                              'CeraPro'),
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : TextField(
                                              controller:
                                                  _hoursWorkedControllers[
                                                      employeeId],
                                              decoration: const InputDecoration(
                                                labelText: 'Часы',
                                                hintText: '0',
                                                labelStyle: TextStyle(
                                                    fontFamily: 'CeraPro'),
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: !_absenceStatus[employeeId]!
                                            ? () => _toggleAbsence(employeeId)
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        child: const Text('Отсутствие'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            _isSaveButtonEnabled[employeeId]!
                                                ? () =>
                                                    _saveAttendance(employeeId)
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 22, 79, 148),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        child: const Text('Сохранить'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 22, 79, 148),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 22, 79, 148),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendances();
    }
  }
}
