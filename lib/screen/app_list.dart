import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childapp/child_app_list_bloc.dart';
import 'package:soqchi/bloc/childappusage/child_app_usage_bloc.dart';
import 'package:soqchi/components/dialogs.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'dart:convert';

import '../widgets/EmptyListWidget.dart';
import '../widgets/loadingwidget.dart';
import '../widgets/upgradewidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class AppListPage extends StatefulWidget {
  final String childuid;
  const AppListPage({super.key, required this.childuid});

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TabController? _tabController;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  final _scrollController = ScrollController();
  final _scrollController2 = ScrollController();
  Timer? _debounce;
  Timer? _debounce2;
  RefreshController _refreshController_app_usage = RefreshController(initialRefresh: false);

  var token = '';
  List<dynamic>? apps;
  List<dynamic>? apps_usage;
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    BlocProvider.of<ChildAppListBloc>(context).add(GetChildAppEvent(childuid: widget.childuid));
    BlocProvider.of<ChildAppUsageBloc>(context).add(GetChildAppUsageEvent(childuid: widget.childuid,date: _selectedDate.toString()));

    _scrollController.addListener(_onScroll);
    _scrollController2.addListener(_onScroll2);
    // _onRefresh();
    // _onRefresh_app_usage();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _scrollController2
      ..removeListener(_onScroll2)
      ..dispose();
    _debounce?.cancel();
    _debounce2?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_isNearBottom()) {
        BlocProvider.of<ChildAppListBloc>(context).add(GetChildAppEvent(childuid: widget.childuid));
      }
    });
  }

  void _onScroll2() {
    if (_debounce2?.isActive ?? false) _debounce2!.cancel();
    _debounce2 = Timer(const Duration(milliseconds: 300), () {
      if (_isNearBottom2()) {
        BlocProvider.of<ChildAppUsageBloc>(context).add(GetChildAppUsageEvent(childuid: widget.childuid,date: _selectedDate.toString()));
      }
    });
  }

  bool _isNearBottom2() {
    if (!_scrollController2.hasClients || _scrollController2.position.maxScrollExtent == 0) return false;
    final maxScroll = _scrollController2.position.maxScrollExtent;
    final currentScroll = _scrollController2.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent == 0) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
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

  Future<void> _onRefresh_app_usage() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'chuid': widget.childuid};

    String response = await post_helper_token(data, '/getchildappsusage', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);

      print(response_json);
      if (response_json['status']) {
        setState(() {
          apps_usage = response_json['apps_usage'];
        });
        _refreshController_app_usage.refreshCompleted();
      } else {
        _refreshController_app_usage.refreshCompleted();
      }
    } else {
      _refreshController_app_usage.requestRefresh();
      print('response Error');
    }
  }

  TimeOfDay? _selectedTime;

  DateTime _selectedDate = DateTime.now();

  void _pickDateDialog() {
    showDatePicker(
        builder:(context , child){
          return Theme(  data: Theme.of(context).copyWith(  // override MaterialApp ThemeData
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.black,
              ),
            ),
          ),  child: child!   );
        },
        keyboardType: TextInputType.datetime,
        context: context,

        initialDate: _selectedDate,
        //which date will display when user open the picker
        firstDate: DateTime(1950),
        //what will be the previous supported year in picker
        lastDate: DateTime
            .now()) //what will be the up to supported date in picker
        .then((pickedDate) {
      //then usually do the future job
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        //for rebuilding the ui
        _selectedDate = pickedDate;
      });
      BlocProvider.of<ChildAppUsageBloc>(context).add(ReloadChildAppUsageEvent(childuid: widget.childuid,date: _selectedDate.toString()));

      // BlocProvider.of<ChildNotificationBloc>(context).add(ReloadChildNotificationEvent(childuid: widget.childuid,date: _selectedDate.toString()));
      // print(_selectedDate.toString());
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text:AppLocalizations.of(context)!.app_list,),
              Tab(text: AppLocalizations.of(context)!.app_usage,)
            ],
          ),
          centerTitle: true, // this is all you need
          title: Text(AppLocalizations.of(context)!.apps),
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
        body: TabBarView(
          controller: _tabController,
          children: [
            SafeArea(
              child: BlocBuilder<ChildAppListBloc, ChildAppState>(
              builder: (context, state) {

                switch (state.status) {
                  case ChildApp.loading:
                    return LoadingWidget();
                  case ChildApp.success:
                    if (state.apps.isEmpty) {
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
                                      ? state.apps.length
                                      : state.apps.length + 1,
                                  itemBuilder: (context, index) {
                                    // = List.generate(5, (index) => false)
                                    Image? image;
                                    if(state.apps.length > index ){
                                      String base64String = state.apps[index].img.toString();

                                      // print(base64String);
                                      String singleLineString = base64String.replaceAll('\n', '');
                                      Uint8List bytes = base64Decode(singleLineString);
                                      image = Image.memory(bytes,height: 50,);
                                    }
                                    return index >= state.apps.length
                                        ? LoadingWidget()
                                        : ListTile(
                                      // leading: Icon(Icons.person),
                                      // leading: CircleAvatar(
                                      //   child: Icon(
                                      //     Icons.person,
                                      //     color: Colors.white,
                                      //   ),
                                      //   backgroundColor: Colors.grey,
                                      // ),
                                      subtitle: Text(AppLocalizations.of(context)!.app_limit +
                                          state.apps[index].blockTime.toString() +
                                          AppLocalizations.of(context)!.minut),
                                      // subtitle: LinearProgressIndicator(
                                      //   value: 50.0,
                                      //   color: Colors.blue,
                                      // ),
                                      leading: image,
                                      title: Text(
                                        state.apps[index].name.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      // subtitle: Text(sms_list['body']),
                                      trailing: Transform.scale(
                                        scale: 1,
                                        child: Switch(

                                          thumbIcon: MaterialStateProperty.resolveWith<Icon?>((Set<MaterialState> states) {
                                            if(states.contains(MaterialState.selected)){
                                              return const Icon(Icons.lock_outline,size: 20,color: Colors.white,);
                                            }
                                            else{
                                              return const Icon(Icons.lock_open_outlined,size: 20,color: Colors.white,);
                                            }
                                          }),
                                          inactiveThumbColor: Colors.black,
                                          inactiveTrackColor: Colors.grey,
                                          value: state.apps[index].block!,
                                          // splashRadius: 20.0,
                                          activeColor: Colors.red,
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
                                                hourLabelText: AppLocalizations.of(context)!.hour,
                                                helpText:
                                                AppLocalizations.of(context)!.hour_or_minut_limit,
                                                minuteLabelText: AppLocalizations.of(context)!.minut,
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
                                                int app_id = state.apps[index].id!;

                                                int block_time =
                                                    picked.hour * 60 +
                                                        picked.minute;

                                                bool block = value;

                                                var a = await change_app_limit(
                                                    app_id, block, block_time);
                                                if (a == true) {
                                                  setState(() {
                                                    state.apps[index].block = value;
                                                    state.apps[index].blockTime =
                                                        block_time;
                                                  });
                                                  Navigator.pop(context);
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              }
                                              else{
                                                Navigator.pop(context);
                                              }
                                            } else {
                                              int app_id = state.apps[index].id!;
                                              int block_time = 0;
                                              bool block = value;
                                              var a = await change_app_limit(
                                                  app_id, block, block_time);
                                              if (a == true) {
                                                setState(() {
                                                  state.apps[index].block = value;
                                                  state.apps[index].blockTime = 0;
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
                    );
                  case ChildApp.error:
                    return Center(
                      child: Text(state.errorMessage),
                    );
                  case ChildApp.expired:
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
            SafeArea(
              child: Column(
                children: [
                  TextButton(
                    onPressed: _pickDateDialog,
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.date,style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
                        Text(
                          Jiffy.parse(_selectedDate.toString())
                              .yMMMMd,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<ChildAppUsageBloc, ChildAppUsageState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case ChildAppUsage.loading:
                          return LoadingWidget();
                        case ChildAppUsage.success:
                          return Container(
                            child: ListView.builder(
                                controller: _scrollController2,
                                itemCount: state.islast
                                    ? state.apps.length
                                    : state.apps.length + 1,
                                itemBuilder: (context, index) {
                                  Image? image;
                                  int hours = 0;
                                  int minutes = 0;
                                  double utime = 0;
                                  if(state.apps.length > index ){
                                    utime = state.apps[index].usageTime == null ? 0.0 : state.apps[index].usageTime!.toDouble();
                                    if(utime>0){
                                      hours = (utime / 60).floor();
                                      minutes = ((utime / 60 - hours) * 60).round();
                                    }
                                    if(state.apps[index].img !=null ){
                                      String base64String = state.apps[index].img.toString();
                                      String singleLineString = base64String.replaceAll('\n', '');
                                      Uint8List bytes = base64Decode(singleLineString);
                                      image = Image.memory(bytes,height: 50,);
                                    }
                                  }


                                  return index >= state.apps.length
                                      ? LoadingWidget()
                                      : ListTile(
                                    subtitle: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10,),
                                        LinearProgressIndicator(
                                          minHeight: 8,
                                          value: utime*0.01,
                                          color: utime>50?utime<70?Colors.redAccent:Colors.red:Colors.blue,
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                            hours>0?hours.toString()+AppLocalizations.of(context)!.hour+" "+minutes.toString()+AppLocalizations.of(context)!.minut
                                            :minutes.toString()+AppLocalizations.of(context)!.minut),
                                      ],
                                    ),
                                    leading: image,
                                    title: Text(
                                      state.apps[index].name.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    // subtitle: Text(sms_list['body']),


                                    onTap: () async {
                                      // Navigator.of(context)
                                      //     .push(MaterialPageRoute(
                                      //         builder: (context) => SmsInfoPage(
                                      //               sender: sms_list['sender'],
                                      //             )));
                                    },
                                  );
                                }),
                          );
                        case ChildAppUsage.error:
                          return Center(
                            child: Text(state.errorMessage),
                          );
                        case ChildAppUsage.expired:
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
