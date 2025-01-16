import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TrangChu(),
    );
  }
}

class TrangChu extends StatefulWidget {
  @override
  _TrangChuState createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  int currentTab = 0;

  // Screens for bottom navigation
  final List<Widget> screens = [
    TrangChuScreen(),
    DonHangScreen(),
    ThuChiScreen(),
    CaiDatScreen(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = TrangChuScreen(); // Default screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add action for FAB
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side of Bottom Navigation Bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = TrangChuScreen();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: currentTab == 0 ? Colors.amber : Colors.grey,
                        ),
                        Text(
                          'Trang Chủ',
                          style: TextStyle(
                            color: currentTab == 0 ? Colors.amber : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = DonHangScreen();
                        currentTab = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: currentTab == 1 ? Colors.amber : Colors.grey,
                        ),
                        Text(
                          'Đơn Hàng',
                          style: TextStyle(
                            color: currentTab == 1 ? Colors.amber : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Right side of Bottom Navigation Bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = ThuChiScreen();
                        currentTab = 2;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.money_sharp,
                          color: currentTab == 2 ? Colors.amber : Colors.grey,
                        ),
                        Text(
                          'Thu Chi',
                          style: TextStyle(
                            color: currentTab == 2 ? Colors.amber : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = CaiDatScreen();
                        currentTab = 3;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          color: currentTab == 3 ? Colors.amber : Colors.grey,
                        ),
                        Text(
                          'Cài Đặt',
                          style: TextStyle(
                            color: currentTab == 3 ? Colors.amber : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy Screens
class TrangChuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Trang Chu Screen'));
  }
}

class DonHangScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Don Hang Screen'));
  }
}

class ThuChiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Thu Chi Screen'));
  }
}

class CaiDatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Cai Dat Screen'));
  }
}
