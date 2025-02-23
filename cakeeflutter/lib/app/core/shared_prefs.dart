import 'dart:convert';
import 'package:cakeeflutter/app/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';

Future<bool> saveUser(User objUser) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String strUser = jsonEncode(objUser);
    prefs.setString('user', strUser);
    prefs.setString('userId', objUser.id.toString()); // ⚡ Lưu userId riêng
    return true;
  } catch (e) {
    return false;
  }
}


Future<bool> logOut(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
    return true;
  } catch (e) {
    return false;
  }
}

Future<User?> getUser() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String? strUser = pref.getString('user');
  if (strUser == null || strUser.isEmpty) {
    return null;
  }
  return User.fromJson(jsonDecode(strUser));
}
