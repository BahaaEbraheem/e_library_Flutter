import 'package:flutter/material.dart';

class User {
  final int? id;
  final String username;
  final String password;
  final String fName;
  final String lName;
  final bool isAdmin;
  final String? token;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.fName,
    required this.lName,
    this.isAdmin = false,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // طباعة البيانات المستلمة للتصحيح
    debugPrint('استخراج بيانات المستخدم من JSON: $json');

    // معالجة حقل isAdmin بطريقة أكثر مرونة
    bool isAdminValue = false;

    if (json.containsKey('isAdmin')) {
      var isAdminField = json['isAdmin'];

      if (isAdminField is bool) {
        isAdminValue = isAdminField;
      } else if (isAdminField is String) {
        isAdminValue = isAdminField.toLowerCase() == 'true';
      } else if (isAdminField is int) {
        isAdminValue = isAdminField == 1;
      }

      debugPrint('قيمة isAdmin المستخرجة: $isAdminValue');
    } else {
      debugPrint('حقل isAdmin غير موجود في البيانات المستلمة');
    }

    // استخراج معرف المستخدم
    int? userId;
    if (json['id'] != null) {
      try {
        userId = int.parse(json['id'].toString());
      } catch (e) {
        debugPrint('خطأ في تحويل معرف المستخدم: $e');
      }
    }

    return User(
      id: userId,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      fName: json['fName'] ?? '',
      lName: json['lName'] ?? '',
      isAdmin: isAdminValue,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fName': fName,
      'lName': lName,
      'isAdmin': isAdmin,
      'token': token,
    };
  }
}
