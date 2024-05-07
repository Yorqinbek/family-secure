import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/poster_help/post_helper.dart';
class NotificationListPage extends StatefulWidget {
  final String childuid;
  const NotificationListPage({super.key,required this.childuid});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  RefreshController _refreshController =
  RefreshController(initialRefresh: true);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic>? notif;

  Future<void> _onRefresh() async {
    await Jiffy.setLocale('ru');
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'chuid': widget.childuid};

    String response = await post_helper_token(data, '/getchildnotif', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      print(response_json);
      if (response_json['status']) {
        setState(() {
          notif = response_json['notif'];
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
        title: Text("Уведомления"),
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
                  _refreshController.isRefresh || notif == null
                      ? SizedBox()
                      : notif!.isEmpty
                      ? Center(
                    child: Text("Пустой"),
                  )
                      : Expanded(
                    child: ListView.builder(
                        itemCount: notif!.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> notif_list =
                          notif![index];
                          Image? image;
                          if(notif_list['img']!=null){
                            String base64String = notif_list['img'];
                            // String base64String = "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";

                            // print(base64String);
                            String singleLineString = base64String.replaceAll('\n', '');
                            Uint8List bytes = base64Decode(singleLineString);
                            image = Image.memory(bytes,height: 25,);
                          }

                          return Column(
                            children: [
                              ListTile(
                                // leading: Icon(Icons.person),
                                title: Text(

                                  notif_list['name'],
                                  style: TextStyle(

                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                  maxLines: 1,
                                ),
                                trailing: Text(
                                    Jiffy.parse(notif_list['time']).from(
                                        Jiffy.parse(
                                            DateTime.now().toString())),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                leading: image==null ? Icon(Icons.notifications) : image,
                                subtitle: Text(
                                  notif_list['text'],
                                  style: TextStyle(

                                      fontSize: 12),
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
                              ),
                              Divider()
                            ],
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
