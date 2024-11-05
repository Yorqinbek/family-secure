import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/add_child.dart';
import 'package:soqchi/screen/add_child_name.dart';
import 'package:soqchi/child_info.dart';
import 'package:soqchi/login.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'dart:convert';

import 'package:soqchi/screen/settings.dart';

class ChildListPage extends StatefulWidget {
  const ChildListPage({super.key});

  @override
  State<ChildListPage> createState() => _ChildListPageState();
}

class _ChildListPageState extends State<ChildListPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var token = '';
  List<dynamic>? childs;

  int subscribe = -1;

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

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
            setState(() {
              subscribe = 0;
            });
          } else {
            setState(() {
              subscribe = 1;
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

  Future<PermissionStatus> _getCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      return result;
    } else {
      return status;
    }
  }

  Future<PermissionStatus> _getlocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      final result = await Permission.location.request();
      return result;
    } else {
      return status;
    }
  }

  // final FirebaseAuth auth = FirebaseAuth.instance;
  // final User? user = await auth.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Family Secure",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsPage()));
            },
            icon: Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: Container(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Мои дети",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 0.03,
                // ),
                subscribe == -1
                    ? SizedBox()
                    : subscribe == 0
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                "Срок подписки истек.\nСвяжитесь с администратором!",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ),
                          )
                        : _refreshController.isRefresh || childs == null
                            ? SizedBox()
                            : childs!.isEmpty
                                ? Center(
                                    child: Text("Пустой"),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                        itemCount: childs!.length,
                                        itemBuilder: (context, index) {
                                          Map<String, dynamic> child =
                                              childs![index];
                                          return Container(
                                            color: Colors.white,
                                            margin: EdgeInsets.only(
                                                left: 10, right: 10, top: 8),
                                            child: ListTile(
                                              leading: Icon(Icons.person),
                                              title: Text(
                                                child['name'] ?? 'No name',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(child['uid']),
                                              trailing:
                                                  Icon(Icons.navigate_next),
                                              onTap: () async {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChildInfoPage(
                                                              childuid: child[
                                                              'uid'],
                                                              chname: child[
                                                              'name'] ??
                                                                  'No name',
                                                            )));
                                                // PermissionStatus status =
                                                //     await _getlocationPermission();
                                                // if (status.isGranted) {
                                                //   Navigator.of(context).push(
                                                //       MaterialPageRoute(
                                                //           builder: (context) =>
                                                //               ChildInfoPage(
                                                //                 childuid: child[
                                                //                     'uid'],
                                                //                 chname: child[
                                                //                         'name'] ??
                                                //                     'No name',
                                                //               )));
                                                // }
                                              },
                                            ),
                                          );
                                        }),
                                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          PermissionStatus status = await _getCameraPermission();
          if (status.isGranted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AddChildName(),
            ));
          }
        },
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
