import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/newdrawer.dart';
import 'mediaquery.dart';

class CustomAppBarClient extends StatefulWidget implements PreferredSizeWidget {

  @override
  State<CustomAppBarClient> createState() => _CustomAppBarClientState();

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 50); // Add additional height for space
}

class _CustomAppBarClientState extends State<CustomAppBarClient> {
  late final AdvancedDrawerController advancedDrawerController; // Pass the controller as a parameter

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 50); // Add additional height for space

  String firstName = '';
  String lastName = '';

  int? clientId; // Change the variable name to clientId

  @override
  void initState() {
    super.initState();
    fetchClientData();
    retrieveClientId(); // Change the function name
  }

  Future<int?> getSavedClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? clientId = prefs.getInt('client_id'); // Change the key to 'client_id'
    print('Fetched Client ID: $clientId'); // Add this line

    return clientId;
  }

  void retrieveClientId() async {
    int? id = await getSavedClientId();
    setState(() {
      clientId = id;
    });
  }

  Future<void> fetchClientData() async {
    int? clientId = await getSavedClientId(); // Change the variable name

    if (clientId != null) {
      final apiUrl = 'http://172.233.199.17/clients.php'; // Change the API endpoint
      final url = Uri.parse(apiUrl + '?client_id=$clientId'); // Append client_id to the URL


      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
// Extract client data
        Map<String, dynamic> clientData = jsonResponse['data']['client'];

        // Extract specific fields from the client data
        String clientFirstName = clientData['client_firstname'];
        String clientLastName = clientData['client_lastname'];

        // Update state variables to display the fetched client information
        setState(() {
          firstName = clientFirstName;
          lastName = clientLastName;
          print(firstName);
        });
      } else {
        print('Failed to fetch client data. Status code: ${response.statusCode}');
      }
    } else {
      print('Client ID not found in SharedPreferences.');
    }
  }
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(


            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
            child:Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                  advancedDrawerController.showDrawer(); // Use the provided controller to open the drawer
                  },
                  child: SvgPicture.asset(
                    'assets/icons/menuicon.svg',
                    width: 57.0,
                    height: 57.0,
                  ),
                ),
                Spacer(),
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey, // Change the color as needed
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    // Handle the tap event here
                  },
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/profileimage.png'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
