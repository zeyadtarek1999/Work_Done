import 'package:flutter/material.dart';

class AddressForm extends StatefulWidget {
  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _addressLineController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();

  void _showAddressPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _addressLineController,
                decoration: InputDecoration(labelText: 'Address Line'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your address line';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State/Region'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your state/region';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the form data and close the bottom sheet
                    Navigator.pop(context);
                    // You can access the filled values using:
                    // _addressLineController.text
                    // _cityController.text
                    // _stateController.text
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}