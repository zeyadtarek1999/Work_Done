import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/mediaquery.dart';
import '../view/portofolio.dart';
import '../view/screens/Profile (client-worker)/profilescreenClient.dart';

class MyDrawerclient extends StatefulWidget {

  @override
  State<MyDrawerclient> createState() => _MyDrawerclientState();
}

class _MyDrawerclientState extends State<MyDrawerclient> {
  String firstName = '';
  String lastName = '';
  int? clientId;

  @override
  void initState() {
    super.initState();
    fetchClientData();
    retrieveClientId();
  }

  Future<int?> getSavedClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? clientId = prefs.getInt('client_id');
    print('Fetched Client ID: $clientId');
    return clientId;
  }

  void retrieveClientId() async {
    int? id = await getSavedClientId();
    setState(() {
      clientId = id;
    });
  }

  Future<void> fetchClientData() async {
    int? clientId = await getSavedClientId();

    if (clientId != null) {
      final apiUrl = 'http://172.233.199.17/clients.php';
      final url = Uri.parse('$apiUrl?client_id=$clientId'); // Use string interpolation to build the URL

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        Map<String, dynamic> clientData = jsonResponse['data']['client'];

        // Extract specific fields from the client data
        String clientFirstName = clientData['client_firstname'];
        String clientLastName = clientData['client_lastname'];

        setState(() {
          firstName = clientFirstName;
          lastName = clientLastName;
          print('First Name: $firstName'); // Added a label for clarity
          print('Last Name: $lastName'); // Added a label for clarity
        });
      } else {
        print('Failed to fetch client data. Status code: ${response.statusCode}');
      }
    } else {
      print('Client ID not found in SharedPreferences.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(width: 250,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(height: 240,
            child: DrawerHeader(
              decoration: BoxDecoration(

                color: HexColor('#4D8D6E'),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HexColor('#FFFFFF'),
                          width: 4,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profileimage.png',
                          // Replace with the image URL
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: HexColor('#EFCE4A'),
                        size: 28,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '4.2',
                        style: TextStyle(
                            color: HexColor('#FFFFFF'),
                            fontSize: 18),
                      )
                    ],
                  ),SizedBox(height: 3,),
                  Text(
                    '$firstName $lastName',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/profileicon.svg',
              width: 33.0,
              height: 33.0,
            ),// Icon

            title: Text('Profile'),
            onTap: () {
              // Add your logic here for when the first item is tapped
              Get.to (ProfileScreenClient2()); // Close the drawer
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/portfolio.svg',
              width: 33.0,
              height: 33.0,
            ),// Icon

            title: Text('portofolio'),
            onTap: () {
              Get.to (portofolio()); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}