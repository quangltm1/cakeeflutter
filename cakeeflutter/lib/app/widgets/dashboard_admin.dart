import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/screen/admin/caidat_admin.dart';
import 'package:cakeeflutter/app/screen/admin/donhang_admin.dart';
import 'package:cakeeflutter/app/screen/admin/doanhthu_admin.dart';
import 'package:cakeeflutter/app/screen/admin/trangchu_admin.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  AdminHomeScreenState createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    TrangChuAdmin(),
    DonHangAdmin(),
    DoanhthuAdmin(),
    CaiDatAdminScreen(),
  ];

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFFD900),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.grey[200],
          notchMargin: 4.0,
          child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildNavItem(Icons.home, 0, 'Trang Chủ'),
            _buildNavItem(Icons.shopping_cart, 1, 'Đơn Hàng'),
            const SizedBox(width: 40), // Chừa khoảng trống cho FAB
            _buildNavItem(Icons.account_balance_wallet, 2, 'Doanh Thu'),  
            _buildNavItem(Icons.settings, 3, 'Tôi'),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _onItemTapped(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFFD900).withAlpha((0.2 * 255).toInt())
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFFFFD900) : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
