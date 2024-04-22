import 'dart:convert';

import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/poster_help/post_helper.dart';

class SmsInfoPage extends StatefulWidget {
  final String sender;
  final String childuid;
  const SmsInfoPage({super.key, required this.sender, required this.childuid});

  @override
  State<SmsInfoPage> createState() => _SmsInfoPageState();
}

class _SmsInfoPageState extends State<SmsInfoPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic>? messages;

  Future<void> _onRefresh() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'sender': widget.sender, 'chuid': widget.childuid};

    String response =
        await post_helper_token(data, '/getchildsendermsg', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      print(response_json);
      if (response_json['status']) {
        setState(() {
          messages = response_json['messages'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text(widget.sender),
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
                _refreshController.isRefresh || messages == null
                    ? SizedBox()
                    : messages!.isEmpty
                        ? Center(
                            child: Text("Пустой"),
                          )
                        : Expanded(
                            child: ListView.builder(
                                itemCount: messages!.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> msg_list =
                                      messages![index];
                                  return Column(
                                    children: [
                                      DateChip(
                                        date: DateTime.parse(msg_list['time']),
                                        color: Color(0x558AD3D5),
                                      ),
                                      msg_list['is_me']
                                          ? BubbleSpecialThree(
                                              text: msg_list['body'],
                                              color: Color(0xFF1B97F3),
                                              tail: false,
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            )
                                          : BubbleSpecialThree(
                                              text: msg_list['body'],
                                              color: Color(0xFFE8E8EE),
                                              isSender: false,
                                              tail: false,
                                              textStyle:
                                                  TextStyle(fontSize: 16),
                                            ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                    ],
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
