import 'package:flutter/material.dart';
import 'package:e_library/models/user.dart';
import 'package:e_library/models/publisher.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/screens/publishers/add_publisher_screen.dart';
import 'package:e_library/screens/publishers/publisher_details_screen.dart';

class PublishersScreen extends StatefulWidget {
  final User user;

  const PublishersScreen({super.key, required this.user});

  @override
  State<PublishersScreen> createState() => _PublishersScreenState();
}

class _PublishersScreenState extends State<PublishersScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Publisher>> _publishersFuture;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _publishersFuture = _apiService.getAllPublishers();
    debugPrint('User is admin in publishers screen: ${widget.user.isAdmin}');
  }

  void _refreshPublishers() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _publishersFuture = _apiService.getAllPublishers();
      } else {
        _publishersFuture = _apiService.searchPublishersByName(_searchQuery);
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _publishersFuture = _apiService.searchPublishersByName(query);
      } else {
        _publishersFuture = _apiService.getAllPublishers();
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
                    hintText: 'بحث عن ناشر...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: _performSearch,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                )
                : const Text('الناشرون'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _publishersFuture = _apiService.getAllPublishers();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Publisher>>(
        future: _publishersFuture,
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
                    Icons.business_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? 'لا توجد نتائج للبحث' : 'لا يوجد ناشرون',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final publisher = snapshot.data![index];
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
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(Icons.business, color: Colors.orange),
                    ),
                    title: Text(
                      publisher.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('المدينة: ${publisher.city}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PublisherDetailsScreen(
                                publisherId: publisher.id!,
                              ),
                        ),
                      ).then((_) => _refreshPublishers());
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
                      builder:
                          (context) => AddPublisherScreen(user: widget.user),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _refreshPublishers();
                    }
                  });
                },
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 8,
                icon: const Icon(Icons.add, size: 30),
                label: const Text(
                  'إضافة ناشر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
