import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../Support Screen/Helper.dart';
import '../homescreen/home screenClient.dart';
import '../view profile screens/Client profile view.dart';

class ChatScreen extends StatelessWidget {
  final String chatId; // Unique identifier for the chat
  final String currentUser; // Identify whether the current user is client or worker
  final String secondUserName; // Add this line
  final String userId; // Add this line
  final String seconduserimage; // Add this line
  ChatScreen(
      {required this.chatId, required this.currentUser, required this.secondUserName,
        
        required this.userId,
        required this.seconduserimage
      
      
      });

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: HexColor('4D8D6E'),
      body: Container(
        margin: EdgeInsets.only(top: 60),
        child: Column(
            children: [
        Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
        IconButton(
        icon: Icon(
        Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);

          // Handle back button press
        },
      ),
      SizedBox(
        width: 50,
      ),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(
                seconduserimage != null &&
                    seconduserimage.isNotEmpty
                    ? seconduserimage
                    : 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
              ),
            ),
      Center(
        child: TextButton(onPressed: () {
          Get.to(ProfilePageClient(
              userId: userId ));
        },
          child: Text(
            '${secondUserName}',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ),
      )],
      ),
    ),
    SizedBox(
    height: 10,
    ),
    Expanded (
    child: Container(
    padding: EdgeInsets.all(20),
    width: MediaQuery
        .of(context)
        .size
        .width,
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
    ),
    ),
    child: Column(
    children: [
    Expanded(
    child: StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp',
    descending: true) // Ensure descending order
        .snapshots(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
    return Center(
    child: CircularProgressIndicator(),
    );
    }

    var messages = snapshot.data!.docs;
    // List<Widget> messageWidgets = [];
    // for (var message in messages) {
    //   var messageContent = message['content'];
    //   var messageSender = message['sender'];
    //
    //   var messageWidget = MessageWidget(
    //     sender: messageSender,
    //     content: messageContent,
    //     isClient: currentUser == 'client',
    //   );
    //   messageWidgets.add(messageWidget);
    // }
print(chatId);
    return ListView.builder(
    reverse: true,
    itemCount: messages.length,
    itemBuilder: (context, index) {
    var messageContent = messages[index]['content'];
    var messageSender = messages[index]['sender'];
    var imageUrl = messages[index]['image']; // Add this line
    var messageTime = (messages[index]['timestamp'] as Timestamp).toDate(); // Get the DateTime from Timestamp

    return ChatBubble(
    currentuser: messageSender,
    message: messageContent,
    isSentByMe: messageSender == currentUser,
    imageUrl: imageUrl,
      time: messageTime, // Pass the DateTime object
// Add this line
    );
    },
    );
    },
    ),


    ),
    SizedBox(height: 20),
    SendMessageField(
    onSendMessage: (message, image) {
    sendMessage(message, image);
    },
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    ),
    );
    }

  void sendMessage(String content, File? image) async {
    try {
      if (content.isEmpty && image == null) {
        Fluttertoast.showToast(
          msg: "Empty message. Please write a message or select an image.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      var imageUrl;
      if (image != null) {
        imageUrl = await uploadImageToStorage(image);
      }

      FirebaseFirestore.instance.collection('chats').doc(chatId).collection(
          'messages').add({
        'sender': currentUser,
        'content': content,
        'image': imageUrl, // Store image URL or path
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false, // Initialize as not seen
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<String?> uploadImageToStorage(File image) async {
    try {
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('images/${DateTime
          .now()
          .millisecondsSinceEpoch}');

      final UploadTask uploadTask = storageReference.putFile(image);

      // Get the snapshot of the upload task to track the progress
      TaskSnapshot snapshot = await uploadTask;

      // Wait until the upload is complete
      await snapshot.ref.getDownloadURL();

      // Get the download URL of the uploaded image
      final String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

class ChatBubble extends StatelessWidget {
  final String currentuser;
  final String message;
  final bool isSentByMe;
  final String? imageUrl;
  final bool? seen;
  final DateTime time; // Add this line

  ChatBubble({
    required this.currentuser,
    required this.message,
    required this.isSentByMe,
    this.imageUrl,
    this.seen,
    required this.time, // Add this line

  });
  Widget _buildTimeStamp() {
    String hourMinute = DateFormat('hh:mm a').format(time); // Format the time
    return Text(
      hourMinute,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(
              currentuser,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (seen != null && !isSentByMe)
              Icon(
                seen! ? Icons.done_all : Icons.done,
                size: 16,
                color: seen! ? Colors.blue : Colors.red[600],
              ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isSentByMe ? Colors.grey[200] : Colors.green[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (imageUrl != null) // Display the image if it exists
                Image.network(
                  imageUrl!,
                  width: 200,
                  height: 200,
                ),
              if (message
                  .isNotEmpty) // Display the text message if it's not an empty string
                Text(
                  message,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              _buildTimeStamp(), // Display formatted time

            ],
          ),
        ),
      ],
    );
  }
}

class SendMessageField extends StatefulWidget {
  final Function(String, File?) onSendMessage;

  SendMessageField({required this.onSendMessage});

  @override
  _SendMessageFieldState createState() => _SendMessageFieldState();
}

class _SendMessageFieldState extends State<SendMessageField> {
  final TextEditingController _messageController = TextEditingController();
  File? _selectedImage;

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type a message",
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                ),
                if (_selectedImage !=
                    null) // Display delete icon only if an image is selected
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                IconButton(
                  icon: Icon(
                    Icons.photo,
                    color: Colors.grey[700],
                  ),
                  onPressed: () async {
                    // Trigger the image picker
                    final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                ),
                GestureDetector(
                  onTap: () {
                    String message = _messageController.text;
                    widget.onSendMessage(message, _selectedImage);
                    _messageController.clear();
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ),
        ),
        if (_selectedImage != null)
          Image.file(
            _selectedImage!,
            height: 100,
            width: 100,
          ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}