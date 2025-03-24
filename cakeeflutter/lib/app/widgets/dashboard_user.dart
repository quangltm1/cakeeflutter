import 'package:cakeeflutter/app/screen/user/donhang_user.dart';
import 'package:cakeeflutter/app/screen/user/giohang_user.dart';
import 'package:cakeeflutter/app/screen/user/trangchu_user.dart';
import 'package:flutter/material.dart';
import '../screen/user/caidat_user.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  UserHomeScreenState createState() => UserHomeScreenState();
}

class UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  static final List<Widget> _widgetOptions = <Widget>[
    TrangChuUserPage(),
    DonHangPage(),
    CartPage(),
    CaiDatUserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang Chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Đơn Hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Giỏ Hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Tôi',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFFFD900),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFFFBFBFB),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}