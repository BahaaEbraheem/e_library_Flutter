import 'package:flutter/material.dart';
import 'package:e_library/models/user.dart';
import 'package:e_library/models/book.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/screens/books/add_book_screen.dart';
import 'package:e_library/screens/books/book_details_screen.dart';

class BooksScreen extends StatefulWidget {
  final User user;

  const BooksScreen({super.key, required this.user});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Book>> _booksFuture;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _booksFuture = _apiService.getAllBooks();
    // طباعة معلومات المستخدم للتصحيح
    debugPrint('معلومات المستخدم في شاشة الكتب:');
    debugPrint('اسم المستخدم: ${widget.user.username}');
    debugPrint('هل هو مسؤول؟ ${widget.user.isAdmin}');
  }

  void _refreshBooks() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _booksFuture = _apiService.getAllBooks();
      } else {
        _booksFuture = _apiService.searchBooksByTitle(_searchQuery);
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _booksFuture = _apiService.searchBooksByTitle(query);
      } else {
        _booksFuture = _apiService.getAllBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // طباعة معلومات المستخدم للتأكد من صلاحيات المسؤول
    debugPrint('معلومات المستخدم في شاشة الكتب:');
    debugPrint('اسم المستخدم: ${widget.user.username}');
    debugPrint('هل هو مسؤول؟ ${widget.user.isAdmin}');

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'بحث عن كتاب...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: _performSearch,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                )
                : const Text('الكتب'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _booksFuture = _apiService.getAllBooks();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? 'لا توجد نتائج للبحث' : 'لا توجد كتب متاحة',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final book = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.book, color: Colors.blue),
                    ),
                    title: Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('النوع: ${book.type}'),
                        Text('السعر: ${book.price} \$'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookDetailsScreen(bookId: book.id!),
                        ),
                      ).then((_) => _refreshBooks());
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton:
          widget.user.isAdmin
              ? FloatingActionButton.extended(
                onPressed: () {
                  debugPrint('تم النقر على زر إضافة كتاب');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddBookScreen(user: widget.user),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _refreshBooks();
                    }
                  });
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 8,
                icon: const Icon(Icons.add, size: 30),
                label: const Text(
                  'إضافة كتاب',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
              : null,
    );
  }
}
