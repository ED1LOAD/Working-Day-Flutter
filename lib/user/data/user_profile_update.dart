class UserProfileUpdate {
  String email;
  String password;
  String birthday;
  // ignore: non_constant_identifier_names
  String telegram_id;
  // ignore: non_constant_identifier_names
  String vk_id;
  String jobPosition;

  UserProfileUpdate({
    required this.email,
    required this.password,
    required this.birthday,
    // ignore: non_constant_identifier_names
    required this.telegram_id,
    // ignore: non_constant_identifier_names
    required this.vk_id,
    required this.jobPosition,
  });
}
