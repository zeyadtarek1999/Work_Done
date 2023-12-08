import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/changePassword.dart';
import '../../model/post address model.dart';
import '../widgets/rounded_button.dart';
import 'package:http/http.dart' as http;

class editAddressClient extends StatefulWidget {
  const editAddressClient({super.key});


  @override
  State<editAddressClient> createState() => _editAddressClientState();
}

class _editAddressClientState extends State<editAddressClient> {
  String addressline1 = '';

  String addressline2 = '';

  String city = '';

  String state = '';
  late String userToken;


  String addressZip = '';

  final TextEditingController addressline1Controller = TextEditingController();

  final TextEditingController addressline2Controller  = TextEditingController();

  final TextEditingController cityController  = TextEditingController();

  final TextEditingController stateController  = TextEditingController();

  final TextEditingController addressZipController  = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Fetch user profile information when the screen initializes
    getaddressuser();
  }


  Future<void> _updateAddress() async {
    // Retrieve values from TextEditingControllers
    String street1 = addressline1Controller.text;
    String street2 = addressline2Controller.text;
    String city = cityController.text;
    String state = stateController.text;
    String zipCode = addressZipController.text;

    // Call the API to update the address
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('user_token') ?? '';
      await UpdateAddressApi.updateAddress(
        token: userToken,
        street1: street1,
        street2: street2,
        city: city,
        state: state,
        zipCode: zipCode,
      );

      // Handle success (you can show a success message or navigate to another screen)
    } catch (error) {
      // Handle error (you can show an error message)
      print('Error updating address: $error');
    }
  }

  Future<void> getaddressuser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_address';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('Address_data')) {
            Map<String, dynamic> Addressdata = responseData['Address_data'];

            setState(() {
              addressline1  = Addressdata['street1'] ?? '';
              addressline2  = Addressdata['street2'] ?? '';
              city  = Addressdata['city'] ?? '';
              state  = Addressdata['state'] ?? '';
              addressZip = Addressdata['address_zip']?.toString() ?? '';
            });

            print('Response: $Addressdata');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load profile information');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }
      }
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 67,
        backgroundColor: Colors.white,
        title: Text(
          'Edit Address',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: HexColor('454545'),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: Colors.black,
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Text('Address Line 1'),
                      ),
                      Container(
                        width: size.width * 0.90,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: addressline1Controller ,
                            decoration: InputDecoration(
                              hintText: addressline1 ,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Text('Address Line 2'),
                      ),
                      Container(
                        width: size.width * 0.90,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: addressline2Controller  ,
                            decoration: InputDecoration(
                              hintText: addressline2 ,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Text("city" ),
                      ),
                      Container(
                        width: size.width * 0.90,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: cityController  ,
                            decoration: InputDecoration(
                              hintText: city ,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Text('State'),
                      ),
                      Container(
                        width: size.width * 0.90,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: stateController  ,
                            decoration: InputDecoration(
                              hintText: state,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Text("Zip Code" ),
                      ),
                      Container(
                        width: size.width * 0.90,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: addressZipController  ,
                            decoration: InputDecoration(
                              hintText: addressZip.toString() ,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
      RoundedButton(
        text: 'Confirm',
        press: () async {
          await _updateAddress();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Update Address Done'),
                content: Text('Your address has been successfully updated.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pop(context); // Close the screen
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      )
          ],
        ),
      ),
    );
  }
}
