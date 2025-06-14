import 'package:flutter/material.dart';
import 'package:e_library/models/user.dart';
import 'package:e_library/screens/books/books_screen.dart';
import 'package:e_library/screens/authors/authors_screen.dart';
import 'package:e_library/screens/publishers/publishers_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // طباعة معلومات المستخدم للتصحيح
    debugPrint('معلومات المستخدم في الشاشة الرئيسية:');
    debugPrint('اسم المستخدم: ${widget.user.username}');
    debugPrint('الاسم الكامل: ${widget.user.fName} ${widget.user.lName}');
    debugPrint('هل هو مسؤول؟ ${widget.user.isAdmin}');
    debugPrint('هل لديه رمز مصادقة؟ ${widget.user.token != null}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكتبة الإلكترونية'),
        actions: [
          // إضافة مؤشر لحالة المسؤول
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: widget.user.isAdmin ? Colors.red : Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.user.isAdmin ? 'مسؤول' : 'مستخدم',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً، ${widget.user.username}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              widget.user.isAdmin ? 'حساب مدير (مسؤول)' : 'حساب مستخدم عادي',
              style: TextStyle(
                fontSize: 16,
                color: widget.user.isAdmin ? Colors.red : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMainButton(
                      context,
                      'الكتب',
                      Icons.book,
                      Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BooksScreen(user: widget.user),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildMainButton(
                      context,
                      'المؤلفون',
                      Icons.person,
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AuthorsScreen(user: widget.user),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildMainButton(
                      context,
                      'الناشرون',
                      Icons.business,
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PublishersScreen(user: widget.user),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
