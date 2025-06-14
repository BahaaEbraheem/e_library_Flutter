import 'package:flutter/material.dart';
import 'package:e_library/models/user.dart';
import 'package:e_library/models/author.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/screens/authors/add_author_screen.dart';
import 'package:e_library/screens/authors/author_details_screen.dart';

class AuthorsScreen extends StatefulWidget {
  final User user;

  const AuthorsScreen({super.key, required this.user});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Author>> _authorsFuture;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _authorsFuture = _apiService.getAllAuthors();
    debugPrint('User is admin: ${widget.user.isAdmin}');
  }

  void _refreshAuthors() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _authorsFuture = _apiService.getAllAuthors();
      } else {
        _authorsFuture = _apiService.searchAuthorsByName(_searchQuery);
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _authorsFuture = _apiService.searchAuthorsByName(query);
      } else {
        _authorsFuture = _apiService.getAllAuthors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'بحث عن مؤلف...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: _performSearch,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                )
                : const Text('المؤلفون'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _authorsFuture = _apiService.getAllAuthors();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Author>>(
        future: _authorsFuture,
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
                  const Icon(
                    Icons.person_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? 'لا توجد نتائج للبحث' : 'لا يوجد مؤلفون',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final author = snapshot.data![index];
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
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.person, color: Colors.green),
                    ),
                    title: Text(
                      '${author.firstName} ${author.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('البلد: ${author.country}'),
                        Text('المدينة: ${author.city}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AuthorDetailsScreen(authorId: author.id!),
                        ),
                      ).then((_) => _refreshAuthors());
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddAuthorScreen(user: widget.user),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _refreshAuthors();
                    }
                  });
                },
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 8,
                icon: const Icon(Icons.add, size: 30),
                label: const Text(
                  'إضافة مؤلف',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
              : null,
    );
  }
}
