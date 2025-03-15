import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cakeeflutter/app/providers/cart_provider.dart';
import 'package:cakeeflutter/app/screen/admin/acessory/quanlyacessory.dart';
import 'package:cakeeflutter/app/screen/admin/cakesize/quanlycakesize.dart';
import 'package:cakeeflutter/app/screen/admin/category/quanlycategory.dart';
import 'package:cakeeflutter/app/screen/admin/cake/quanlycake.dart';
import 'package:cakeeflutter/app/screen/login.dart';
import 'package:cakeeflutter/app/screen/welcom_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()), // ✅ Đăng ký CartProvider
      ],
      child: const MyApp(),
    ),
  );
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
        '/login': (context) => LoginScreen(),
        '/phu-kien': (context) => QuanLyAcessory(),
        '/cake': (context) => QuanLyCake(),
        '/danh-muc': (context) => QuanLyCategory(),
        '/size-banh': (context) => QuanLyCakeSize(),
      },
    );
  }
}
