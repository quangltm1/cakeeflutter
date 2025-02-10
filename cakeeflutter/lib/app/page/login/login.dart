import 'package:cakeeflutter/app/page/login/register_user.dart';
import 'package:cakeeflutter/app/page/UserUI/trangchu.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Set background color to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png'), // Make sure to add your logo in the assets folder
            SizedBox(height: 20),
            Text(
              'Đăng nhập',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Color(0xFFFFD900),
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Color(0xFF000000),
                  ),
                ],
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Tài khoản',
                  style: TextStyle(fontSize: 16.0, fontFamily: 'Montserrat',),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Nhập tài khoản',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Mật khẩu',
                  style: TextStyle(fontSize: 16.0,
                  fontFamily: 'Montserrat',
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Nhập mật khẩu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD900)),
                  onPressed: () {
                    // Handle login logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('Đăng nhập', style: TextStyle(color: Colors.black),),
                ),
                SizedBox(width: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD900)),
                  onPressed: () {
                    // Handle register logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterUserScreen()),
                    );
                  },
                  child: Text('Đăng ký', style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}