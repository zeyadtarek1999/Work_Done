import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/model/firebaseNotification.dart';
import 'package:workdone/model/save_notification_to_firebase.dart';
import 'package:workdone/view/stateslectorpopup.dart';
import '../../model/post address model.dart';
import '../widgets/rounded_button.dart';
import 'package:http/http.dart' as http;

class editAddressClient extends StatefulWidget {
  const editAddressClient({super.key});


  @override
  State<editAddressClient> createState() => _editAddressClientState();
}

class _editAddressClientState extends State<editAddressClient> {
  final formKey = GlobalKey<FormState>();

  int  ? userId ;

  Future<void> getuserid() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);
      print ('fetching user id');
      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://www.workdonecorp.com/api/get_user_id_by_token';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          print ('done  user id');

          if (responseData.containsKey('user_id')) {

            userId = responseData['user_id'];

            // Now, userId contains the extracted user_id value
            print('User ID: $userId');

            // Optionally, save the user_id to SharedPreferences
            prefs.setInt('user_id', userId ?? 0);
          } else {
            print('Error: Response data does not contain the expected structure.');
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

  String selectedState = 'Select State';

  bool _isFormFilled = false;

  List<String> statesOfAmerica = [
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts',
    'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
    'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island',
    'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia',
    'Wisconsin', 'Wyoming',
  ];
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
    getuserid();
    // Fetch user profile information when the screen initializes
    getaddressuser();
    addressZipController == addressZip.toString();
  }


  Future<void> _updateAddress() async {
    // Retrieve values from TextEditingControllers
    String street1 = addressline1Controller.text;
    String street2 = addressline2Controller.text;
    String city = cityController.text;
    String state = selectedState;
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
  Future<void> editaddress() async {
    final url = Uri.parse('https://www.workdonecorp.com/api/update_address');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print (userToken);
      // Make the API request
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $userToken' ;
      if (addressline1Controller .text.isNotEmpty) {
        request.fields['street1'] = addressline1Controller .text;
      } else {
        request.fields['street1'] = addressline1 ;
      }
      if (addressline2Controller  .text.isNotEmpty) {
        request.fields['street2'] = addressline2Controller  .text;
      } else {
        request.fields['street2'] = addressline2 ;
      }
      if (cityController  .text.isNotEmpty) {
        request.fields['city'] = cityController  .text;
      } else {
        request.fields['city'] = city ;
      }
      if (selectedState    .isNotEmpty) {
        request.fields['state'] = selectedState;
      } else {
        request.fields['state'] = state  ;
      }
      if (addressZipController  .text.isNotEmpty) {
        request.fields['address_zip'] = addressZipController.text;
      } else {
        request.fields['address_zip'] = addressZip   ;
      }
      final response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(await response.stream.transform(utf8.decoder).join());

        // Check the status in the response
        if (responseBody['status'] == 'success') {
          print(responseBody);
          DateTime currentTime = DateTime.now();

          // Format the current time into your desired format
          String formattedTime = DateFormat('h:mm a').format(currentTime);
          Map<String, dynamic> newNotification = {
            'title': 'Address Updated',
            'body': 'Your Address information has been successfully updated 😊',
            'time': formattedTime,
            // Add other notification data as needed
          };
          print('sended notification ${[newNotification]}');


          SaveNotificationToFirebase.saveNotificationsToFirestore(userId.toString(), [newNotification]);
          print('getting notification');


          DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId.toString());

// Get the user document
          DocumentSnapshot doc = await userDocRef.get();

// Check if the document exists
          if (doc.exists) {
            // Extract the FCM token and notifications list from the document
            String? receiverToken = doc.get('fcmToken');
            List<Map<String, dynamic>> notifications = doc.get('notifications').cast<Map<String, dynamic>>();

            // Check if the new notification is not null and not already in the list
            if (!notifications.any((notification) => notification['id'] == newNotification['id'])) {
              // Add the new notification to the beginning of the list
              notifications.insert(0, newNotification);

              // Update the user document with the new notifications list
              await userDocRef.update({
                'notifications': notifications,
              });

              print('Notifications saved for user $userId');
            }

            // Display the notifications list in the app
            print('Notifications for user $userId:');
            for (var notification in notifications) {
              String? title = notification['title'];
              String? body = notification['body'];
              print('Title: $title, Body: $body');
              await NotificationUtil.sendNotification(title ?? 'Default Title', body ?? 'Default Body', receiverToken ?? '2',DateTime.now());
              print('Last notification sent to $userId');
            }
          } else {
            print('User document not found for user $userId');
          }

          Fluttertoast.showToast(
            msg: "Address updated successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          // Navigate to the layout screen
          Navigator.pop(context);
        }

      }
      else {

        print('Failed to edit address. Status code: ${response.statusCode}');

        // Print the response body for more details
        print('Response body: ${await response.stream.transform(utf8.decoder).join()}');

      }
    } catch (e) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      print('Error edit address: $e');
      // Handle errors as needed
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
              selectedState  = Addressdata['state'] ?? '';
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

    return Form(
      key: formKey,
      child: Scaffold(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Note',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text('You Can Edit Any Field Only and Press Submit',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                          color: Colors.black45,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),                        SizedBox(height: 8,),

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
                          child: Stack(
                            children: [
                              TextFormField(
                                readOnly: true,
                                style: TextStyle(color: HexColor('#4D8D6E')),
                                decoration: InputDecoration(
                                  hintText: selectedState ?? 'Select State',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                  border: InputBorder.none,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StateSelectorPopup(
                                        states: statesOfAmerica,
                                        onSelect: (newlySelectedState) {
                                          setState(() {
                                            selectedState = newlySelectedState;
                                          });
                                          print('Selected State: $newlySelectedState');
                                        },
                                      );
                                    },
                                  );
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ),
                            ],
                          ),
                        ),                    ],
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
                            child: TextFormField(
                              controller: addressZipController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(5),
                              ],
                              decoration: InputDecoration(
                                hintText: addressZip.toString(),
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  // If the value is empty, don't show an error message
                                  return null;
                                }

                                if (value.length != 5 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'Please enter a valid 5-digit zip code.';
                                }

                                return null;
                              },
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
                text: 'Submit',
                press: () async {
                  if (formKey.currentState!.validate()) {
                    // If the form is valid, call the editaddress() function
                    await editaddress();


                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
