import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;

import 'screens/welcome/welcome_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String _responseMessage = '';
  bool isLoading = false;

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter your email address.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final url = Uri.parse('https://www.workdonecorp.com/api/forgot_password');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'email': email});

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(url, headers: headers, body: body);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text(responseBody['msg']),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
Get.offAll(WelcomeScreen());
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            _responseMessage = responseBody['msg'] ?? 'An error occurred.';
          });
        }
      } else {
        final responseBody = json.decode(response.body);
        setState(() {
          _responseMessage = responseBody['msg'] ?? 'An error occurred.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _responseMessage = 'An error occurred.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Ionicons.arrow_back,
              size: 30,
              color: Colors.white
            ),
          ),
          centerTitle: true,
          title: Text('Forgot Password',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w600,
                fontSize: 20),
          ),
          backgroundColor: HexColor('4D8D6E'),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Enter your email address',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: 'you@example.com',
                    labelText: 'Write your Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _forgotPassword();
                    },
                    style: ElevatedButton.styleFrom(
                     backgroundColor: HexColor('4D8D6E'),
                     foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white,) // Show circular progress indicator when loading
                        : Text('Submit'),
                  ),
                ),


              ],
            ),
          ),
        ),

    );
  }
}