import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class changepasswordapimodel {
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';

      final String apiUrl = 'https://workdonecorp.com/api/change_password';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody ['status'] == "success"){

          print('Password changed successfully');
          Fluttertoast.showToast(
            msg: 'Password changed successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          // Navigate back
          Get.back();
        }else if (responseBody ['status'] == "error" && responseBody ['msg'] == "Wrong current password"){

          print('Wrong current password');
          Fluttertoast.showToast(
            msg: "Wrong current password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          // Navigate back
        }
        // Password changed successfully



      } else {
        // Handle error response
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
        Fluttertoast.showToast(
          msg: 'Failed to change password. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      // Handle network or other errors
      print('Error changing password: $error');
      Fluttertoast.showToast(
        msg: 'Failed to change password. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}