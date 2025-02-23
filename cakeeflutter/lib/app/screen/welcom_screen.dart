import 'package:cakeeflutter/app/screen/login.dart';
import 'package:flutter/material.dart';
// Make sure to import the LoginScreen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Image.asset('assets/images/logo.png'), // Make sure to add your logo in the assets folder
            SizedBox(height: 20),
            Text(
              'Cakee',
              style: TextStyle(
              //doi font chu thanh AbeeZee
              fontFamily: 'AbeeZee',
              color: Color(0xFFFFD900),
              //vien chu mau den
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
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFD900)),
              onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
              },
              child: Text('Bắt đầu', style: TextStyle(color: Color(0xFF000000))),
            ),
          ],
        ),
      ),
    );
  }
}