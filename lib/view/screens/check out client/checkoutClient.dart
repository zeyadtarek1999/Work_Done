import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:workdone/view/screens/check%20out%20client/payment.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';
import 'package:workdone/view/screens/check%20out%20client/paypal%20checkout.dart';
import 'package:workdone/view/widgets/rounded_button.dart';

import '../homescreen/home screenClient.dart';

class checkOutClient extends StatefulWidget {
  const checkOutClient({super.key});

  @override
  State<checkOutClient> createState() => _checkOutClientState();
}


class _checkOutClientState extends State<checkOutClient> {
  int _currentIndex = 0;
  int selectedValue = 1;

  CarouselController _carouselController = CarouselController();
  List<CarouselItem> items = [
    CarouselItem(cardNumber: '1234', cardHolder: 'John Doe', expires: '12/23'),
    CarouselItem(cardNumber: '5678', cardHolder: 'Jane Smith', expires: '11/24'),
    CarouselItem(cardNumber: '9876', cardHolder: 'Alice Johnson', expires: '10/25'),
  ];

// Define a function to handle item selection
  void handleItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Use items[_currentIndex] to access the selected item's data
    print('Selected Item: ${items[_currentIndex].cardNumber}');
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
          onPressed: () {},
          icon: Icon(
            Icons.arrow_back_sharp,
            color: HexColor('1A1D1E'),
            size: 27,
          ),
        ),
        toolbarHeight: 67,
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 27,right: 23,left: 23,bottom: 5),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HexColor('FFFFFF'),
                  border: Border(
                    bottom: BorderSide(
                      color: HexColor('D8D8D8'), // Specify the color of the bottom border
                      width: 1.0,          // Specify the width of the bottom border
                    ),
                  ),),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text('Your Address',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: HexColor('424347'),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 14,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('202 Wayne St, ',
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
                              activeColor: HexColor('4D8D6E'), // Hex color 4D8D6E
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
                        Text('Durand, MI, 48429',
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
                    SizedBox(height: 7,),
                    TextButton(onPressed: (){}, child: Text('Change',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: HexColor('4D8D6E'),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),)


                  ],
                ),

              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Row(
                children: [
                  Text('Select Your Card',style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: HexColor('424347'),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ),
                  Spacer(),
                  Text('+', style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: HexColor('4D8D6E'),
                      fontSize: 19,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  ),
                  TextButton(onPressed: (){Get.to(CreditCardPage());},child: Text('Add New Card', style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: HexColor('4D8D6E'),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ),),



                ],
              ),
            ),
            SizedBox(height: 12,),
            CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index, int realIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CarouselItemWidget(
                    item: items[index],
                    borderRadius: BorderRadius.circular(26),
                    isSelected: _currentIndex == index,
                    onItemSelected: () => handleItemSelected(index),
                  ),
                );
              },
              options: CarouselOptions(
                height: 220,
                aspectRatio: 16 / 8,
                viewportFraction: 0.85,
                enableInfiniteScroll: true,

                autoPlay: false,
                enlargeFactor: 89,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: items.map((item) {
                  int itemIndex = items.indexOf(item);
                  return CircularIndicator(
                    itemIndex: itemIndex,
                    currentIndex: _currentIndex,
                  );
                }).toList(),
              ),
            ),            SizedBox(height: 20,),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Container(
                height: 1, // Set the height to control the thickness of the line
                color: HexColor('D8D8D8'),// Set the color of the line
              ),
            )
,
            SizedBox(height: 13,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27.0),
              child: Column(
                children: [
                  Row(children: [
                    Text('Project',style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('3E3E3E'),
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    ),
                    Spacer(),
                    Text('28',style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('3E3E3E'),
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    ),

                    SizedBox(width: 2,),

                    Text('\$',style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('3E3E3E'),
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    ),

                  ],
                  ),
                  SizedBox(height: 10,),
                  Row(children: [
                    Text('Fees',style: GoogleFonts.roboto(
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
                        iconSize: 17, // Set the desired icon size
                        icon: Icon(Icons.info_outline, color: HexColor('4D8D6E')), // Use the 'info' icon
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
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        color: HexColor('4D8D6E'), // Set the 'Close' button color
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
                    Text('3',style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('3E3E3E'),
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    ),
                    SizedBox(width: 2,),
                    Text('\$',style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('3E3E3E'),
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    ),

                  ],),
                  SizedBox(height: 10,),

                  Row(children: [
                    Text('Total',style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('3E3E3E'),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ),
                    Spacer(),
                    Text('31',style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('3E3E3E'),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ),SizedBox(width: 2,),

                    Text('\$',style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: HexColor('3E3E3E'),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ),

                  ],),
                  Center(
                    child: Text('(What you will pay) ',style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('9A9D9C'),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12,),
Center(child: RoundedButton(text: 'Pay Now', press: (){
 // Close the dialog
Get.to(CheckoutPage());
})),
SizedBox(height: 14,)

          ],
        ),
      ),
    );
  }
}
class CarouselItem {
  final String cardNumber;
  final String cardHolder;
  final String expires;
  bool isSelected;

  CarouselItem({
    required this.cardNumber,
    required this.cardHolder,
    required this.expires,
    this.isSelected = false, // Initialize isSelected as false by default
  });
}

class CarouselItemWidget extends StatefulWidget {
  final CarouselItem item;
  final BorderRadius borderRadius;
  final bool isSelected;
  final Function onItemSelected;

  CarouselItemWidget({
    required this.item,
    required this.borderRadius,
    required this.isSelected,
    required this.onItemSelected,
  });

  @override
  _CarouselItemWidgetState createState() => _CarouselItemWidgetState();
}

class _CarouselItemWidgetState extends State<CarouselItemWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isSelected) {
          widget.onItemSelected();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: widget.isSelected
              ? Border.all(
            color: HexColor('4D8D6E'),
            width: 4.0,
          )
              : null,
          image: DecorationImage(
            image: AssetImage('assets/images/cardbackground.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/icons/visa.svg',
                    width: 43.0,
                    height: 43.0,
                    color: Colors.white,
                  ),
                  Icon(
                    widget.isSelected ? Icons.check_circle : Icons.more_horiz,
                    color: widget.isSelected ? HexColor('4D8D6E') : Colors.grey[400],
                    size: 28.0,
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Number',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 7,),
                  Text(
                    ' ${widget.item.cardNumber}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                widget.item.cardHolder,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Expires ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.item.expires,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'CIB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
            Lottie.asset('assets/icons/done.json',width: 120,height: 100),

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