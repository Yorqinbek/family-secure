import 'dart:async';
import 'dart:convert';

import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childsmsinfo/child_sms_info_bloc.dart';
import 'package:soqchi/poster_help/post_helper.dart';

import '../widgets/EmptyListWidget.dart';
import '../widgets/loadingwidget.dart';

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
  final _scrollController = ScrollController();
  Timer? _debounce;
  List<dynamic>? messages;

  Future<void> _onRefresh() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'sender': widget.sender, 'chuid': widget.childuid};

    String response =
        await post_helper_token(data, '/getchildsendermsg', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<ChildSmsInfoBloc>(context).add(GetChildSmsInfoEvent(childuid: widget.childuid,sender: widget.sender));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_isNearBottom()) {
        BlocProvider.of<ChildSmsInfoBloc>(context).add(GetChildSmsInfoEvent(childuid: widget.childuid,sender: widget.sender));
      }
    });
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent == 0) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
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
        child: BlocBuilder<ChildSmsInfoBloc, ChildSmsInfoState>(
        builder: (context, state) {

          switch (state.status) {
            case ChildSmsInfo.loading:
              return LoadingWidget();
            case ChildSmsInfo.success:
              if (state.messages.isEmpty) {
                return EmptyListWidget();
              }
              return Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.islast
                              ? state.messages.length
                              : state.messages.length + 1,
                          itemBuilder: (context, index) {
                            return index >= state.messages.length
                                ? LoadingWidget()
                                : Column(
                              children: [
                                DateChip(
                                  date: DateTime.parse(state.messages[index].time.toString()),
                                  color: Color(0x558AD3D5),
                                ),
                                state.messages[index].isMe!
                                    ? BubbleSpecialThree(
                                  text: state.messages[index].body.toString(),
                                  color: Color(0xFF1B97F3),
                                  tail: false,
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16),
                                )
                                    : BubbleSpecialThree(
                                  text: state.messages[index].body.toString(),
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
              );
            case ChildSmsInfo.error:
              return Center(
                child: Text(state.errorMessage),
              );
          }
  },
),
      ),
    );
  }
}
