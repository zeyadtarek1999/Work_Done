import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:screenshot/screenshot.dart';

import '../Support Screen/Support.dart';

class Chatbody extends StatefulWidget {
  final String chatId; // Unique identifier for the chat
  final String currentUser; //

  Chatbody({required this.chatId, required this.currentUser});
  @override
  State<Chatbody> createState() => _ChatbodyState();
}

final ScreenshotController screenshotController = ScreenshotController();

String unique= 'chatbody' ;
void _navigateToNextPage(BuildContext context) async {
  Uint8List? imageBytes = await screenshotController.capture();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
    ),
  );
}
class _ChatbodyState extends State<Chatbody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( floatingActionButton:
    FloatingActionButton(    heroTag: 'workdone_${unique}',

mini: true,

      onPressed: () {
        _navigateToNextPage(context);

      },
      backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
      child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
      shape: CircleBorder(), // Make the button circular
    ),

      backgroundColor: HexColor('4D8D6E'),
      body:
      Screenshot(
        controller:screenshotController ,
        child: Container(
          margin: EdgeInsets.only(
            top: 60,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    Text(
                      'Mohamed',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.only(left: 20,right: 20,top: 50 , bottom: 40),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.167,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/2),
                      alignment:Alignment.bottomRight,
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10)))
                      ,child:
                    Text('Hello , what are you doing ',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w500),),
                    ),
                    SizedBox(height: 20,),

                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width/2),

                      alignment:Alignment.topLeft,
                      decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10)))
                      ,child:
                    Text('Nothing ',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w500),),
                    ),
                    Spacer(),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding:EdgeInsets.only(top: 8,bottom: 8,left: 15,right: 10),
                        decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(30) ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(border: InputBorder.none,hintText: "Type a message",hintStyle: TextStyle(color: Colors.black38)),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.grey[100] , borderRadius:BorderRadius.circular(60) ),
                                child: Center(child: Icon(Icons.send,color: Colors.grey[700],)))
                          ],
                        ),),
                    )

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
