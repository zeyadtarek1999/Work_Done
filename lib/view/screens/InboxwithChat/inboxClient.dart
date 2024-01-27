import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:workdone/view/screens/InboxwithChat/ChatClient.dart';
import 'package:http/http.dart' as http;

import '../../../controller/shimmers/shimmer basic.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';

class InboxClient extends StatefulWidget {
  const InboxClient({super.key});

  @override
  State<InboxClient> createState() => _InboxClientState();
}
late Future<List<Item>> futurechatusers;

Future<void> fetchLastMessageAndTime(Item chatItem) async {
  String chatId = chatItem.chat_id; // Assuming chat_id corresponds to Firebase chat document ID

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
      (lastMessage['timestamp'] as Timestamp).toString(),
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

      // Convert the Timestamp to a DateTime and then format as a string
      DateTime date = (lastMessageDoc['timestamp'] as Timestamp).toDate();
      String formattedTime = DateFormat('h:mm a').format(date); // Formats to a string like "4:30 PM"

      item.lastMessageTime = formattedTime; // Save the formatted time
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
            )
          ];
        }

        List<Item> Chats = ChatsJson.map((json) {
          return Item(
            other_side_image: json['other_side_image'],
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

class _InboxClientState extends State<InboxClient> {

  @override
  void initState() {
    super.initState();
    _getUserProfile();

    // Call the fetchchatusers() function and set the futurechatusers with the result
    futurechatusers = fetchchatusers().then((chats) async {
      await updateItemsWithLastMessage(chats); // this becomes an async closure
      if (mounted) setState(() {}); // Check if the widget is still in the tree
      return chats; // Returning the updated chats list
    });
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



  final ScreenshotController screenshotController = ScreenshotController();

  String unique= 'inbox' ;
  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController.capture();

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
        child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
        shape: CircleBorder(), // Make the button circular
      ),
      backgroundColor: HexColor('4D8D6E'),
      body: Screenshot(
        controller:screenshotController ,
        child:Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 40, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Inbox',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.279,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: FutureBuilder<List<Item>>(
                  future: futurechatusers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Replace CircularProgressIndicator with Shimmer.fromColors
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: YourShimmerWidget(), // Your custom shimmer widget
                      );
                    } else if (snapshot.hasError) {
                      return  SvgPicture.asset(
                        'assets/images/emptyinbox.svg',
                        width: 100.0,
                        height: 100.0,
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

                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return buildListItem(snapshot.data![index]);
                        },
                      );

                    }
                  },
                ),
              ),
            ],
          ),

        ),
      ),
    );

  }
  Widget buildListItem(Item item) {

    return Column(
      children: [
        GestureDetector(
          onTap:(){
            Get.to(ChatScreen(
              seconduserimage: item.other_side_image,
              chatId: item.chat_id,
              currentUser: '${firstname}',
              secondUserName: "${item.other_side_firstname}",
              userId: '${item.chat_id}',
            ));

          },
          child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  item.other_side_image == 'https://workdonecorp.com/images/'
                      ? 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png'
                      : item.other_side_image ?? 'https://example.com/placeholder.jpg',
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  Text(
                    '${item.other_side_firstname}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${item.lastMessage} ',
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),

                ],
              ),
              Spacer(),
              Text(
                '${item.lastMessageTime}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
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

  final String other_side_image;
  final  String other_side_firstname;
  final String other_side_lastname;
  final String chat_id;
  String? lastMessage; // Make optional
  String? lastMessageTime;


  Item({
    required this.other_side_image,
    required this.other_side_firstname,
    required this.other_side_lastname,
    required this.chat_id,
    this.lastMessage ='',
    this.lastMessageTime ,

  }) ;
  void updateLastMessage(String message, String time) {
    lastMessage = message;
    lastMessageTime = time;
  }

}
