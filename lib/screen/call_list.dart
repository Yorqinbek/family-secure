import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childcall/child_call_bloc.dart';
import 'package:soqchi/poster_help/post_helper.dart';

import '../components/dialogs.dart';
import '../widgets/EmptyListWidget.dart';
import '../widgets/loadingwidget.dart';
import '../widgets/upgradewidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class CallListPage extends StatefulWidget {
  final String childuid;
  const CallListPage({super.key, required this.childuid});

  @override
  State<CallListPage> createState() => _CallListPageState();
}

class _CallListPageState extends State<CallListPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _scrollController = ScrollController();
  Timer? _debounce;
  List<dynamic>? calls;

  formattedTime(int timeInSecond) {
    int sec = timeInSecond % 60;
    print(sec);
    int min = (timeInSecond / 60).floor();
    if (min.toString().contains("0") && !min.toString().contains("0")) {
      return "-";
    } else if (!min.toString().contains("0")) {
      return "$min min $sec sec";
    } else {
      return "$sec sec";
    }
  }

  Future<void> _onRefresh() async {
    // BlocProvider.of<ChildCallBloc>(context).add(ChildCallLoadingData(childuid: widget.childuid));

    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<ChildCallBloc>(context).add(ReloadChildCallEvent(childuid: widget.childuid,date: _selectedDate.toString()));
    _scrollController.addListener(_onScroll);
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
      BlocProvider.of<ChildCallBloc>(context).add(ReloadChildCallEvent(childuid: widget.childuid,date: _selectedDate.toString()));
      // print(_selectedDate.toString());
    });
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
        BlocProvider.of<ChildCallBloc>(context).add(GetChildCallEvent(childuid: widget.childuid,date: _selectedDate.toString()));
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
        // centerTitle: true, // this is all you need
        title: Text(AppLocalizations.of(context)!.calls,),
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
        child: BlocBuilder<ChildCallBloc, ChildCallState>(
          builder: (context, state) {
            switch (state.status) {
              case ChildCall.loading:
                return LoadingWidget();
              case ChildCall.success:
                if (state.calls.isEmpty) {
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
                                  ? state.calls.length
                                  : state.calls.length + 1,
                              itemBuilder: (context, index) {
                                return index >= state.calls.length
                                    ? LoadingWidget()
                                    : ListTile(
                                  // leading: Icon(Icons.person),
                                  title: Text(
                                    state.calls[index].address.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  trailing: Text(
                                      Jiffy.parse( state.calls[index].time.toString(),).from(
                                          Jiffy.parse(
                                              DateTime.now().toString()))),
                                  // leading: Icon(
                                  //   state.calls[index].type == 0 ?
                                  //   Icons.call_received : state.calls[index].type == 1 ? Icons.call_made :state.calls[index].type == 2 ? Icons.call_received : Icons.call,
                                  //   color:  state.calls[index].type == 4 ?  Colors.red : Colors.green,
                                  //   size: 20,
                                  // ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.person,color: Colors.white,),
                                  ),
                                  subtitle: Row(
                                    children: [
                                    Icon(
                                      state.calls[index].type == 0 ?
                                      Icons.call_received : state.calls[index].type == 1 ? Icons.call_made :state.calls[index].type == 2 ? Icons.call_received : Icons.call,
                                      color:  state.calls[index].type == 4 ?  Colors.red : Colors.green,
                                      size: 20,
                                    ),
                                      Icon(
                                        color: Colors.blue,
                                        Icons.timer_sharp,
                                        size: 18,
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        formattedTime(
                                            state.calls[index].duration!),
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
                );
              case ChildCall.error:
                return Center(
                  child: Text(state.errorMessage),
                );
              case ChildCall.expired:
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
