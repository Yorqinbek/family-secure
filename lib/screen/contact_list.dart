import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childcontact/child_contact_bloc.dart';
import 'package:soqchi/poster_help/post_helper.dart';

import '../widgets/EmptyListWidget.dart';
import '../widgets/loadingwidget.dart';
import '../widgets/upgradewidget.dart';

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
  final _scrollController = ScrollController();
  Timer? _debounce;
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
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<ChildContactBloc>(context).add(GetChildContactEvent(childuid: widget.childuid));
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
        BlocProvider.of<ChildContactBloc>(context).add(GetChildContactEvent(childuid: widget.childuid));
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
        child: BlocBuilder<ChildContactBloc, ChildContactState>(
  builder: (context, state) {
    switch (state.status) {
      case ChildContact.loading:
        return LoadingWidget();
      case ChildContact.success:
        if (state.contacts.isEmpty) {
          return EmptyListWidget();
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.islast
                          ? state.contacts.length
                          : state.contacts.length + 1,
                      itemBuilder: (context, index) {
                      return index >= state.contacts.length
                      ? LoadingWidget()
                          : ListTile(
                          // leading: Icon(Icons.person),
                          title: Text(
                            state.contacts[index].name.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person,color: Colors.white,),
                        ),
                          trailing: Text(
                              Jiffy.parse(state.contacts[index].time.toString()).from(
                                  Jiffy.parse(
                                      DateTime.now().toString()))),
                          // leading: Icon(
                          //   Icons.call_missed_outgoing,
                          //   color: Colors.red,
                          //   size: 20,
                          // ),
                          subtitle: Text(
                            state.contacts[index].address.toString(),
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
        );
      case ChildContact.error:
        return Center(
          child: Text(state.errorMessage),
        );
      case ChildContact.expired:
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
