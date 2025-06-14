class Publisher {
  final int? id;
  final String name;
  final String city;

  Publisher({this.id, required this.name, required this.city});

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: json['id'],
      name: json['pName'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'pName': name, 'city': city};
  }
}
