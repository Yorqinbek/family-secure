import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/login.dart';
import 'package:soqchi/poster_help/post_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // String user = '';

  Map<String, dynamic> user = {};

  Future<void> _onRefresh() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    // Map data = {'sender': widget.sender};

    String response = await get_helper('/getinfo');
    if (response != "Error") {
      final Map response_json = json.decode(response);
      if (response_json['status']) {
        setState(() {
          user = response_json['user'];
          print(user);
        });
      }
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
      print('response Error');
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text("Настройки"),
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
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                _refreshController.isRefresh || !user.containsKey('email')
                    ? SizedBox()
                    : Column(
                        children: [
                          Text(
                            user['name'].toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            user['email'].toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ListTile(
                            title: Text(
                              "#" + user!['id'].toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Мой ID"),
                          ),
                          ListTile(
                            title: Text(
                              user['tarif'] == 1
                                  ? "Start (30 дней)"
                                  : user['tarif'] == 2
                                      ? "Vip (365 дней)"
                                      : "Free (3 дней)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Подписка"),
                          ),
                          ListTile(
                            title: Text(
                              user.containsKey('exp_time') &&
                                      user['exp_time'] >= 0
                                  ? user['exp_time'].toString() +
                                      " дней осталось"
                                  : "Истекший",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: user.containsKey('exp_time') &&
                                          user['exp_time'] >= 0
                                      ? Colors.black
                                      : Colors.red),
                            ),
                            subtitle: Text("Время окончания"),
                          ),
                          ListTile(
                            title: Text(
                              user!['balance'].toString() + " сум",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Баланс"),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.telegram,
                              color: Colors.blue,
                            ),
                            title: Text(
                              "@soqchi_support",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Связаться с нами Telegram"),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Container(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () async {
                                  var signout = await signOutFromGoogle();
                                  // print(signout);
                                  if (signout) {
                                    final SharedPreferences prefs =
                                        await _prefs;
                                    prefs.setBool("regstatus", false);
                                    prefs.setString("email", "");
                                    prefs.setString("uid", "");
                                    prefs.setString('bearer_token', '');
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) {
                                      return LoginPage();
                                    }));
                                  }
                                },
                                child: Text("Выход",
                                    style: TextStyle(color: Colors.white))),
                          )
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
