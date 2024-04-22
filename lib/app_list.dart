import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/components/dialogs.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'dart:convert';

class AppListPage extends StatefulWidget {
  final String childuid;
  const AppListPage({super.key, required this.childuid});

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  var token = '';
  List<dynamic>? apps;
  List<bool> switchStates = [];

  Future<bool> change_app_limit(int app_id, bool block, int block_time) async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'app_id': app_id, 'block': block, 'block_time': block_time};

    String response = await post_helper_token(data, '/changeapplimit', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);

      print(response_json);
      if (response_json['status']) {
        return true;
      } else {
        MyCustomDialogs.error_dialog_custom(
            context, "Ошибка подключения к серверу. Попробуйте еще раз!");
        return false;
      }
    } else {
      MyCustomDialogs.error_dialog_custom(
          context, "Ошибка подключения к серверу. Попробуйте еще раз!");
      return false;
    }
  }

  Future<void> _onRefresh() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'chuid': widget.childuid};

    String response = await post_helper_token(data, '/getchildapps', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);

      print(response_json);
      if (response_json['status']) {
        setState(() {
          apps = response_json['apps'];
        });
        _refreshController.refreshCompleted();
      } else {
        _refreshController.refreshCompleted();
      }
    } else {
      _refreshController.requestRefresh();
      print('response Error');
    }
  }

  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text("Программы"),
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
                _refreshController.isRefresh || apps == null
                    ? SizedBox()
                    : apps!.isEmpty
                        ? Center(
                            child: Text("Пустой"),
                          )
                        : Expanded(
                            child: ListView.builder(
                                itemCount: apps!.length,
                                itemBuilder: (context, index) {
                                  // = List.generate(5, (index) => false)
                                  Map<String, dynamic> app_list = apps![index];
                                  // String base64String =
                                  //     app_list['img']; // Your Base64 string
                                  // Uint8List bytes = base64Decode(base64String);
                                  // Image image = Image.memory(bytes);
                                  return ListTile(
                                    // leading: Icon(Icons.person),
                                    // leading: CircleAvatar(
                                    //   child: Icon(
                                    //     Icons.person,
                                    //     color: Colors.white,
                                    //   ),
                                    //   backgroundColor: Colors.grey,
                                    // ),
                                    subtitle: Text("Дневной лимит: " +
                                        app_list['block_time'].toString() +
                                        " minut"),
                                    leading: Icon(Icons.add_circle_rounded),
                                    title: Text(
                                      app_list['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    // subtitle: Text(sms_list['body']),
                                    trailing: Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: Colors.grey,
                                        value: app_list['block'],
                                        // splashRadius: 20.0,
                                        activeColor: Colors.blue,
                                        // changes the state of the switch
                                        onChanged: (value) async {
                                          var load_dg = MyCustomDialogs
                                              .my_showAlertDialog(context);
                                          if (value == true) {
                                            final TimeOfDay? picked =
                                                await showTimePicker(
                                              context: context,
                                              initialEntryMode:
                                                  TimePickerEntryMode.inputOnly,
                                              hourLabelText: "час",
                                              helpText:
                                                  "Сколько час и минут блокировать?",
                                              minuteLabelText: "минут",
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                          alwaysUse24HourFormat:
                                                              true),
                                                  child: child!,
                                                );
                                              },
                                              initialTime: TimeOfDay(
                                                  hour: 0, minute: 00),
                                            );
                                            if (picked != null &&
                                                picked != _selectedTime) {
                                              setState(() {
                                                _selectedTime = picked;
                                              });
                                              int app_id = app_list['id'];

                                              int block_time =
                                                  picked.hour * 60 +
                                                      picked.minute;

                                              bool block = value;

                                              var a = await change_app_limit(
                                                  app_id, block, block_time);
                                              if (a == true) {
                                                setState(() {
                                                  app_list['block'] = value;
                                                  app_list['block_time'] =
                                                      block_time;
                                                });
                                                Navigator.pop(context);
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            }
                                          } else {
                                            int app_id = app_list['id'];
                                            int block_time = 0;
                                            bool block = value;
                                            var a = await change_app_limit(
                                                app_id, block, block_time);
                                            if (a == true) {
                                              setState(() {
                                                app_list['block'] = value;
                                                app_list['block_time'] = 0;
                                              });
                                              Navigator.pop(context);
                                            } else {
                                              Navigator.pop(context);
                                            }
                                          }
                                        },
                                      ),
                                    ),

                                    onTap: () async {
                                      // Navigator.of(context)
                                      //     .push(MaterialPageRoute(
                                      //         builder: (context) => SmsInfoPage(
                                      //               sender: sms_list['sender'],
                                      //             )));
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
