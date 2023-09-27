import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'mediaquery.dart';

class CustomAppBarworker extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<CustomAppBarworker> createState() => _CustomAppBarworkerState();

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 50); // Add additional height for space
}
class _CustomAppBarworkerState extends State<CustomAppBarworker> {
  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 50);
 // Add additional height for space

  String firstName = '';

  String lastName = '';
  int? workerId;

  @override
  void initState() {
    super.initState();
    fetchWorkerData();
    retrieveWorkerId();
  }
  Future<void> saveWorkerId(int workerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('worker_id', workerId);
  }

  Future<int?> getSavedWorkerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? workerId = prefs.getInt('worker_id');
    print('Fetched Worker ID: $workerId');

    return workerId;
  }
  void retrieveWorkerId() async {
    int? id = await getSavedWorkerId();
    setState(() {
      workerId = id;
    });
  }

  Future<void> fetchWorkerData() async {
    int? workerId = await getSavedWorkerId();

    if (workerId != null) {
      final apiUrl = 'http://172.233.199.17/worker.php';
      final url = Uri.parse(apiUrl + '?worker_id=$workerId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Extract worker data and languages
        Map<String, dynamic> workerData = jsonResponse['data']['worker'];
        List<dynamic> languages = jsonResponse['data']['languages'];

        // Now you can access the worker data and languages list
        print('Worker Data: $workerData');
        print('Languages: $languages');

        // Extract specific fields from the worker data
        String workerFirstName = workerData['worker_firstname'];
        String workerLastName = workerData['worker_lastname'];
        // ... other fields

        // Update state variables to display the fetched worker information
        setState(() {
          firstName = workerFirstName;
          lastName = workerLastName;
          // ... update other fields
        });
      } else {
        print('Failed to fetch worker data. Status code: ${response.statusCode}');
      }
    } else {
      print('Worker ID not found in SharedPreferences.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
          child: Row(
            children: [
              InkWell(borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Handle the tap event here
                },
                child: SvgPicture.asset(
                  'assets/icons/menuicon.svg',
                  width: 57.0, // Set the width you want
                  height: 57.0, // Set the height you want
                ),
              ),
              Spacer(),
              Text('Home',style:GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HexColor('605E5E'),),),
              Spacer(),
              InkWell(
                onTap: () {
                  // Handle the tap event here
                },
                child: CircleAvatar(
                  radius: 27, // Adjust the radius as needed
                  backgroundColor: Colors.transparent, // Set the background color to transparent for a circular avatar
                  backgroundImage: AssetImage( 'assets/images/profileimage.png'), // Replace with your asset image path
                ),
              )






            ],
          ),
        )
    );
  }
}
