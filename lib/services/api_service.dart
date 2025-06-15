import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:e_library/models/user.dart';
import 'package:e_library/models/book.dart';
import 'package:e_library/models/author.dart';
import 'package:e_library/models/publisher.dart';

// دالة لفك تشفير رمز JWT
Map<String, dynamic> _decodeJwtToken(String token) {
  try {
    // تقسيم الرمز إلى أجزاء
    final parts = token.split('.');
    if (parts.length != 3) {
      debugPrint('رمز JWT غير صالح: عدد الأجزاء غير صحيح');
      return {};
    }

    // فك تشفير الجزء الثاني (البيانات)
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> data = json.decode(decoded);

    debugPrint('تم فك تشفير رمز JWT: $data');
    return data;
  } catch (e) {
    debugPrint('خطأ في فك تشفير رمز JWT: $e');
    return {};
  }
}

// Método para verificar la conectividad general
Future<bool> _checkConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

class ApiService {
  // final String baseUrl = 'http://your-url-here/api';
  final String baseUrl = 'http://elibrary2025.somee.com/api';
  String? _authToken; // لتخزين رمز المصادقة

  // دالة لتعيين رمز المصادقة بعد تسجيل الدخول
  void setAuthToken(String token) {
    _authToken = token;
    debugPrint('تم تخزين رمز المصادقة');
  }

  // دالة للحصول على ترويسات المصادقة
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Añadir método para verificar la conexión
  Future<bool> checkConnection() async {
    try {
      debugPrint('Verificando conexión al servidor: $baseUrl');
      final response = await http
          .get(Uri.parse('$baseUrl/books'))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => http.Response('Timeout', 408),
          );

      debugPrint(
        'Respuesta de verificación: ${response.statusCode}, ${response.body.substring(0, min(100, response.body.length))}',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error de conexión: $e');
      return false;
    }
  }

  // User Authentication
  Future<User?> login(String username, String password) async {
    try {
      // Verificar la conectividad antes de intentar iniciar sesión
      final isConnected = await _checkConnectivity();
      if (!isConnected) {
        throw Exception(
          'لا يوجد اتصال بالإنترنت. الرجاء التحقق من اتصالك والمحاولة مرة أخرى.',
        );
      }

      debugPrint('محاولة تسجيل الدخول: $username');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'انتهت مهلة الاتصال بالخادم. الرجاء المحاولة مرة أخرى لاحقًا.',
              );
            },
          );

      debugPrint('استجابة تسجيل الدخول: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint('بيانات الاستجابة: $responseData');

        // التحقق من وجود الرمز
        if (responseData.containsKey('token')) {
          final String token = responseData['token'];
          debugPrint('تم استلام رمز المصادقة');

          // تخزين الرمز للاستخدام في الطلبات المستقبلية
          setAuthToken(token);

          // فك تشفير الرمز للحصول على معلومات المستخدم
          final Map<String, dynamic> tokenData = _decodeJwtToken(token);

          // إنشاء بيانات المستخدم من الرمز
          final Map<String, dynamic> userData = {
            'id': tokenData['nameid'],
            'username': tokenData['unique_name'],
            'fName': tokenData['unique_name'], // استخدام اسم المستخدم كبديل
            'lName': '', // فارغ لأنه غير متوفر في الرمز
            'isAdmin': tokenData['role']?.toString().toLowerCase() == 'admin',
            'token': token,
          };

          debugPrint('بيانات المستخدم المستخرجة من الرمز: $userData');
          debugPrint('هل المستخدم مسؤول؟ ${userData['isAdmin']}');

          return User.fromJson(userData);
        } else {
          debugPrint('لم يتم العثور على رمز المصادقة في الاستجابة');
        }
      } else if (response.statusCode == 401) {
        debugPrint('فشل تسجيل الدخول: بيانات الاعتماد غير صالحة');
        return null;
      } else if (response.statusCode == 404) {
        debugPrint('فشل تسجيل الدخول: المستخدم غير موجود');
        return null;
      } else {
        debugPrint('فشل تسجيل الدخول: رمز الحالة ${response.statusCode}');
        throw Exception(
          'فشل في الاتصال بالخادم. الرجاء المحاولة مرة أخرى لاحقًا.',
        );
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: $e');
      rethrow; // إعادة رمي الاستثناء ليتم التقاطه في الشاشة
    }
  }

  // تسجيل مستخدم جديد مع دور المسؤول
  Future<bool> registerWithAdminRole(
    String username,
    String password,
    String firstName,
    String lastName,
    bool isAdmin, // معلمة جديدة
  ) async {
    try {
      // Verificar la conectividad antes de intentar registrarse
      final isConnected = await _checkConnectivity();
      if (!isConnected) {
        throw Exception(
          'لا يوجد اتصال بالإنترنت. الرجاء التحقق من اتصالك والمحاولة مرة أخرى.',
        );
      }

      debugPrint('محاولة تسجيل مستخدم: $username (مسؤول: $isAdmin)');

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'fName': firstName,
              'lName': lastName,
              'isAdmin': isAdmin,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'انتهت مهلة الاتصال بالخادم. الرجاء المحاولة مرة أخرى لاحقًا.',
              );
            },
          );

      debugPrint('رمز الحالة: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        debugPrint('خطأ في التسجيل: ${response.body}');
        // يمكن تحليل الرد لمعرفة سبب الخطأ بالتحديد
        if (response.body.contains('username')) {
          throw Exception(
            'اسم المستخدم موجود بالفعل. الرجاء اختيار اسم مستخدم آخر.',
          );
        }
        return false;
      } else {
        debugPrint('خطأ في التسجيل: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('خطأ في التسجيل: $e');
      rethrow; // إعادة رمي الاستثناء ليتم التقاطه في الشاشة
    }
  }

  Future<bool> register(
    String username,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      debugPrint('Intentando registrar usuario: $username');

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'fName': firstName,
              'lName': lastName,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('Tiempo de espera agotado para el registro');
              return http.Response('Timeout', 408);
            },
          );

      debugPrint('Código de estado: ${response.statusCode}');

      if (response.statusCode != 201) {
        debugPrint('Error en el registro: ${response.body}');
      }

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error de registro: $e');
      return false;
    }
  }

  // Books
  Future<List<Book>> getAllBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    }
    return [];
  }

  Future<Book?> getBookById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$id'));

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<Book>> searchBooksByTitle(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/search?title=$query'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> addBook({
    required String title,
    required String type,
    required double price,
    required int authorId,
    required int pubId,
    User? user, // Añadir parámetro de usuario
  }) async {
    try {
      final Map<String, dynamic> bookData = {
        'title': title,
        'type': type,
        'price': price,
        'authorId': authorId,
        'publisherId': pubId,
      };

      debugPrint('Agregando libro con datos: ${jsonEncode(bookData)}');

      // Preparar los encabezados con el token de autenticación
      final headers = {'Content-Type': 'application/json'};

      // Añadir el token si el usuario está disponible y tiene token
      if (user != null && user.token != null) {
        headers['Authorization'] = 'Bearer ${user.token}';
        debugPrint('Usando token de autenticación: ${user.token}');
      } else {
        debugPrint('No hay token de autenticación disponible');
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/books'),
            headers: headers,
            body: jsonEncode(bookData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('La solicitud POST expiró');
              return http.Response('Timeout', 408);
            },
          );

      debugPrint('Código de estado: ${response.statusCode}');
      debugPrint('Cuerpo de respuesta: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error al agregar libro: $e');
      return false;
    }
  }

  // Authors
  Future<List<Author>> getAllAuthors() async {
    final response = await http.get(Uri.parse('$baseUrl/authors'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Author.fromJson(json)).toList();
    }
    return [];
  }

  Future<Author?> getAuthorById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/authors/$id'));

    if (response.statusCode == 200) {
      return Author.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<Author>> searchAuthorsByName(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/authors/search?name=$query'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Author.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> addAuthor({
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String address,
    User? user, // Añadir parámetro de usuario
  }) async {
    try {
      final Map<String, dynamic> authorData = {
        'fName': firstName,
        'lName': lastName,
        'country': country,
        'city': city,
        'address': address,
      };

      debugPrint('Agregando autor con datos: ${jsonEncode(authorData)}');

      // Preparar los encabezados con el token de autenticación
      final headers = {'Content-Type': 'application/json'};

      // Añadir el token si el usuario está disponible y tiene token
      if (user != null && user.token != null) {
        headers['Authorization'] = 'Bearer ${user.token}';
        debugPrint('Usando token de autenticación: ${user.token}');
      } else {
        debugPrint('No hay token de autenticación disponible');
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/authors'),
            headers: headers,
            body: jsonEncode(authorData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('La solicitud POST expiró');
              return http.Response('Timeout', 408);
            },
          );

      debugPrint('Código de estado: ${response.statusCode}');
      debugPrint('Cuerpo de respuesta: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error al agregar autor: $e');
      return false;
    }
  }

  // Publishers
  Future<List<Publisher>> getAllPublishers() async {
    final response = await http.get(Uri.parse('$baseUrl/publishers'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Publisher.fromJson(json)).toList();
    }
    return [];
  }

  Future<Publisher?> getPublisherById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/publishers/$id'));

    if (response.statusCode == 200) {
      return Publisher.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<Publisher>> searchPublishersByName(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/publishers/search?name=$query'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Publisher.fromJson(json)).toList();
    }
    return [];
  }

  // Método para agregar editor con autenticación
  Future<bool> addPublisher({
    required String name,
    required String city,
    User? user, // Añadir parámetro de usuario opcional
  }) async {
    try {
      final Map<String, dynamic> publisherData = {'pName': name, 'city': city};

      debugPrint('Agregando editor con datos: ${jsonEncode(publisherData)}');

      // Preparar los encabezados con el token de autenticación si está disponible
      final headers = {'Content-Type': 'application/json'};

      // Añadir el token si el usuario está disponible y tiene token
      if (user != null && user.token != null) {
        headers['Authorization'] = 'Bearer ${user.token}';
        debugPrint('Usando token de autenticación');
      } else {
        debugPrint('No hay token de autenticación disponible');
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/publishers'),
            headers: headers,
            body: jsonEncode(publisherData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('La solicitud POST expiró');
              return http.Response('Timeout', 408);
            },
          );

      debugPrint('Código de estado: ${response.statusCode}');
      debugPrint('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 401) {
        debugPrint('Error de autenticación: Se requiere iniciar sesión');
        return false;
      }

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error al agregar editor: $e');
      return false;
    }
  }
}
