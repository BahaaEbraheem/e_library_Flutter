class Book {
  final int? id;
  final String title;
  final String type;
  final double price;
  final int authorId;
  final int publisherId; // تغيير من publisherId إلى publisherId
  final String? authorName;
  final String? publisherName;

  Book({
    this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.authorId,
    required this.publisherId,
    this.authorName,
    this.publisherName,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : (json['price'] ?? 0.0),
      authorId: json['authorId'] ?? 0,
      publisherId: json['publisherId'] ?? 0, // تغيير من pubId إلى publisherId
      authorName: json['authorName'],
      publisherName: json['publisherName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'price': price,
      'authorId': authorId,
      'publisherId': publisherId, // تغيير من pubId إلى publisherId
    };
  }
}
