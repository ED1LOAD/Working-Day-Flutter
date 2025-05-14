import 'package:test/user/data/user_head_info.dart';
import 'package:test/user/data/user_inventory.dart';

class User {
  final String? id;
  final String? name;
  final String? surname;
  final String? patronymic;
  final List<String>? phones;
  final String? email;
  final String? birthday;
  final String? photo_link;
  final String? password;
  final String? headId;
  final String? telegram_id;
  final String? vk_id;
  final String? team;
  final String? jobPosition;
  final List<InventoryItem>? inventory;
  final String? head_id;
  final HeadInfo? headInfo;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.patronymic,
    required this.phones,
    required this.email,
    required this.birthday,
    required this.photo_link,
    required this.password,
    required this.headId,
    required this.telegram_id,
    required this.vk_id,
    required this.team,
    required this.jobPosition,
    required this.inventory,
    required this.head_id,
    required this.headInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var phonesFromJson = json['phones'];
    List<String> phoneList = phonesFromJson != null
        ? List<String>.from(phonesFromJson.map((p) => p.toString()))
        : [];

    var inventoryJson = json['inventory'] as List<dynamic>?;
    List<InventoryItem> inventoryList = inventoryJson != null
        ? inventoryJson.map((e) => InventoryItem.fromJson(e)).toList()
        : [];

    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      patronymic: json['patronymic'],
      phones: phoneList,
      email: json['email'],
      birthday: json['birthday'],
      photo_link: json['photo_link'],
      password: json['password'],
      headId: json['headId'],
      telegram_id: json['telegram_id'],
      vk_id: json['vk_id'],
      team: json['team'],
      jobPosition: json['job_position'],
      inventory: inventoryList,
      head_id: json['head_id'],
      headInfo: json['head_info'] != null
          ? HeadInfo.fromJson(json['head_info'])
          : null,
    );
  }
}
