import 'package:cakeeflutter/app/page/login/register.dart';
import 'package:cakeeflutter/trangchu.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                  // Handle login logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('Login'),
                ),
                SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: () {
                  // Handle register logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text('Register'),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}