import 'package:flutter/material.dart';
import 'package:e_library/models/book.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/screens/authors/author_details_screen.dart';
import 'package:e_library/screens/publishers/publisher_details_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  final int bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<Book> _bookFuture;

  @override
  void initState() {
    super.initState();
    _bookFuture = _apiService.getBookById(widget.bookId).then((book) {
      if (book == null) throw Exception('Book not found');
      return book;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الكتاب')),
      body: FutureBuilder<Book>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('لا يمكن العثور على الكتاب'));
          } else {
            final book = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(
                        Icons.book,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('النوع', book.type),
                  _buildInfoRow('السعر', '${book.price} \$'),

                  // Información del autor con botón para ver detalles
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'المؤلف: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${book.authorName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('عرض التفاصيل'),
                          onPressed: () {
                            if (book.authorId != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AuthorDetailsScreen(
                                        authorId: book.authorId,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('معلومات المؤلف غير متوفرة'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Información del editor con botón para ver detalles
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'الناشر: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${book.publisherName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('عرض التفاصيل'),
                          onPressed: () {
                            if (book.publisherId != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PublisherDetailsScreen(
                                        publisherId: book.publisherId,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('معلومات الناشر غير متوفرة'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
