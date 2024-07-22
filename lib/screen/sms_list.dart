import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childsms/child_sms_bloc.dart';
import 'package:soqchi/bloc/childsmsinfo/child_sms_info_bloc.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'package:soqchi/screen/sms_info.dart';
import 'package:soqchi/widgets/EmptyListWidget.dart';

import '../components/dialogs.dart';
import '../widgets/loadingwidget.dart';
import '../widgets/upgradewidget.dart';

class SmsListPage extends StatefulWidget {
  final String childuid;
  const SmsListPage({super.key, required this.childuid});

  @override
  State<SmsListPage> createState() => _SmsListPageState();
}

class _SmsListPageState extends State<SmsListPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _scrollController = ScrollController();
  Timer? _debounce;
  Future<void> _onRefresh() async {
    BlocProvider.of<ChildSmsBloc>(context).add(GetChildSmsEvent(childuid: widget.childuid));

    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<ChildSmsBloc>(context).add(GetChildSmsEvent(childuid: widget.childuid));
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
        BlocProvider.of<ChildSmsBloc>(context).add(GetChildSmsEvent(childuid: widget.childuid));
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
        child: BlocBuilder<ChildSmsBloc, ChildSmsState>(
        builder: (context, state) {
          switch (state.status) {
            case ChildSms.loading:
              return LoadingWidget();
            case ChildSms.success:
              if (state.sms.isEmpty) {
                return EmptyListWidget();
              }
              return Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.islast
                              ? state.sms.length
                              : state.sms.length + 1,
                          itemBuilder: (context, index) {
                            return index >= state.sms.length
                                ? LoadingWidget()
                                : ListTile(
                              // leading: Icon(Icons.person),
                              leading: CircleAvatar(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.blue,
                              ),
                              title: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.sms[index].address.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    // From X
                                    Jiffy.parse(state.sms[index].time.toString()).from(
                                        Jiffy.parse(
                                            DateTime.now().toString())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              subtitle: Text(state.sms[index].body.toString()),
                              // trailing: Icon(Icons.navigate_next),
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return BlocProvider(
                                    create: (ctx) => ChildSmsInfoBloc(),
                                    child: SmsInfoPage(
                                      sender: state.sms[index].address.toString(),
                                      childuid: widget.childuid,
                                    ),
                                  );
                                }));
                              },
                            );
                          }),
                    ),
                  ],
                ),
              );
            case ChildSms.error:
              return Center(
                child: Text(state.errorMessage),
              );
            case ChildSms.expired:
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UpgradeWidget(),
                ],
              );
          }
  },
),
      ),
    );
  }
}
