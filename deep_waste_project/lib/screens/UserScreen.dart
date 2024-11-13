import 'package:deep_waste/components/default_button.dart';
import 'package:deep_waste/components/form_error.dart';
import 'package:deep_waste/constants/app_properties.dart';
import 'package:deep_waste/constants/size_config.dart';
import 'package:deep_waste/database_manager.dart';
import 'package:deep_waste/models/User.dart';
import 'package:deep_waste/screens/HomeScreen.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  var _formKey = GlobalKey<FormState>();
  String title = '';  // Initialized to avoid null safety error
  final List<String> errors = [];

  void addError({required String error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({required String error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Future addUser() async {
    final user = User(
      name: title,
      id: 1001,
    );

    await DatabaseManager.instance.insertUser(user);
  }

  void validateAndSave() async {
    final FormState? form = _formKey.currentState;
    if (form != null && form.validate()) {
      await addUser();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(title: title)),
      );
    } else {
      print('Form is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Scaffold(
            backgroundColor: white,
            body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: getProportionateScreenHeight(75)),
                      SizedBox(height: getProportionateScreenHeight(25)),
                      Text(
                        "Create a username that can be used for identification",
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(18),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      buildUserName(),
                      FormError(errors: errors),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      DefaultButton(
                        text: "Create",
                        press: () async {
                          validateAndSave();
                        },
                      ),
                    ],
                  ),
                )))));
  }

  TextFormField buildUserName() {
    return TextFormField(
      keyboardType: TextInputType.text,
      onSaved: (newValue) => title = newValue ?? '', // Default if null
      onChanged: (value) {
        title = value;
        if (value.isNotEmpty) {
          removeError(error: kItemName);
        }
      },
      validator: (value) {
        if (value?.isEmpty ?? true) {
          addError(error: kItemName);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
