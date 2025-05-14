class InventoryItem {
  final String? id;
  final String? name;
  final String? description;

  InventoryItem({this.id, this.name, this.description});

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
