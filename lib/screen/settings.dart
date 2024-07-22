import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/language_settings.dart';
import 'package:soqchi/login.dart';
import 'package:soqchi/payment/purchase_bloc.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'package:soqchi/screen/subscription.dart';

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
  int lan_item = 0;

  Map<String, dynamic> user = {};

  Future<void> _onRefresh() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      lan_item = prefs.getInt('lan') ?? 0;
    });
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
      backgroundColor: Colors.white,
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
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                radius: 40,
                                child: Icon(Icons.person_2,size: 50,color: Colors.blue,),
                              ),
                              SizedBox(height: 15,),
                              Text(
                                user['name'].toString(),
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                user['email'].toString(),
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                "User id: "+user['id'].toString(),
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                              ),
                            ],
                          ),
                          // InkWell(
                          //   onTap: (){
                          //       Navigator.push(context, MaterialPageRoute(builder: (context) {
                          //         return BlocProvider(
                          //           create: (ctx) => PurchaseBloc(),
                          //           child: ParentSubscribePage(
                          //             // childuid: widget.childuid,
                          //
                          //           ),
                          //         );
                          //       }));
                          //   },
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Card(
                          //       child: Column(
                          //         children: [
                          //           ListTile(
                          //             trailing: Icon(Icons.lock,color: Colors.white,size: 20,),
                          //             title: Text("Current Plan",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                          //           ),
                          //           // ListTile(
                          //           //   // subtitle: Text(
                          //           //   //   user.containsKey('exp_time') &&
                          //           //   //       user['exp_time'] >= 0
                          //           //   //       ? user['exp_time'].toString() +
                          //           //   //       " дней осталось"
                          //           //   //       : "Истекший",
                          //           //   //   style: TextStyle(
                          //           //   //       fontWeight: FontWeight.bold,
                          //           //   //       fontSize: 19,
                          //           //   //       color: user.containsKey('exp_time') &&
                          //           //   //           user['exp_time'] >= 0
                          //           //   //           ? Colors.white
                          //           //   //           : Colors.red),
                          //           //   // ),
                          //           //   title: Text(      user['tarif'] == 1
                          //           //       ? "Start (30 дней)"
                          //           //       : user['tarif'] == 2
                          //           //       ? "Vip (365 дней)"
                          //           //       : "Free (3 дней)",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                          //           // ),
                          //           Padding(
                          //             padding: const EdgeInsets.all(10.0),
                          //             child: Text(      user['tarif'] == 1
                          //                 ? "Monthly"
                          //                 : user['tarif'] == 2
                          //                 ? "Yearly"
                          //                 : "Free (3 дней)",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
                          //           ),
                          //           // Container(
                          //           //   height: 40,
                          //           //   decoration: BoxDecoration(
                          //           //     color: Colors.white,
                          //           //       border: Border.all(
                          //           //         color: Colors.white,
                          //           //       ),
                          //           //       borderRadius: BorderRadius.all(Radius.circular(18))
                          //           //   ),
                          //           //   margin: EdgeInsets.all(15),
                          //           //   width: MediaQuery.of(context).size.width*0.9,
                          //           //   child: TextButton(
                          //           //       onPressed: (){
                          //           //         Navigator.push(context, MaterialPageRoute(builder: (context) {
                          //           //           return BlocProvider(
                          //           //             create: (ctx) => PurchaseBloc(),
                          //           //             child: ParentSubscribePage(
                          //           //               // childuid: widget.childuid,
                          //           //
                          //           //             ),
                          //           //           );
                          //           //         }));
                          //           //       },
                          //           //       child: Text("Yangilash",style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),)
                          //           //   ),
                          //           // )
                          //         ],
                          //       ),
                          //       color: Colors.blue,
                          //     ),
                          //   ),
                          // ),
                          ListTile(
                            leading: CircleAvatar(
                                child: Icon(Icons.subscriptions,color: Colors.blueAccent,),
                              backgroundColor: Colors.grey[100],
                            ),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return ParentSubscribePage(
                                  // childuid: widget.childuid,

                                );
                              }));
                            },
                            trailing: Icon(Icons.chevron_right_outlined),
                            subtitle: Text(
                              user['tarif'] == 1
                                  ? "Monthly"
                                  : user['tarif'] == 2
                                      ? "Yearly"
                                      : "Free (3 дней)",
                            ),
                            title: Text("Подписка",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),),
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.language,color: Colors.blueAccent,),
                              backgroundColor: Colors.grey[200],
                            ),
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LanguageSettings()));
                            },
                            trailing: Icon(Icons.chevron_right_outlined),
                            title: Text(
                              "Language",
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19,),
                            ),
                            subtitle: Text(
                                lan_item == 0 ? "Eng" : lan_item == 1?"Uz":"Ru"
                            ),
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.support_agent,color: Colors.blueAccent,),
                              backgroundColor: Colors.grey[200],
                            ),
                            onTap: (){
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => LanguageSettings()));
                            },
                            trailing: Icon(Icons.chevron_right_outlined),
                            title: Text(
                              "Support",
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19,),
                            ),
                            subtitle: Text(
                               "24/7"
                            ),
                          ),
                          // ListTile(
                          //   leading: CircleAvatar(
                          //     child: Icon(Icons.warning,color: Colors.blueAccent,),
                          //     backgroundColor: Colors.grey[200],
                          //   ),
                          //   title: Text(
                          //     user.containsKey('exp_time') &&
                          //             user['exp_time'] >= 0
                          //         ? user['exp_time'].toString() +
                          //             " дней осталось"
                          //         : "Истекший",
                          //     style: TextStyle(
                          //         fontWeight: FontWeight.bold,
                          //         fontSize: 19,
                          //         color: user.containsKey('exp_time') &&
                          //                 user['exp_time'] >= 0
                          //             ? Colors.black
                          //             : Colors.red),
                          //   ),
                          //   subtitle: Text("Время окончания"),
                          // ),
                          user['subscribe_type'] == 0 ?
                          SizedBox():
                          ListTile(
                            title: Text(
                              user!['balance'].toString() + " сум",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Баланс"),
                          ),
                          // ListTile(
                          //   title: Text(
                          //     "#" + user!['id'].toString(),
                          //     style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),
                          //   ),
                          //   subtitle: Text("Мой ID"),
                          // ),
                          // ListTile(
                          //   leading: Icon(
                          //     Icons.telegram,
                          //     color: Colors.blue,
                          //   ),
                          //   title: Text(
                          //     "@soqchi_support",
                          //     style: TextStyle(fontWeight: FontWeight.bold),
                          //   ),
                          //   subtitle: Text("Связаться с нами Telegram"),
                          // ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                          ),

                          Container(
                              width: MediaQuery.of(context).size.width *
                                  0.4,
                              height:
                              MediaQuery.of(context).size.height *
                                  0.056,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                 backgroundColor: MaterialStateProperty.all(
                                       Colors.redAccent),
                                  // overlayColor: MaterialStateProperty.all(
                                  //     Colors.red),
                                  // backgroundColor: MaterialStateProperty.all(
                                  //     Colors.red),
                                  // backgroundColor: next_btn == true
                                  //     ? MaterialStateProperty.all(
                                  //         Colors.blueAccent)
                                  //     : MaterialStateProperty.all(
                                  //         Colors.grey),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // radius of the corners
                                    ),
                                  ),
                                ),
                                // onPressed: next_btn == true
                                //     ? () => send_phone(phone_number)
                                //     : () {},
                                onPressed: () async{
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
                                child: Text(
                                  "Выход",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                              )),
                          // Container(
                          //   child: ElevatedButton(
                          //       style: ElevatedButton.styleFrom(
                          //           backgroundColor: Colors.red),
                          //       onPressed: () async {
                          //         var signout = await signOutFromGoogle();
                          //         // print(signout);
                          //         if (signout) {
                          //           final SharedPreferences prefs =
                          //               await _prefs;
                          //           prefs.setBool("regstatus", false);
                          //           prefs.setString("email", "");
                          //           prefs.setString("uid", "");
                          //           prefs.setString('bearer_token', '');
                          //           Navigator.pushReplacement(context,
                          //               MaterialPageRoute(builder: (context) {
                          //             return LoginPage();
                          //           }));
                          //         }
                          //       },
                          //       child: Text("Выход",
                          //           style: TextStyle(color: Colors.white))),
                          // )
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
