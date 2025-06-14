import 'package:flutter/material.dart';
import 'package:e_library/models/author.dart';
import 'package:e_library/services/api_service.dart';

class AuthorDetailsScreen extends StatefulWidget {
  final int authorId;

  const AuthorDetailsScreen({super.key, required this.authorId});

  @override
  State<AuthorDetailsScreen> createState() => _AuthorDetailsScreenState();
}

class _AuthorDetailsScreenState extends State<AuthorDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<Author?> _authorFuture;

  @override
  void initState() {
    super.initState();
    _authorFuture = _apiService.getAuthorById(widget.authorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المؤلف')),
      body: FutureBuilder<Author?>(
        future: _authorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('لا يمكن العثور على المؤلف'));
          } else {
            final author = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${author.firstName} ${author.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('البلد', author.country),
                  _buildInfoRow('المدينة', author.city),
                  _buildInfoRow('العنوان', author.address),
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