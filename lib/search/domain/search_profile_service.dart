import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';

class SearchProfileService {
  Future<User?> fetchUserById(String userId) async {
    try {
      return await UserPreferences.fetchUserInfoById(userId);
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<bool> addInventoryItem(
      String name, String description, String employeeId) async {
    final url = Uri.parse('https://working-day.su:8080/v1/inventory/add');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await UserPreferences.getToken()}',
    };
    final body = jsonEncode({
      'item': {
        'name': name,
        'description': description,
      },
      'employee_id': employeeId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка при добавлении инвентаря: $e');
      return false;
    }
  }
}
