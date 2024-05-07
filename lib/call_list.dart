import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/poster_help/post_helper.dart';

class CallListPage extends StatefulWidget {
  final String childuid;
  const CallListPage({super.key, required this.childuid});

  @override
  State<CallListPage> createState() => _CallListPageState();
}

class _CallListPageState extends State<CallListPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic>? calls;

  formattedTime(int timeInSecond) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "$min" : "$min";
    String second = sec.toString().length <= 1 ? "$sec" : "$sec";
    if (minute.toString().contains("0") && !second.toString().contains("0")) {
      return "-";
    } else if (!minute.toString().contains("0")) {
      return "$minute min $second sec";
    } else {
      return "$second sec";
    }
  }

  Future<void> _onRefresh() async {
    await Jiffy.setLocale('ru');
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'chuid': widget.childuid};

    String response = await post_helper_token(data, '/getchildcalls', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      print(response_json);
      if (response_json['status']) {
        setState(() {
          calls = response_json['calls'];
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
        title: Text("Звонки"),
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
                  _refreshController.isRefresh || calls == null
                      ? SizedBox()
                      : calls!.isEmpty
                          ? Center(
                              child: Text("Пустой"),
                            )
                          : Expanded(
                              child: ListView.builder(
                                  itemCount: calls!.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> call_list =
                                        calls![index];
                                    return ListTile(
                                      // leading: Icon(Icons.person),
                                      title: Text(
                                        call_list['address'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      trailing: Text(
                                          Jiffy.parse(call_list['time']).from(
                                              Jiffy.parse(
                                                  DateTime.now().toString()))),
                                      leading: Icon(
                                        call_list['type'] == 0 ?
                                        Icons.call_received : call_list['type'] == 1 ? Icons.call_made : call_list['type'] == 2 ? Icons.call_received : Icons.call,
                                        color:  call_list['type'] == 4 ?  Colors.red : Colors.green,
                                        size: 20,
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            size: 15,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            formattedTime(
                                                call_list['duration']),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
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
