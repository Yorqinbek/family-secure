import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/poster_help/post_helper.dart';

class ContactListPage extends StatefulWidget {
  final String childuid;
  const ContactListPage({super.key, required this.childuid});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic>? contacts;

  Future<void> _onRefresh() async {
    await Jiffy.setLocale('ru');
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'chuid': widget.childuid};

    String response = await post_helper_token(data, '/getchildcontacts', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      print(response_json);
      if (response_json['status']) {
        setState(() {
          contacts = response_json['contacts'];
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
        title: Text("Контакты"),
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  _refreshController.isRefresh || contacts == null
                      ? SizedBox()
                      : contacts!.isEmpty
                          ? Center(
                              child: Text("Пустой"),
                            )
                          : Expanded(
                              child: ListView.builder(
                                  itemCount: contacts!.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> call_list =
                                        contacts![index];
                                    return ListTile(
                                      // leading: Icon(Icons.person),
                                      title: Text(
                                        call_list['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      trailing: Text(
                                          Jiffy.parse(call_list['time']).from(
                                              Jiffy.parse(
                                                  DateTime.now().toString()))),
                                      // leading: Icon(
                                      //   Icons.call_missed_outgoing,
                                      //   color: Colors.red,
                                      //   size: 20,
                                      // ),
                                      subtitle: Text(
                                        call_list['address'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onTap: () async {
                                        // Navigator.of(context).push(MaterialPageRoute(
                                        //     builder: (context) => SmsInfoPage()));
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
      ),
    );
  }
}
