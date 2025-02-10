// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    TrangChuPage(),
    DonHangPage(),
    ThuChiPage(),
    CaiDatPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Trang Chu',
          ),
          BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Don Hang',
          ),
          BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet),
        label: 'Thu Chi',
          ),
          BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Cai Dat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 87, 221, 91),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TrangChuPage extends StatefulWidget {
  @override
  _TrangChuPageState createState() => _TrangChuPageState();
}

class _TrangChuPageState extends State<TrangChuPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Trang Chu Page'),
    );
  }
}

class DonHangPage extends StatefulWidget {
  @override
  _DonHangPageState createState() => _DonHangPageState();
}

class _DonHangPageState extends State<DonHangPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Don Hang Page'),
    );
  }
}

class ThuChiPage extends StatefulWidget {
  @override
  _ThuChiPageState createState() => _ThuChiPageState();
}

class _ThuChiPageState extends State<ThuChiPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Thu Chi Page'),
    );
  }
}

class CaiDatPage extends StatefulWidget {
  @override
  _CaiDatPageState createState() => _CaiDatPageState();
}

class _CaiDatPageState extends State<CaiDatPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Cai Dat Page'),
    );
  }
}