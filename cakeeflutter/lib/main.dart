import 'package:cakeeflutter/app/screen/admin/acessory/quanlyacessory.dart';
import 'package:cakeeflutter/app/screen/admin/cakesize/quanlycakesize.dart';
import 'package:cakeeflutter/app/screen/admin/category/category_details.dart';
import 'package:cakeeflutter/app/screen/admin/category/quanlycategory.dart';
import 'package:cakeeflutter/app/screen/admin/donhang_admin.dart';
import 'package:cakeeflutter/app/screen/admin/cake/quanlycake.dart';
import 'package:cakeeflutter/app/screen/admin/thuchi_admin.dart';
import 'package:cakeeflutter/app/screen/login.dart';
import 'package:cakeeflutter/app/screen/welcom_screen.dart';
import 'package:flutter/material.dart';
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cakee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver],
      home: WelcomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(), // Define the login screen route
        '/phu-kien': (context) => QuanLyAcessory(), // Define the donhang screen route
        '/cake': (context) => QuanLyCake(), // Define the thuchi screen route
        '/danh-muc': (context) => QuanLyCategory(), // Define the quanlycake screen route
        '/size-banh': (context) => QuanLyCakeSize(), // Define the quanlycategory screen route
      },
    );
  }
}