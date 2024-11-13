import 'package:deep_waste/components/profile_menu.dart';
import 'package:deep_waste/constants/app_properties.dart';
import 'package:deep_waste/database_manager.dart';
import 'package:deep_waste/models/User.dart';
import 'package:deep_waste/screens/HomeScreen.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  static String routeName = "/settings_screen";
  final User user;
  const SettingsScreen({Key? key, required this.user}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  late String titsle;
  final String lorelEpsum = 'This is great product ...';
  late ExpandableController controller;

  @override
  void initState() {
    super.initState();
    controller = ExpandableController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future removeUser(userId) async {
    await DatabaseManager.instance.deleteUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
        ),
        backgroundColor: white,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              ProfileMenu(
                text: "Help Center",
                icon: "assets/icons/Question mark.svg",
                press: () async {
                  var facebookUrl = "http://m.me/momsstorenepal";
                  await canLaunchUrl(facebookUrl as Uri)
                      ? launchUrl(facebookUrl as Uri)
                      : print(
                          "open facebook app link or do a snackbar with notification that there is no facebook installed");
                },
              ),

              // Replace 'canLaunch' with 'canLaunchUrl' and 'launch' with 'launchUrl'
              ProfileMenu(
                text: "Help Center",
                icon: "assets/icons/Question mark.svg",
                press: () async {
                  var facebookUrl = Uri.parse("http://m.me/momsstorenepal");
                  if (await canLaunchUrl(facebookUrl)) {
                    await launchUrl(facebookUrl);
                  } else {
                    print(
                        "open facebook app link or do a snackbar with notification that there is no facebook installed");
                  }
                },
              ),

              ProfileMenu(
                  text: "Delete Account",
                  icon: "assets/icons/Log out.svg",
                  press: () async {
                    await removeUser(widget.user.id);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen(title: '',)));
                  })
            ],
          ),
        ));
  }
}
