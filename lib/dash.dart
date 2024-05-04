import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/add_child_name.dart';
import 'package:soqchi/child_info.dart';
import 'package:soqchi/child_information.dart';
import 'package:soqchi/home.dart';
import 'package:soqchi/poster_help/post_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<PermissionStatus> _getlocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      final result = await Permission.location.request();
      return result;
    } else {
      return status;
    }
  }

  var token = '';
  List<dynamic>? childs;
  Future<void> _onRefresh() async {
    print('keldi');
    final SharedPreferences prefs = await _prefs;
    setState(() {
      token = prefs.getString('bearer_token') ?? '';
    });
    if (token == '') {
      print("Token yoq");
      Map data = {
        'phone': prefs.getString('phone'),
        'password': prefs.getString('phone')
      };
      //login
      String response = await post_helper(data, '/login');
      print(response);
      if (response != "Error") {
        final Map response_json = json.decode(response);
        print("Login response:$response_json");
        if (response_json['status']) {
          prefs.setString('bearer_token', response_json['token']);
        }
        print("Yangi token:$response_json['token']");
        _refreshController.requestRefresh();
      } else {
        print('login response Error');
      }
    } else {
      print('/getchilds');
      String response = await get_helper('/getchilds');
      print(response);
      if (response != "Error") {
        final Map response_json = json.decode(response);
        if (response_json['status']) {
          if (response_json['message']
              .toString()
              .contains('Expired subscribe')) {
            // setState(() {
            //   subscribe = 0;
            // });
          } else {
            setState(() {
              // subscribe = 1;
              childs = response_json['childs'];
            });
          }
        }
      } else {
        print('getchilds response Error');
      }
    }
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Material(
          color: Colors.grey[200],
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _refreshController.isRefresh || childs == null
                ? SizedBox()
                : childs!.isEmpty
                    ? Center(
                        child: Text("Bo'sh"),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverList(
                              delegate: SliverChildListDelegate([
                            Container(
                              // color: Colors.grey[200],
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      "Mening Oilam",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ])),
                          SliverList(
                              delegate: SliverChildBuilderDelegate(
                            childCount: childs!.length,
                            (context, index) {
                              Map<String, dynamic> child = childs![index];
                              return InkWell(
                                onTap: () async {
                                  PermissionStatus status =
                                      await _getlocationPermission();
                                  if (status.isGranted) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChildInformationPage(
                                                  childuid: child['uid'],
                                                  name: child['name'],
                                                )));

                                    // Navigator.of(context).push(
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             ChildInfoPage(
                                    //               childuid: child['uid'],
                                    //               chname: child['name'] ??
                                    //                   'No name',
                                    //             )));
                                  }
                                },
                                child: Card(
                                  shadowColor: Colors.grey,
                                  margin: EdgeInsets.only(
                                      left: 15, right: 15, top: 15),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              child: Icon(
                                                size: 25,
                                                Icons.image,
                                                color: Colors.white,
                                              ),
                                              backgroundColor: Colors.blue,
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  child['name'] ?? 'No name',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  "o'g'lim",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.blue,
                                          child: Icon(
                                            Icons.navigate_next,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ))
                        ],
                      ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent[200],
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddChildName()));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
