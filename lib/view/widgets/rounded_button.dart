import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    Key? key,
    required this.text,
    required this.press,
    this.textColor = Colors.white,
    this.loading = false, // Add loading parameter with default value
  }) : super(key: key);

  final String text;
  final Function() press;
  final Color? textColor;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: newElevatedButton(),
      ),
    );
  }

  Widget newElevatedButton() {
    return ElevatedButton(
      child: loading // Show loading indicator if loading is true
          ? CircularProgressIndicator() // Replace this with your custom loading widget if desired
          : Text(
        text,
        style: TextStyle(color: textColor, fontSize: 17),
      ),
      onPressed: loading ? null : press, // Disable button during loading
      style: ElevatedButton.styleFrom(
       backgroundColor: HexColor('#4D8D6E'),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        textStyle: TextStyle(
          letterSpacing: 2,
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
