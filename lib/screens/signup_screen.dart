import 'package:flutter/material.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/screens/login_screen.dart';
import 'package:e_library/widgets/error_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isAdmin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // طباعة بيانات التسجيل للتصحيح
        debugPrint('محاولة تسجيل مستخدم جديد:');
        debugPrint('اسم المستخدم: ${_usernameController.text}');
        debugPrint('الاسم الأول: ${_firstNameController.text}');
        debugPrint('الاسم الأخير: ${_lastNameController.text}');
        debugPrint('هل سيكون مسؤول؟ $_isAdmin');

        final success = await _apiService.registerWithAdminRole(
          _usernameController.text,
          _passwordController.text,
          _firstNameController.text,
          _lastNameController.text,
          _isAdmin,
        );

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        if (success) {
          debugPrint('تم التسجيل بنجاح');

          // استخدام ErrorDialog للنجاح
          ErrorDialog.show(
            context,
            title: 'تم التسجيل بنجاح',
            message:
                'تم إنشاء حسابك بنجاح. يمكنك الآن تسجيل الدخول باستخدام بيانات الاعتماد الخاصة بك.',
            buttonText: 'تسجيل الدخول',
            onPressed: () {
              Navigator.pop(context); // إغلاق مربع الحوار
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          );
        } else {
          debugPrint('فشل التسجيل');

          // استخدام ErrorDialog للفشل
          ErrorDialog.show(
            context,
            title: 'فشل التسجيل',
            message:
                'فشل في إنشاء الحساب. قد يكون اسم المستخدم موجودًا بالفعل. الرجاء المحاولة باستخدام اسم مستخدم مختلف.',
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        debugPrint('خطأ أثناء التسجيل: $e');

        // استخدام ErrorDialog للخطأ
        ErrorDialog.show(
          context,
          title: 'خطأ في الاتصال',
          message:
              'حدث خطأ أثناء الاتصال بالخادم: ${e.toString()}. الرجاء التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل حساب جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الأول',
                  border: OutlineInputBorder(),
                ),
                textDirection: TextDirection.rtl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم الأول';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الأخير',
                  border: OutlineInputBorder(),
                ),
                textDirection: TextDirection.rtl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم الأخير';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(),
                ),
                textDirection: TextDirection.rtl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المستخدم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                textDirection: TextDirection.rtl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال كلمة المرور';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('تسجيل كمسؤول (أدمن)'),
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'تسجيل',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('لديك حساب بالفعل؟ تسجيل الدخول'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
