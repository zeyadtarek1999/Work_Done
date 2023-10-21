import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';

class CreditCardPage extends StatefulWidget {
  const CreditCardPage({Key? key}) : super(key: key);

  @override
  _CreditCardPageState createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
bool     isCardNumberVisible= true ;

String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,

        elevation: 3,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Get.back;
            }),
        title: Text('Payment',style: GoogleFonts.openSans(
          textStyle: TextStyle(color: HexColor('212121'), fontSize: 21,fontWeight: FontWeight.w600),
        ),),
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          CreditCardWidget(
            cardBgColor: HexColor('F2547A'),
            cardType: CardType.visa,
            bankName: 'WorkDone',
            customCardTypeIcons: [],
            backgroundImage: 'assets/images/cardbackground.jpg',
            obscureInitialCardNumber: true,
            isHolderNameVisible: true,
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            obscureCardNumber: isCardNumberVisible,
            obscureCardCvv: false,
            onCreditCardWidgetChange: (CreditCardBrand) {},
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                CreditCardForm(

                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  onCreditCardModelChange: onCreditCardModelChange,
                  themeColor: HexColor('4D8D6E'),
                  formKey: formKey,
                 cardNumberDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Set the border radius here
                    ),
                    labelText: 'Card Number',
                    hintText: 'xxxx xxxx xxxx xxxx',
                   suffixIcon: IconButton(icon: Icon(isCardNumberVisible ? Icons.visibility : Icons.visibility_off)

    ,onPressed: (){setState(() {
                       isCardNumberVisible = !isCardNumberVisible; // Toggle visibility
                     });},)
                  ),
                  expiryDateDecoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Set the border radius here
                      ),
                      labelText: 'Expired Date',
                      hintText: 'xx/xx'),
                  cvvCodeDecoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Set the border radius here
                      ),
                      labelText: 'CVV',
                      suffixIcon: Icon(Ionicons.alert_circle_outline),
                      hintText: 'xxx'),
                  cardHolderDecoration: InputDecoration(
                    focusColor: HexColor('4D8D6E'),
                    fillColor: HexColor('4D8D6E'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Set the border radius here
                    ),
                    labelText: 'Card Holder',
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Set the border radius here
                      ),
                      labelText: 'Preferred Card Name (optional)',
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30.0), // Set the border radius here
                        ),
                        primary: Color(
                            0xFF4D8D6E), // Set the background color to 4D8D6E
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 35,
                        margin: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Add Card',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              package: 'flutter_credit_card',
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (cvvCode.length != 3) {
                          Fluttertoast.showToast(
                            msg: 'CVV must be 3 characters long',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        } else {
                          if (formKey.currentState!.validate()) {
                            print('valid');
                          } else {
                            print('inValid');
                          }
                        }
                      }),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
