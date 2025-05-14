class HeadInfo {
  final String id;
  final String name;
  final String surname;

  HeadInfo({required this.id, required this.name, required this.surname});

  factory HeadInfo.fromJson(Map<String, dynamic> json) {
    return HeadInfo(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
    );
  }
}
