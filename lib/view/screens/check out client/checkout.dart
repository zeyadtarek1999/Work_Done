import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/check%20out%20client/payment.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';
import 'package:workdone/view/screens/check%20out%20client/paypal%20checkout.dart';
import 'package:workdone/view/screens/editProfile/editprofileworker.dart';
import 'package:workdone/view/widgets/rounded_button.dart';
import 'package:http/http.dart' as http;

import '../Bid Details/Bid details Client.dart';
import '../Edit address.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';
import '../view profile screens/Client profile view.dart';
import '../view profile screens/Worker profile .dart';

class checkOutClient extends StatefulWidget {
  final int userId;
  final String workerimage;
  final List<String> projectimage;
  final String currentbid;
  final int workerId;
  final String workername;
  final String projecttitle;
  final String project_id;
  final String selectedworkerrating;
  final String projectdesc;

  checkOutClient(
      {required this.userId,
      required this.workerimage,
      required this.projectimage,
      required this.selectedworkerrating,
      required this.project_id,
      required this.workerId,
      required this.currentbid,
      required this.projecttitle,
      required this.projectdesc,
      required this.workername});

  @override
  State<checkOutClient> createState() => _checkOutClientState();
}

class _checkOutClientState extends State<checkOutClient> {
  int _currentIndex = 0;
  int selectedValue = 1;

  String addressline1 = '';

  String addressline2 = '';

  String city = '';

  String state = '';
  String addressZip = '';
  String chat = '';
  late List<String> projectImages;
  double total=0.0;
  double fee=0.0;
  double currentBidAmount=0.0;
// Define a function to handle item selection
  Future<int> acceptproject() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);
       fee = 3.0; // Replace this with your actual fee
       currentBidAmount = double.parse(widget.currentbid);

// Calculate the total by adding the current bid and fee
       total= currentBidAmount + fee;
      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/accept_worker_bid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'project_id': widget.project_id.toString(),
          'worker_id': widget.workerId.toString(),
          'final_bid':total.toString()
        }),
      );
      print(chat);
      print(chat);
      print(chat);

      print(widget.workerId);
      print(widget.workerId);
      print(widget.workerId);

      print(widget.project_id);
      print(widget.project_id);
      print(widget.project_id);


      print(total);
      print(total);
      print(total);
      if (response.statusCode == 200) {
        Map<dynamic, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('chat')) {
          int chat = responseData['chat'];

          setState(() {
            chat = chat;

          });

          print('Response: $chat');

          print("accepted \n ${chat}");
          print(chat);
          print(chat);

          print(widget.workerId);
          print(widget.workerId);
          print(widget.workerId);

          print(widget.project_id);
          print(widget.project_id);
          print(widget.project_id);


          print(total);
          print(total);
          print(total);
          return chat;
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
              addressline1 = Addressdata['street1'] ?? '';
              addressline2 = Addressdata['street2'] ?? '';
              city = Addressdata['city'] ?? '';
              state = Addressdata['state'] ?? '';
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
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    projectImages = widget.projectimage;
    getaddressuser();
  }
  String unique= 'checkout' ;
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
    double fee = 3.0; // Replace this with your actual fee
    double currentBidAmount = double.parse(widget.currentbid);

// Calculate the total by adding the current bid and fee
     total = currentBidAmount + fee;
    return Scaffold(
      floatingActionButton:
      FloatingActionButton(    heroTag: 'workdone_${unique}',



        onPressed: () {
          _navigateToNextPage(context);

        },
        backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
child: Icon(Icons.help ,color: Colors.white,), // Use the support icon        shape: CircleBorder(), // Make the button circular
      ),
      backgroundColor: HexColor('FFFFFF'),
      appBar: AppBar(
        elevation: 3,
        centerTitle: true,
        backgroundColor: HexColor('FFFFFF'),
        title: Text(
          'Check Out',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: HexColor('3A3939'),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {Get.back();},
          icon: Icon(
            Icons.arrow_back_sharp,
            color: HexColor('1A1D1E'),
            size: 27,
          ),
        ),
        toolbarHeight: 67,
      ),
      body: Screenshot(
        controller:screenshotController ,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 27, right: 23, left: 23, bottom: 5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: HexColor('FFFFFF'),
                    border: Border(
                      bottom: BorderSide(
                        color: HexColor('D8D8D8'),
                        // Specify the color of the bottom border
                        width: 1.0, // Specify the width of the bottom border
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Address',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: HexColor('424347'),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${addressline1.toString()} ',
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: HexColor('3E3E3E'),
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Radio(
                                activeColor: HexColor('4D8D6E'),
                                // Hex color 4D8D6E
                                value: 1,
                                groupValue: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value as int;
                                  });
                                },
                              ),
                            ],
                          ),
                          Text(
                            '${addressline2.toString()} ,${city.toString()} ',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                color: HexColor('3E3E3E'),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(editAddressClient());
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('4D8D6E'),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 314,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12),
                      child: Text(
                        'Project details',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: HexColor('424347'),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      projectImages.isNotEmpty ? projectImages[0] :  'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',

                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    widget.projecttitle.toString().length > 20 ? widget.projecttitle.toString().substring(0, 20) + '...' : widget.projecttitle.toString(),                                    style: GoogleFonts.roboto(
                                      textStyle: TextStyle(
                                        color: HexColor('030302'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
,
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                    width: 215, // Set a width for the container
                                    child: Text(
                                      widget.projectdesc.toString(),
                                      maxLines: 3, // Set the maximum number of lines
                                      overflow: TextOverflow.ellipsis, // Overflow behavior (you can use TextOverflow.fade, TextOverflow.clip, etc.)
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )


                                ],
                              )
                            ],
                          ),

                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8),
                      child: Text(
                        'Selected Worker',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: HexColor('424347'),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 3),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(widget.workerimage ==
                                      ''
                                  ? 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png'
                                  : widget.workerimage),
                              radius: 25,
                            ),
                            SizedBox(width: 5),
                            TextButton(
                              onPressed: () {
                                Get.to(Workerprofileother(userId: widget.workerId.toString()));
                              },
                              child: Text(
                                widget.workername.toString(),
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: HexColor('#4D8D6E'),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${widget.selectedworkerrating}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23.0),
                child: Container(
                  height: 1,
                  // Set the height to control the thickness of the line
                  color: HexColor('D8D8D8'), // Set the color of the line
                ),
              ),
              SizedBox(
                height: 13,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Project',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${currentBidAmount}',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          '\$',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          'Fees',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Container(
                          width: 20, // Set the desired width
                          height: 30, // Set the desired height
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Make the container circular
                          ),
                          child: IconButton(
                            iconSize: 17,
                            // Set the desired icon size
                            icon: Icon(Icons.info_outline,
                                color: HexColor('4D8D6E')),
                            // Use the 'info' icon
                            onPressed: () {
                              // Show the dialog when the icon is pressed
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Information'),
                                    content: Text('information.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text(
                                          'Close',
                                          style: TextStyle(
                                            color: HexColor(
                                                '4D8D6E'), // Set the 'Close' button color
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${fee}',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          '\$',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${total}',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          '\$',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: HexColor('3E3E3E'),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        '(What you will pay) ',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('9A9D9C'),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Center(
                  child: RoundedButton(
                      text: 'Pay Now',
                      press: () async {
print(total);
int projectIdAsInt = int.parse(widget.project_id);

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => PaypalCheckout(
                              sandboxMode: true,
                              clientId: "ARmLFvTeapAnQ3eKmmtR4A34yXqTKSvh9assM9YlXzgVoB07MaLpRkNQkBTNZBD131HhTWkDQlIIU6qg",
                              secretKey: "EB__UVRnUJQxfOhfUEIQsbhIZCtH7DBouIOER_bDOWfcsEEuiWhXhwgfNwYT7DGfxhVEzaRCpK7Etz-c",
                              returnURL: "success.snippetcoder.com",
                              cancelURL: "cancel.snippetcoder.com",
                              transactions:  [
                                {
                                  "amount": {
                                    "total": '${total.toString()}',
                                    "currency": "USD",
                                    "details": {
                                      "subtotal": '${total.toString()}',
                                      "shipping": '0',
                                      "shipping_discount": 0
                                    }
                                  },
                                  "description":
                                      "The payment transaction description.",
                                  // "payment_options": {
                                  //   "allowed_payment_method":
                                  //       "INSTANT_FUNDING_SOURCE"
                                  // },
                                  "item_list": {
                                    "items": [
                                      {
                                        "name": "${widget.projecttitle}",
                                        "quantity": 1,
                                        "price": '${total.toString()}',
                                        "currency": "USD"
                                      },

                                    ],
        
                                    // shipping address is not required though
                                    //   "shipping_address": {
                                    //     "recipient_name": "Raman Singh",
                                    //     "line1": "Delhi",
                                    //     "line2": "",
                                    //     "city": "Delhi",
                                    //     "country_code": "IN",
                                    //     "postal_code": "11001",
                                    //     "phone": "+00000000",
                                    //     "state": "Texas"
                                    //  },
                                  }
                                }
                              ],
                              note: "Contact us for any questions on your order.",
                              onSuccess: (Map params) async {
                                acceptproject();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Payment Successful'),
                                      content: Text('Thank you for your payment!'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            // Close the dialog
Get.off(bidDetailsClient(projectId: projectIdAsInt));

},
                                          child: Text('Okay'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                Get.to(bidDetailsClient(projectId: projectIdAsInt));
                                print("onSuccess: $params");

                              },
                              onError: (error) {
                                Fluttertoast.showToast(
                                  msg: "Error during payment",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Payment failed'),
                                      content: Text('try again!'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            // Close the dialog
                                            Get.offAll(bidDetailsClient(projectId: projectIdAsInt));
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                Navigator.pop(context);
                              },
                              onCancel: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Payment canceled'),

                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            // Close the dialog
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                print('cancelled:');
                              },
                            ),
                          ),
                        );
                      })),
              SizedBox(
                height: 14,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Circular radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/icons/done.json', width: 120, height: 100),
            SizedBox(height: 16),
            Text(
              'Order Successfully Completed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
class AcceptProject {

  final String chat;



  AcceptProject({
    required this.chat,

  });

}
