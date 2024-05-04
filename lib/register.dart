import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/childs_list.dart';
import 'package:soqchi/components/dialogs.dart';
import 'package:soqchi/dash.dart';
import 'package:soqchi/poster_help/post_helper.dart';

class RegisterPage extends StatefulWidget {
  final String phone_number;
  const RegisterPage({super.key, required this.phone_number});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _nameController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> register() async {
    MyCustomDialogs.my_showAlertDialog(context);
    final SharedPreferences prefs = await _prefs;
    Map data = {
      'name': _nameController.text.toString(),
      'phone': widget.phone_number,
      'password': widget.phone_number
    };
    var response = await post_helper(data, '/register');
    if (response != "Error") {
      Navigator.pop(context);
      final Map response_json = json.decode(response);

      if (response_json['status']) {
        prefs.setBool("regstatus", true);
        prefs.setString("phone", widget.phone_number);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return DashboardPage();
        }));
      } else {
        MyCustomDialogs.error_network(context);
      }
    } else {
      Navigator.pop(context);
      MyCustomDialogs.error_network(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "Ismingiz va Familiyangiz",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: new BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 5, bottom: 5),
                                  child: TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText:
                                              "Misol uchun: Anvar Saidaliyev"
                                          // labelText: 'Email',
                                          ))))),
                    ],
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blueAccent),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // radius of the corners
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_nameController.text.isEmpty) {
                            MyCustomDialogs.my_infodialog(
                                context, "Barcha maydonlarni to'ldiring!");
                          } else {
                            register();
                          }
                        },
                        child: Text(
                          "Yakunlash",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )),
                ]),
          ),
        ));
  }
}
