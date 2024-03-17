import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/InboxwithChat/ChatClient.dart';
import 'package:http/http.dart' as http;

import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';
import 'chat.dart';

class inboxtest extends StatefulWidget {
  const inboxtest({super.key});

  @override
  State<inboxtest> createState() => _inboxtestState();
}
late Future<List<Item>> futurechatusers;

Future<void> fetchLastMessageAndTime(Item chatItem) async {
  String chatId = chatItem.chat_id; // Assuming chat_id corresponds to Firebase chat document ID
  late AnimationController ciruclaranimation;
  // Query Firebase for the last message in this chat
  var lastMessageSnapshot = await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();

  if (lastMessageSnapshot.docs.isNotEmpty) {
    var lastMessage = lastMessageSnapshot.docs.first;
    chatItem.updateLastMessage(
      lastMessage['content'],
      (lastMessage['timestamp'] as Timestamp).toString()?? '',
    );
  }
}
Future<void> updateItemsWithLastMessage(List<Item> items) async {
  for (var item in items) {
    var lastMessageSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(item.chat_id)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (lastMessageSnapshot.docs.isNotEmpty) {
      var lastMessageDoc = lastMessageSnapshot.docs.first;
      item.lastMessage = lastMessageDoc['content'];
print('last message ${item.lastMessage}');
      // Convert the Timestamp to a DateTime and then format as a string
      DateTime date = (lastMessageDoc['timestamp'] as Timestamp).toDate() ;
      String formattedTime = DateFormat('h:mm a').format(date); // Formats to a string like "4:30 PM"

      item.lastMessageTime = formattedTime ?? ''; // Save the formatted time
    }
  }
}// After fetching user details from the API and initializing Item objects,
// call fetchLastMessageAndTime for each item to get the latest message and time from Firebase


// Now 'items' contains the merged data and can be used in the ListView.builder
List<Item> items = [];



Future<List<Item>> fetchchatusers() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';

    final response = await http.post(
      Uri.parse('https://workdonecorp.com/api/get_all_inbox'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        final List<dynamic> ChatsJson = responseData['chats'];

        if (ChatsJson.isEmpty) {
          // Response is empty, return a widget indicating an empty inbox
          return [
            Item(
              other_side_image: '', // Replace with appropriate values
              other_side_firstname: '',
              other_side_lastname: '',
              chat_id: '',
              client_id: 0,
              worker_id: 0,
              myside_image: '',
              myside_firstname: '',
            )
          ];
        }

        List<Item> Chats = ChatsJson.map((json) {
          return Item(
            other_side_image: json['other_side_image'],
            client_id: json['client_id'],
            worker_id: json['worker_id'],
            myside_image: json['myside_image'],
            myside_firstname: json['myside_firstname'],
            other_side_firstname: json['other_side_firstname'],
            other_side_lastname: json['other_side_lastname'],
            chat_id: json['chat_id'],
          );
        }).toList();
        for (Item chatItem in items) {
          await fetchLastMessageAndTime(chatItem);
        }
        print(ChatsJson);
        print(Item);
        print(Chats);
        return Chats;
      } else {
        throw Exception('Failed to load data from API: ${responseData['msg']}');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

class _inboxtestState extends State<inboxtest> with SingleTickerProviderStateMixin {
  String? usertype;
  Future<void> _getusertype() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_user_type';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData.containsKey('user_type')) {
            String userType = responseData['user_type'];
print(userType);
            // Navigate based on user type
            if (userType == 'client') {

              usertype = userType;
            } else if (userType == 'worker') {
                usertype = userType;
            } else {
              print('Error: Unknown user type.');

            }
          } else {
            print('Error: Response data does not contain user_type.');
          }
          print('user type is $usertype');
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }
      } else {
        // No token in SharedPreferences, navigate to WelcomeScreen
      }
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }
  late AnimationController ciruclaranimation;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
    _getusertype();
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);

    // Call the fetchchatusers() function and set the futurechatusers with the result
    futurechatusers = fetchchatusers().then((chats) async {
      await updateItemsWithLastMessage(chats); // this becomes an async closure
      if (mounted) setState(() {}); // Check if the widget is still in the tree
      return chats; // Returning the updated chats list
    });
  }
  @override
  void dispose() {
    ciruclaranimation.dispose();
    super.dispose();
  }

  String profile_pic ='' ;
  String firstname ='' ;
  String secondname ='' ;
  String email ='' ;
  Future<void> _getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_profile_info';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            Map<String, dynamic> profileData = responseData['data'];

            setState(() {
              firstname = profileData['firstname'] ?? '';
              secondname = profileData['lastname'] ?? '';
              email = profileData['email'] ?? '';
              profile_pic = profileData['profile_pic'] ?? '';
            });

            print('Response: $profileData');
            print('profile pic: $profile_pic');
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
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }
  bool search = false;



  final ScreenshotController screenshotController200 = ScreenshotController();

  String unique= 'inbox' ;
  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController200.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('4D8D6E'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return Scaffold(

      floatingActionButton:
      FloatingActionButton(    heroTag: 'workdone_${unique}',



        onPressed: () {
          _navigateToNextPage(context);

        },
        backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
        child: Icon(Icons.help ,color: Colors.white,), // Use the support icon        shape: CircleBorder(), // Make the button circular
      ),

      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: HexColor('EDEBEB'),
centerTitle: true,
      title: Text('Inbox' ,style: TextStyle(
        color: Colors.black,
        fontSize: 25,
        fontWeight: FontWeight.bold



      )),

      ),
      backgroundColor: HexColor('EDEBEB'),
      body: RefreshIndicator(
        color: HexColor('4D8D6E'),
        backgroundColor: Colors.white,
        onRefresh: () async {
          setState(() {
            fetchchatusers();
          });
        },
        child: Screenshot(
          controller:screenshotController200 ,
          child:SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: FutureBuilder<List<Item>>(
                      future: futurechatusers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: RotationTransition(
                            turns: ciruclaranimation,
                            child: SvgPicture.asset(
                              'assets/images/Logo.svg',
                              semanticsLabel: 'Your SVG Image',
                              width: 130,
                              height: 130,
                            ),
                          ))
                          ;
                        } else if (snapshot.hasError) {
                          return  Center(
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/emptyinbox.svg',
                                  width: 200.0,
                                  height: 300.0,
                                ),

                              SizedBox(height: 20,),
                                Text('Inbox is Empty',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                              ],

                            ),
                          );

                        } else if (snapshot.data!.isEmpty) {
                          return  SvgPicture.asset(
                            'assets/images/emptyinbox.svg',
                            width: 100.0,
                            height: 100.0,
                          );

                        }else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return  SvgPicture.asset(
                            'assets/images/emptyinbox.svg',
                            width: 100.0,
                            height: 100.0,
                          );
                        } else {
                          // Update the items list
                          items = snapshot.data!;

                          return Animate(
                            effects: [SlideEffect(duration: Duration(milliseconds: 400),),],
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return buildListItem(snapshot.data![index]);
                              },
                            ),
                          );

                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
  Widget buildListItem(Item item) {

    return Column(
      children: [
        SizedBox(height: 20,),
        GestureDetector(
          onTap:(){
            Get.to(chat(
client_id: item.client_id,
              myside_firstname: item.myside_firstname,
              myside_image: item.myside_image,
              worker_id: item.worker_id,
              seconduserimage: item.other_side_image,
              chatId: item.chat_id,
              currentUser: '${usertype}',
              secondUserName: "${item.other_side_firstname}",
              userId: '${item.chat_id}',
            ));

          },
          child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.transparent,
                backgroundImage: item.other_side_image == '' || item.other_side_image.isEmpty
                    || item.other_side_image == "https://workdonecorp.com/storage/" ||
                    !(item.other_side_image.toLowerCase().endsWith('.jpg') || item.other_side_image.toLowerCase().endsWith('.png'))

                    ? AssetImage('assets/images/default.png') as ImageProvider
                    : NetworkImage(item.other_side_image?? 'assets/images/default.png'),
              ),


              SizedBox(width: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.other_side_firstname}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8,),
                  if (item.lastMessage == '')
Text('.....',style: TextStyle(fontSize: 20),)       
                  else
                    Container(
                      width: MediaQuery.of(context).size.width * 0.512, // Adjust the width as needed
                      child: Row(
                        children: [
                          Expanded( // Use Expanded to ensure the Text widget fits within the available space
                            child: Text(
                              '${item.lastMessage}',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis, // Truncate the text with an ellipsis
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Spacer(),
              if (item.lastMessageTime == null)
                Text('')
                else
              Text(
                '${item.lastMessageTime}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30,),



      ],
    );
  }

}
class Item {

  final int client_id;
  final int worker_id;
  final  String myside_image;
  final  String myside_firstname;
  final  String other_side_firstname;
  final String other_side_image;
  final String other_side_lastname;
  final String chat_id;
  String? lastMessage; // Make optional
  String? lastMessageTime ;


  Item({
    required this.other_side_image,
    required this.client_id,
    required this.worker_id,
    required this.myside_image,
    required this.myside_firstname,
    required this.other_side_firstname,
    required this.other_side_lastname,
    required this.chat_id,
    this.lastMessage ='',
    this.lastMessageTime ,

  }) ;
  void updateLastMessage(String message, String time ) {
    lastMessage = message;
    lastMessageTime = time ?? '';
  }

}
