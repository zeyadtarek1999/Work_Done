import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
import '../view profile screens/Worker profile .dart';

class chat extends StatefulWidget {
  final String chatId;
  final int client_id;
  final int worker_id;
  final String
      currentUser; // Identify whether the current user is client or worker
  final String
      myside_firstname; // Identify whether the current user is client or worker
  final String
      myside_image; // Identify whether the current user is client or worker
  final String secondUserName; // Add this line
  final String userId; // Add this line
  final String seconduserimage; // Add this line
  chat(
      {required this.chatId,
      required this.currentUser,
      required this.secondUserName,
      required this.userId,
      required this.client_id,
      required this.worker_id,
      required this.myside_firstname,
      required this.myside_image,
      required this.seconduserimage});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('4D8D6E'),
      body: Container(
        margin: EdgeInsets.only(top: 45),
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
                  GestureDetector(
                    onTap: (){

                      if (widget.currentUser == 'client') {
                        Get.to(Workerprofileother(
                            userId: widget.worker_id.toString()));
                      } else if (widget.currentUser == 'worker') {
                        Get.to(ProfilePageClient(
                            userId: widget.client_id.toString()));
                      }

                    },

                    child:  CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      backgroundImage: widget.seconduserimage == '' || widget.seconduserimage.isEmpty
                          || widget.seconduserimage== "https://workdonecorp.com/images/"
                          ? AssetImage('assets/images/default.png') as ImageProvider
                          : NetworkImage(widget.seconduserimage?? 'assets/images/default.png'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (widget.currentUser == 'client') {
                          Get.to(Workerprofileother(
                              userId: widget.worker_id.toString()));
                        } else if (widget.currentUser == 'worker') {
                          Get.to(ProfilePageClient(
                              userId: widget.client_id.toString()));
                        }
                      },
                      child: Text(
                        '${widget.secondUserName}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10 ,horizontal: 12),
                width: MediaQuery.of(context).size.width,
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
                            .doc(widget.chatId)
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
                          print(widget.chatId);
                          if (messages.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    'Chat is Empty',
                                    style: TextStyle(fontSize: 20, color: Colors.grey,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              var messageContent = messages[index]['content'];
                              var messageSender = messages[index]['sender'];
                              var imageUrl =
                                  messages[index]['image']; // Add this line
                              var messageTime =
                                  messages[index]['timestamp'] as Timestamp?;

                              return ChatBubble(
                                myimage: widget.myside_image,
                                otherimage: widget.seconduserimage,
                                usertype: widget.currentUser,
                                clientid: widget.client_id,
                                workerid: widget.worker_id,
                                currentuser: messageSender,
                                message: messageContent,
                                isSentByMe:
                                    messageSender == widget.myside_firstname,
                                imageUrl: imageUrl,
                                time: messageTime != null
                                    ? messageTime.toDate()
                                    : DateTime.now(),
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

      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'sender': widget.myside_firstname,
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
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}');

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
  final String usertype;
  final int clientid;
  final int workerid;
  final String message;
  final String myimage;
  final String otherimage;
  final bool isSentByMe;
  final String? imageUrl;
  final bool? seen;
  final DateTime time; // Add this line

  ChatBubble({
    required this.currentuser,
    required this.myimage,
    required this.otherimage,
    required this.clientid,
    required this.workerid,
    required this.usertype,
    required this.message,
    required this.isSentByMe,
    this.imageUrl,
    this.seen,
    required this.time, // Add this line
  });

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => FullScreenImage(imageUrl: imageUrl),
    );
  }

  Widget _buildTimeStamp() {
    String formattedTime = DateFormat('hh:mm a').format(time);
    return Text(
      formattedTime,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSentByMe)
          GestureDetector(

            onTap:
            (){

              if (usertype == 'client' && isSentByMe) {
                Get.to(ProfilePageClient(userId: clientid.toString()));
              } else {
                Get.to(Workerprofileother(userId: workerid.toString()));
              }

            },
            child:
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.transparent,
              backgroundImage: otherimage == '' || otherimage.isEmpty
                  || otherimage== "https://workdonecorp.com/images/"
                  ? AssetImage('assets/images/default.png') as ImageProvider
                  : NetworkImage(otherimage?? 'assets/images/default.png'),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: isSentByMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (usertype == 'client' && isSentByMe) {
                        Get.to(ProfilePageClient(userId: clientid.toString()));
                      } else if (usertype == 'worker' &&  isSentByMe){
                        Get.to(Workerprofileother(userId: workerid.toString()));
                      }else if(usertype == 'worker' &&  !isSentByMe){
                        Get.to(ProfilePageClient(userId: clientid.toString()));


                      }else if (usertype == 'client' && !isSentByMe){

                        Get.to(Workerprofileother(userId: workerid.toString()));


                      }
                    },
                    child: Text(
                      currentuser,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (seen != null && !isSentByMe)
                    Icon(
                      seen! ? Icons.done_all : Icons.done,
                      size: 16,
                      color: seen! ? Colors.blue : Colors.grey[600],
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
                    if (imageUrl != null && imageUrl!.isNotEmpty)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Positioned(
                            child: GestureDetector(
                              onTap: () {
                                _showFullScreenImage(context, imageUrl!);
                              },
                              child: Image.network(
                                imageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.image,
                                size: 24,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    _buildTimeStamp(),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isSentByMe)
          GestureDetector(
            onTap: (){

              if (usertype == 'client' && isSentByMe) {
                Get.to(ProfilePageClient(userId: clientid.toString()));
              } else {
                Get.to(Workerprofileother(userId: workerid.toString()));
              }

            },
            child:
    CircleAvatar(
    radius: 25,
    backgroundColor: Colors.transparent,
    backgroundImage: myimage == '' || myimage.isEmpty
    || myimage== "https://workdonecorp.com/images/"
    ? AssetImage('assets/images/default.png') as ImageProvider
        : NetworkImage(myimage?? 'assets/images/default.png'),
    ),
    ),

      ],
    );

  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        child: Image.network(imageUrl, fit: BoxFit.contain),
      ),
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
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => FullScreenImageformessage(imagePath: imagePath),
    );
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
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                ),
                if (_selectedImage != null)
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
                    final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
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
                      )

              ],
            ),
          ),
        ),
        if (_selectedImage != null)
          Column(
            children: [
              Image.file(
                _selectedImage!,
                height: 100,
                width: 100,
              ),
              GestureDetector(
                onTap: () {
                  _showFullScreenImage(context, _selectedImage!.path);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _sendImage() async {
    // Implement your logic to send the image here
    // You can return a Future and use this method in the FutureBuilder
    // For demonstration, it's just a dummy implementation that waits for 2 seconds
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class FullScreenImageformessage extends StatelessWidget {
  final String imagePath;

  FullScreenImageformessage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
