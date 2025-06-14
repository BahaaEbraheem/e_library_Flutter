class Author {
  final int? id;
  final String firstName;
  final String lastName;
  final String country;
  final String city;
  final String address;

  Author({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.city,
    required this.address,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      firstName: json['fName'] ?? '',
      lastName: json['lName'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fName': firstName,
      'lName': lastName,
      'country': country,
      'city': city,
      'address': address,
    };
  }
}
