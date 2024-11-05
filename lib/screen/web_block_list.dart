import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childwebblock/child_web_bloc.dart';

import '../components/dialogs.dart';
import '../poster_help/post_helper.dart';
import '../widgets/EmptyListWidget.dart';
import '../widgets/loadingwidget.dart';
import '../widgets/upgradewidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class WebBlockPage extends StatefulWidget {
  final String childuid;
  const WebBlockPage({super.key,required this.childuid});

  @override
  State<WebBlockPage> createState() => _WebBlockPageState();
}

class _WebBlockPageState extends State<WebBlockPage> {

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> add_website(String name,String website_url) async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'name': name, 'url': website_url,'chuid':widget.childuid};

    String response = await post_helper_token(data, '/addwebsite', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      if (response_json['status']) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> change_website(int website_id,bool block) async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'website_id': website_id, 'block': block};

    String response = await post_helper_token(data, '/changewebsite', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      if (response_json['status']) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  TextEditingController _controller_name = TextEditingController();
  TextEditingController _controller_url = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<ChildWebBloc>(context).add(GetChildWebEvent(childuid: widget.childuid));
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
        BlocProvider.of<ChildWebBloc>(context).add(GetChildWebEvent(childuid: widget.childuid));
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
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            color: Colors.blue,
              onPressed: (){
            showDialog(
              context: context,
              builder: (BuildContext context2) {
                _controller_name.text = "";
                _controller_url.text = "";
                return AlertDialog(

                  backgroundColor: Colors.white,
                  title: Text(AppLocalizations.of(context)!.web_dialog_title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _controller_name,
                        decoration: InputDecoration(
                          fillColor: Colors.blue,
                            label: Text(AppLocalizations.of(context)!.name),
                            hintText: "Google"
                        ),

                      ),
                      SizedBox(height: 5,),
                      TextField(
                        controller: _controller_url,
                        decoration: InputDecoration(
                            label: Text(AppLocalizations.of(context)!.web_url),
                            hintText: "www.google.com"),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.cancel,style: TextStyle(color: Colors.black),),
                      onPressed: () {
                        Navigator.of(context2).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Ok',style: TextStyle(color: Colors.black),),
                      onPressed: () async{
                        // You can process the input here or close the dialog
                        String name = _controller_name.text;
                        String url = _controller_url.text;
                        if(name.isNotEmpty && url.isNotEmpty){
                          Navigator.pop(context2);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  // <-- SEE HERE
                                  content: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                      )),
                                );
                              },
                            );
                            bool a = await add_website(name,url);
                            if(a){
                              _refreshController.requestRefresh();
                              Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context)!.added,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,

                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }
                            else{
                              Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context)!.server_error,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,

                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }
                            Navigator.pop(context);
                        }
                        else{
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.text_error,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,

                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );

                        }
                        // Optionally, you can show a Snackbar or process the input in some way
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('Hello, $enteredName!')),
                        // );
                      },
                    ),
                  ],
                );
              },
            );
          }, icon: Icon(Icons.add,color: Colors.blue,size: 22,))
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.web),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SmartRefresher(
          onRefresh: (){
            BlocProvider.of<ChildWebBloc>(context).add(ReloadChildWebEvent(childuid: widget.childuid));
            _refreshController.refreshCompleted();
            },
          controller: _refreshController,
          child: BlocBuilder<ChildWebBloc, ChildWebState>(
  builder: (context, state) {
      switch (state.status) {
        case ChildWeb.loading:
          return LoadingWidget();
        case ChildWeb.success:
          if (state.websites.isEmpty) {
            return EmptyListWidget();
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                controller: _scrollController,
                itemCount: state.islast
                    ? state.websites.length
                    : state.websites.length + 1,
                itemBuilder: (context, index) {
                  return index >= state.websites.length
                      ? LoadingWidget()
                      : ListTile(
                    leading: Icon(
                      Icons.language, color: Colors.blue, size: 24,),
                    title: Text(state.websites[index].name.toString(), style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),),
                    subtitle: Text(
                      state.websites[index].url.toString(), style: TextStyle(fontSize: 14),),
                    trailing: CircleAvatar(
                      radius: 20,
                      backgroundColor: state.websites[index].block! ? Colors.red : Colors.blue,
                      child: IconButton(onPressed: () async{
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.transparent,
                              // <-- SEE HERE
                              content: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  )),
                            );
                          },
                        );
                        bool a = await change_website(state.websites[index].id!, !state.websites[index].block!);
                        if(a){
                          setState(() {
                            state.websites[index].block = !state.websites[index].block!;
                          });
                        }
                        else{
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.server_error,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,

                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                        Navigator.of(context).pop();
                      },
                        icon: state.websites[index].block! ? Icon(
                          Icons.lock_outline, color: Colors.white,) : Icon(
                          Icons.lock_open, color: Colors.white,),),
                    ),
                  );
                }
            ),
          );
        case ChildWeb.error:
          return Center(
            child: Text(state.errorMessage),
          );
        case ChildWeb.expired:
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
      ),
    );
  }
}
