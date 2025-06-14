import 'package:flutter/material.dart';
import 'package:e_library/models/publisher.dart';
import 'package:e_library/services/api_service.dart';

class PublisherDetailsScreen extends StatefulWidget {
  final int publisherId;

  const PublisherDetailsScreen({super.key, required this.publisherId});

  @override
  State<PublisherDetailsScreen> createState() => _PublisherDetailsScreenState();
}

class _PublisherDetailsScreenState extends State<PublisherDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<Publisher?> _publisherFuture;

  @override
  void initState() {
    super.initState();
    _publisherFuture = _apiService.getPublisherById(widget.publisherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الناشر')),
      body: FutureBuilder<Publisher?>(
        future: _publisherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('لا يمكن العثور على الناشر'));
          } else {
            final publisher = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(
                        Icons.business,
                        size: 50,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    publisher.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('المدينة', publisher.city),
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
