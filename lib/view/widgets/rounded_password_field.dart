import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'text_field_container.dart';


class RoundedPasswordField extends StatelessWidget {
  const RoundedPasswordField({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: true,
        cursorColor: HexColor('#4D8D6E'),
         decoration:  InputDecoration(
            icon: Icon(
              Icons.lock,
              color: HexColor('#292929'),
            ),
            hintText: "Password",
            hintStyle:  TextStyle(fontFamily: 'OpenSans'),
            suffixIcon: Icon(
              Icons.visibility,
              color: HexColor('#292929'),
            ),
            border: InputBorder.none),
      ),
    );
  }
}