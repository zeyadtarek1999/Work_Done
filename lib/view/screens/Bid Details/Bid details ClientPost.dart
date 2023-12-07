import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workdone/view/screens/check%20out%20client/checkoutClient.dart';

import '../view profile screens/Worker profile view.dart';

class bidDetailsClientPost extends StatefulWidget {
  final int projectId;

  bidDetailsClientPost({required this.projectId});
  @override
  State<bidDetailsClientPost> createState() => _bidDetailsClientPostState();
}

class _bidDetailsClientPostState extends State<bidDetailsClientPost> {
  final List<Item> items = [
    Item(WorkerName: 'Mahmoud', Money: '22', rate: '4.5'),
    Item(WorkerName: 'Hossam', Money: '30', rate: '3.8'),
    Item(WorkerName: 'John', Money: '25', rate: '4.2'),
    Item(WorkerName: 'Mohamed', Money: '9', rate: '4.1'),
    Item(WorkerName: 'Mohamed', Money: '10', rate: '4.1'),
    // Add more items as needed
  ];
  String currentbid ='24';

  void updateCurrentbid() {
    // Find the lowest Money value among items
    double lowestMoney = double.infinity;
    for (Item item in items) {
      double money = double.parse(item.Money);
      if (money < lowestMoney) {
        lowestMoney = money;
      }
    }

    setState(() {
      currentbid = lowestMoney.toString();
    });
  }
  @override
  void initState() {
    super.initState();

    // Set currentbid to the lowest Money value when the page opens
    updateCurrentbid();
  }

  bool sortLowest = true;
// Sorting methods
  void sortLowestMoney() {
    items.sort((a, b) {
      double moneyA = double.parse(a.Money);
      double moneyB = double.parse(b.Money);
      return sortLowest ? moneyA.compareTo(moneyB) : moneyB.compareTo(moneyA);
    });
  }

  void sortHighestMoney() {
    items.sort((a, b) {
      double moneyA = double.parse(a.Money);
      double moneyB = double.parse(b.Money);
      return sortLowest ? moneyB.compareTo(moneyA) : moneyA.compareTo(moneyB);
    });
  }

  void sortLowestRate() {
    items.sort((a, b) {
      double rateA = double.parse(a.rate);
      double rateB = double.parse(b.rate);
      return sortLowest ? rateA.compareTo(rateB) : rateB.compareTo(rateA);
    });
  }

  void sortHighestRate() {
    items.sort((a, b) {
      double rateA = double.parse(a.rate);
      double rateB = double.parse(b.rate);
      return sortLowest ? rateB.compareTo(rateA) : rateA.compareTo(rateB);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('FFFFFF'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));

    return Scaffold(
      backgroundColor: HexColor('FFFFFF'),
appBar: AppBar(
  backgroundColor: HexColor('FFFFFF'),
  systemOverlayStyle:SystemUiOverlayStyle.dark,
  elevation: 0,toolbarHeight: 67,

  leading: IconButton(onPressed: (){Get.back();},icon:Icon( Icons.arrow_back_sharp),color: Colors.black,),
  title: Text ( 'Bid Details',
    style: GoogleFonts.roboto(
      textStyle: TextStyle(
        color: HexColor('454545'),
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  centerTitle: true ,
),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                height: 210.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  image: DecorationImage(
                    image: AssetImage('assets/images/testimage.jpg'), // Replace with your image URL
                    fit: BoxFit.cover,
                  ),
                ),
              ),
SizedBox(height: 12,),
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 60,
                    decoration: BoxDecoration(
                      color: HexColor('4D8D6E'),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'Wall',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: HexColor('FFFFFF'),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
,
                  Spacer(),
                  Icon(
                    Icons.access_time_rounded,
                    color: HexColor('777778'),
                    size: 18,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '22 min',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('777778'),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    'ago',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('777778'),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),


                ],
              ),
              SizedBox(height: 12,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text ('Wall Paint',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: HexColor('454545'),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2,),

              Row(

                children: [

                  CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                    AssetImage('assets/images/profileimage.png'),
                  ),
                  SizedBox(width: 13,),
                  Text('Ahmed',
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('454545'),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 75,
                    width: 130,
                    decoration: BoxDecoration(
                      color: HexColor('FFFFFF'),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Color of the shadow
                          spreadRadius: 2, // Spread radius
                          blurRadius: 3, // Blur radius
                          offset: Offset(0, 2), // Offset in the x and y direction
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Current Bid',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('898B8D'),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4,),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text(

                              currentbid,
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: HexColor('4D8D6E'),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '\$',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: HexColor('4D8D6E'),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )


                ],
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text ('Description',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: HexColor('454545'),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text ('Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: HexColor('706F6F'),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  children: [
                    Text ('Workers Bids',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('454545'),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.sort), // Change this icon
                      onSelected: (String value) {
                        setState(() {
                          if (value == 'lowestMoney') {
                            sortLowestMoney();
                          } else if (value == 'highestMoney') {
                            sortHighestMoney();
                          } else if (value == 'lowestRate') {
                            sortLowestRate();
                          } else if (value == 'highestRate') {
                            sortHighestRate();
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'lowestMoney',
                            child: Text('Sort by Lowest Money'),
                          ),
                          PopupMenuItem<String>(
                            value: 'highestMoney',
                            child: Text('Sort by Highest Money'),
                          ),
                          PopupMenuItem<String>(
                            value: 'lowestRate',
                            child: Text('Sort by Lowest Rate'),
                          ),
                          PopupMenuItem<String>(
                            value: 'highestRate',
                            child: Text('Sort by Highest Rate'),
                          ),
                        ];
                      },
                    ),

                  ],
                ),
              ),
              SizedBox(height: 17,),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),

                shrinkWrap: true,
                itemCount: items.length,
                // Replace with the actual length of your data list
                itemBuilder: (context, index) {
                  return buildListItem(items[index]); // Pass the Item object to the buildListItem function
                },
              ),




            ],
          ),
        ),
      ),

    );
  }
  Widget buildListItem(Item item) {
    bool isMoneyLessOrEqual = double.parse(item.Money) <= double.parse(currentbid);

    // Check if Money is less than currentbid, and update currentbid if needed

    return          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0 ,vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.transparent,
                backgroundImage:
                AssetImage('assets/images/profileimage.png'),
              ),
              SizedBox(width: 12,),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,


                      children: [
                        GestureDetector(
                          onTap: () { Get.to(ProfilePageWorker()); },
                         child:  Text(item.WorkerName,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('9DA2A3'),
                                fontSize: 17,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4,),
                        Icon(Icons.star,color: HexColor('F3ED51'),size: 20,),
                        SizedBox(width: 2,),
                        Text(item.rate),

                      ],
                    ),
                    SizedBox(height: 4,),
                    Row(
                      children: [
                        Text('\$',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              color: HexColor('353B3B'),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 3,),
                        Text(item.Money,
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              color: HexColor('353B3B'),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),




                  ],
                ),
              ),

              Spacer(),
              Container(
                width: 73,
                height: 30,
                decoration: BoxDecoration(
                  color: HexColor('4D8D6E'),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: ElevatedButton(
                  onPressed: ()  {Get.to(checkOutClient()); },
                  child: Text('Accept',style: TextStyle(fontSize: 13),),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent, // Make the button background transparent
                    elevation: 0, // Remove button elevation
                    textStyle: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
              ),
              SizedBox(width: 8,),
              isMoneyLessOrEqual
                  ? SvgPicture.asset(
                'assets/icons/arrowdown.svg',
                width: 39.0,
                height: 39.0,
              )
                  : SvgPicture.asset(
                'assets/icons/arrowup.svg',
                width: 39.0,
                height: 39.0,
              ),
            ],
          ),

    );
  }
}
class Item {
  final String WorkerName;
  final String Money;
  final String rate;

  Item({
    required this.WorkerName,
    required this.Money,
    required this.rate,
  });
}
