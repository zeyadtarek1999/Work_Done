import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workdone/view/widgets/rounded_button.dart';

import '../view profile screens/Client profile view.dart';
import '../view profile screens/Worker profile view.dart';
import 'Place a Bid.dart';

class bidDetailsWorker extends StatefulWidget {
  const bidDetailsWorker({super.key});

  @override
  State<bidDetailsWorker> createState() => _bidDetailsWorkerState();
}

class _bidDetailsWorkerState extends State<bidDetailsWorker> {
  final List<Item> items = [
    Item(WorkerName: 'Mahmoud', Money: '22', rate: '4.5'),
    Item(WorkerName: 'Hossam', Money: '30', rate: '3.8'),
    Item(WorkerName: 'John', Money: '25', rate: '4.2'),
    Item(WorkerName: 'Mohamed', Money: '9', rate: '4.1'),
    Item(WorkerName: 'Mohamed', Money: '10', rate: '4.1'),
    // Add more items as needed
  ];
  String currentbid = '24';
  bool sortLowest = true;

  void updateCurrentBid() {
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
  void initState() {
    super.initState();

    // Set currentbid to the lowest Money value when the page opens
    updateCurrentBid();
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
      backgroundColor: HexColor('FAF9F9'),
      appBar: AppBar(
        backgroundColor: HexColor('FAF9F9'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        toolbarHeight: 67,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_sharp),
          color: Colors.black,
        ),
        title: Text(
          'Bid Details',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: HexColor('454545'),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 210.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        image: DecorationImage(
                          image: AssetImage('assets/images/testimage.jpg'),
                          // Replace with your image URL
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
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
                        ),
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
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        'Wall Paint',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('454545'),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              AssetImage('assets/images/profileimage.png'),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        TextButton(onPressed: () { Get.to(ProfilePageClient()); },
                            child: Text(
                              'John ',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: HexColor('43745C'),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            )
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
                                color: Colors.grey.withOpacity(0.5),
                                // Color of the shadow
                                spreadRadius: 2,
                                // Spread radius
                                blurRadius: 3,
                                // Blur radius
                                offset: Offset(
                                    0, 2), // Offset in the x and y direction
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
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                      child: Text(
                        'Description',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('454545'),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
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
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            'Workers Bids',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('454545'),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
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
                    SizedBox(
                      height: 17,
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),

                      shrinkWrap: true,
                      itemCount: items.length,
                      // Replace with the actual length of your data list
                      itemBuilder: (context, index) {
                        return buildListItem(items[
                            index]); // Pass the Item object to the buildListItem function
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            decoration: BoxDecoration(
              color: Colors.white, // Adjust the color as needed

              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Adjust the color as needed
                  spreadRadius: 0.6, // Spread radius
                  blurRadius: 7, // Blur radius
                  offset: Offset(0,
                      -2), // Offset in the y direction to create a top shadow
                ),
              ],
            ),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Container(
                  height: 58,
                  width: double.infinity,
                  // Set the width to match the parent width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    // Adjust the radius as needed
                    color: HexColor('4D8D6E'), // Use the desired hex color
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(Placebid());
                      },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      // Make the button transparent
                      elevation: MaterialStateProperty.all(0),
                      // Remove elevation
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12.0), // Same radius as above
                        ),
                      ),
                    ),
                    child: Text(
                      'Place A Bid',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget buildListItem(Item item) {
    bool isMoneyLessOrEqual =
        double.parse(item.Money) <= double.parse(currentbid);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('assets/images/profileimage.png'),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () { Get.to(ProfilePageWorker()); },
                    child:  Text(
                      item.WorkerName,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('9DA2A3'),
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.star,
                    color: HexColor('F3ED51'),
                    size: 20,
                  ),
                  SizedBox(width: 2),
                  Text(item.rate),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\$',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('353B3B'),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    item.Money,
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
          Spacer(),
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
          ),        ],
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
