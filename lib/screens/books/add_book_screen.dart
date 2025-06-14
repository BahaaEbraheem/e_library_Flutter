import 'package:flutter/material.dart';
import 'package:e_library/models/user.dart';
import 'package:e_library/models/author.dart';
import 'package:e_library/models/publisher.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/utils/string_utils.dart';

class AddBookScreen extends StatefulWidget {
  final User user;

  const AddBookScreen({super.key, required this.user});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  List<Author> _authors = [];
  List<Publisher> _publishers = [];
  Author? _selectedAuthor;
  Publisher? _selectedPublisher;

  @override
  void initState() {
    super.initState();
    _loadAuthorsAndPublishers();
  }

  Future<void> _loadAuthorsAndPublishers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authors = await _apiService.getAllAuthors();
      final publishers = await _apiService.getAllPublishers();

      setState(() {
        _authors = authors;
        _publishers = publishers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAuthor == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار مؤلف')));
        return;
      }

      if (_selectedPublisher == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار ناشر')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Mostrar mensaje de carga
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('جاري إرسال البيانات...')),
          );
        }

        // استخدام الدالة المساعدة لتحويل الأرقام العربية
        final price = StringUtils.parseDouble(_priceController.text);

        final result = await _apiService.addBook(
          title: _titleController.text,
          type: _typeController.text,
          price: price,
          authorId: _selectedAuthor!.id!,
          pubId: _selectedPublisher!.id!,
          user: widget.user, // Pasar el usuario actual
        );

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الكتاب بنجاح')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إضافة الكتاب. تأكد من تسجيل الدخول كمسؤول'),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة كتاب جديد')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان الكتاب',
                          border: OutlineInputBorder(),
                        ),
                        textDirection: TextDirection.rtl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال عنوان الكتاب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          labelText: 'نوع الكتاب',
                          border: OutlineInputBorder(),
                        ),
                        textDirection: TextDirection.rtl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال نوع الكتاب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'السعر',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال السعر';
                          }
                          try {
                            // استخدام الدالة المساعدة للتحقق من صحة الإدخال
                            StringUtils.parseDouble(value);
                          } catch (e) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'اختر المؤلف:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Author>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        hint: const Text('اختر المؤلف'),
                        value: _selectedAuthor,
                        items:
                            _authors.map((author) {
                              return DropdownMenuItem<Author>(
                                value: author,
                                child: Text(
                                  '${author.firstName} ${author.lastName}',
                                ),
                              );
                            }).toList(),
                        onChanged: (Author? value) {
                          setState(() {
                            _selectedAuthor = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'اختر الناشر:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Publisher>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        hint: const Text('اختر الناشر'),
                        value: _selectedPublisher,
                        items:
                            _publishers.map((publisher) {
                              return DropdownMenuItem<Publisher>(
                                value: publisher,
                                child: Text(publisher.name),
                              );
                            }).toList(),
                        onChanged: (Publisher? value) {
                          setState(() {
                            _selectedPublisher = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'حفظ الكتاب',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
