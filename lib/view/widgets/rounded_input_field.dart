import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  const RoundedInputField({Key? key, this.hintText, this.icon = Icons.person})
      : super(key: key);
  final String? hintText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        cursorColor: Colors.white,
        decoration: InputDecoration(
            icon: Icon(
              icon,
              color: HexColor('#292929'),
            ),
            hintText: hintText,
            border: InputBorder.none),
      ),
    );
  }
}
