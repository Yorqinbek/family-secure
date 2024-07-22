import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childnotif/child_notification_bloc.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'package:soqchi/widgets/EmptyListWidget.dart';
import 'package:soqchi/widgets/loadingwidget.dart';
import 'package:soqchi/widgets/upgradewidget.dart';

import '../components/dialogs.dart';
class NotificationListPage extends StatefulWidget {
  final String childuid;
  const NotificationListPage({super.key,required this.childuid});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _scrollController = ScrollController();
  List<dynamic>? notif;
  Timer? _debounce;

  Future<void> _onRefresh() async {
    BlocProvider.of<ChildNotificationBloc>(context).add(GetChildNotificationEvent(childuid: widget.childuid,date: _selectedDate.toString()));

    _refreshController.refreshCompleted();
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<ChildNotificationBloc>(context).add(GetChildNotificationEvent(childuid: widget.childuid,date: _selectedDate.toString()));
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
        BlocProvider.of<ChildNotificationBloc>(context).add(GetChildNotificationEvent(childuid: widget.childuid,date: _selectedDate.toString()));
      }
    });
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent == 0) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
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
      BlocProvider.of<ChildNotificationBloc>(context).add(ReloadChildNotificationEvent(childuid: widget.childuid,date: _selectedDate.toString()));
      // print(_selectedDate.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true, // this is all you need
        title: Text("Уведомления"),
        actions: [
          TextButton(
            onPressed: _pickDateDialog,
            child: Text(
              Jiffy.parse(_selectedDate.toString())
                  .yMMMMd,
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          // IconButton(onPressed: _pickDateDialog, icon: Icon(Icons.date_range,color: Colors.blue,))
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
      ),
      body: SafeArea(
        child: BlocBuilder<ChildNotificationBloc,ChildNotificationState>(
          builder: (ctx, state) {
            switch (state.status) {
              case ChildNotification.loading:
                return LoadingWidget();
              case ChildNotification.success:
                if (state.notification!.isEmpty) {
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
                                  ? state.notification!.length
                                  : state.notification!.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                Image? image;
                                if(state.notification!.length > index ){

                                  if(state.notification![index].img !=null ){
                                    String base64String = state.notification![index].img!;

                                    String singleLineString = base64String.replaceAll('\n', '');
                                    Uint8List bytes = base64Decode(singleLineString);
                                    image = Image.memory(bytes,height: 25,);
                                  }
                                }

                                return index >= state.notification!.length
                                  ? LoadingWidget()
                                    :  Column(
                                  children: [
                                    ListTile(
                                      // leading: Icon(Icons.person),
                                      title: Text(

                                        state.notification![index].name.toString(),
                                        style: TextStyle(

                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        maxLines: 1,
                                      ),
                                      trailing: Text(
                                        Jiffy.parse( state.notification![index].time.toString()).from(
                                            Jiffy.parse(
                                                DateTime.now().toString())),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      leading: image==null ? Icon(Icons.notifications,color: Colors.blue,size: 30,) : image,
                                      // leading: Text(state.notification[index].id.toString()),
                                      subtitle: Text(
                                        state.notification![index].text.toString(),
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
                );
              case ChildNotification.error:
                return Center(
                  child: Text(state.errorMessage),
                );
              case ChildNotification.expired:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UpgradeWidget(),
                  ],
                );
            }
            // if (state.status){
            //   return SmartRefresher(
            //     onRefresh: _onRefresh,
            //     controller: _refreshController,
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Container(
            //         child: Column(
            //           children: [
            //             SizedBox(
            //               height: MediaQuery.of(context).size.height * 0.03,
            //             ),
            //             Expanded(
            //               child: ListView.builder(
            //                   controller: _scrollController,
            //                   itemCount:state.data!.length,
            //                   itemBuilder: (context, index) {
            //                     Image? image;
            //                     if(state.data![index].img !=null ){
            //                       String base64String = state.data![index].img!;
            //
            //                       String singleLineString = base64String.replaceAll('\n', '');
            //                       Uint8List bytes = base64Decode(singleLineString);
            //                       image = Image.memory(bytes,height: 25,);
            //                     }
            //
            //                     return Column(
            //                       children: [
            //                         ListTile(
            //                           // leading: Icon(Icons.person),
            //                           title: Text(
            //
            //                             state.data![index].name.toString(),
            //                             style: TextStyle(
            //
            //                                 fontWeight: FontWeight.bold,
            //                                 fontSize: 14),
            //                             maxLines: 1,
            //                           ),
            //                           trailing: Text(
            //                             Jiffy.parse( state.data![index].time.toString()).from(
            //                                 Jiffy.parse(
            //                                     DateTime.now().toString())),
            //                             style: TextStyle(
            //                                 fontWeight: FontWeight.bold,
            //                                 fontSize: 14),
            //                           ),
            //                           leading: image==null ? Icon(Icons.notifications) : image,
            //                           subtitle: Text(
            //                             state.data![index].text.toString(),
            //                             style: TextStyle(
            //
            //                                 fontSize: 12),
            //                           ),
            //                           onTap: () async {
            //                             // Navigator.of(context).push(MaterialPageRoute(
            //                             //     builder: (context) => SmsInfoPage()));
            //                             // PermissionStatus status =
            //                             //     await _getlocationPermission();
            //                             // if (status.isGranted) {
            //                             //   Navigator.of(context).push(
            //                             //       MaterialPageRoute(
            //                             //           builder: (context) =>
            //                             //               ChildInfoPage()));
            //                             // }
            //                           },
            //                         ),
            //                         Divider()
            //                       ],
            //                     );
            //                   }),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   );
            // }
            // if(state is ChildNotificationError){
            //   return MyCustomDialogs.server_conn_err();
            // }
            // return Align(
            //   child: Center(
            //     child: Text("Загрузка...",style: TextStyle(fontSize: 16),),
            //   ),
            //   alignment: Alignment.center,
            // );
          },
        ),
      ),
    );
  }
}
