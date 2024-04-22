import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'package:soqchi/sms_info.dart';

class SmsListPage extends StatefulWidget {
  final String childuid;
  const SmsListPage({super.key, required this.childuid});

  @override
  State<SmsListPage> createState() => _SmsListPageState();
}

class _SmsListPageState extends State<SmsListPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  var token = '';
  List<dynamic>? sms;

  Future<void> _onRefresh() async {
    await Jiffy.setLocale('ru');
    final SharedPreferences prefs = await _prefs;
    setState(() {
      token = prefs.getString('bearer_token') ?? '';
    });
    Map data = {'chuid': widget.childuid};

    String response = await post_helper_token(data, '/getchildsms', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      if (response_json['status']) {
        setState(() {
          sms = response_json['sms'];
        });
      }
    } else {
      print('response Error');
    }

    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text("Сообщения"),
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
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                _refreshController.isRefresh || sms == null
                    ? SizedBox()
                    : sms!.isEmpty
                        ? Center(
                            child: Text("Пустой"),
                          )
                        : Expanded(
                            child: ListView.builder(
                                itemCount: sms!.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> sms_list = sms![index];
                                  return ListTile(
                                    // leading: Icon(Icons.person),
                                    leading: CircleAvatar(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                      backgroundColor: Colors.grey,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          sms_list['address'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          // From X
                                          Jiffy.parse(sms_list['time']).from(
                                              Jiffy.parse(
                                                  DateTime.now().toString())),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(sms_list['body']),
                                    // trailing: Icon(Icons.navigate_next),
                                    onTap: () async {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => SmsInfoPage(
                                                    sender: sms_list['address'],
                                                    childuid: widget.childuid,
                                                  )));
                                      // PermissionStatus status =
                                      //     await _getlocationPermission();
                                      // if (status.isGranted) {
                                      //   Navigator.of(context).push(
                                      //       MaterialPageRoute(
                                      //           builder: (context) =>
                                      //               ChildInfoPage()));
                                      // }
                                    },
                                  );
                                }),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
