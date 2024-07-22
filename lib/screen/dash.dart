import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pay/pay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soqchi/screen/add_child_name.dart';
import 'package:soqchi/bloc/childinfo/child_info_bloc.dart';
import 'package:soqchi/bloc/dash/dash_bloc.dart';
import 'package:soqchi/child_info.dart';
import 'package:soqchi/screen/child_information.dart';
import 'package:soqchi/home.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'package:soqchi/screen/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../payment/payment_configurations.dart';
import '../payment/purchase_bloc.dart';
import '../widgets/upgradewidget.dart';
import 'subscription.dart';
import '../widgets/loadingwidget.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<PermissionStatus> _getlocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      final result = await Permission.location.request();
      return result;
    } else {
      return status;
    }
  }

  @override
  void initState() {
    BlocProvider.of<DashBloc>(context).add(DashLoadingData());
    super.initState();
  }

  var token = '';
  List<dynamic>? childs;

  // Future<void> _onRefresh() async {
  //   print('keldi');
  //   final SharedPreferences prefs = await _prefs;
  //   setState(() {
  //     token = prefs.getString('bearer_token') ?? '';
  //   });
  //   if (token == '') {
  //     print("Token yoq");
  //     Map data = {
  //       'phone': prefs.getString('phone'),
  //       'password': prefs.getString('phone')
  //     };
  //     //login
  //     String response = await post_helper(data, '/login');
  //     print(response);
  //     if (response != "Error") {
  //       final Map response_json = json.decode(response);
  //       print("Login response:$response_json");
  //       if (response_json['status']) {
  //         prefs.setString('bearer_token', response_json['token']);
  //       }
  //       print("Yangi token:$response_json['token']");
  //       _refreshController.requestRefresh();
  //     } else {
  //       print('login response Error');
  //     }
  //   } else {
  //     print('/getchilds');
  //     String response = await get_helper('/getchilds');
  //     print(response);
  //     if (response != "Error") {
  //       final Map response_json = json.decode(response);
  //       if (response_json['status']) {
  //         if (response_json['message']
  //             .toString()
  //             .contains('Expired subscribe')) {
  //           // setState(() {
  //           //   subscribe = 0;
  //           // });
  //         } else {
  //           setState(() {
  //             // subscribe = 1;
  //             childs = response_json['childs'];
  //           });
  //         }
  //       }
  //     } else {
  //       print('getchilds response Error');
  //     }
  //   }
  //   _refreshController.refreshCompleted();
  // }

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text("FamilySecure",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,),),
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        SettingsPage())
            );
          }, icon: Icon(Icons.settings,color: Colors.blue,))
        ],
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.help,color:  Colors.blue,)),
      ),
      body: SafeArea(
        child: Material(
          color: Colors.white,
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: (){
              BlocProvider.of<DashBloc>(context).add(DashLoadingData());
              _refreshController.refreshCompleted();
            },
            child: CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        // color: Colors.grey[200],
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Card(
                            //     child: Column(
                            //       children: [
                            //         ListTile(
                            //           leading: Icon(Icons.lock,color: Colors.white,size: 30,),
                            //           title: Text("Bepul obuna tugadi",style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.bold),),
                            //         ),
                            //         Container(
                            //           height: 40,
                            //           decoration: BoxDecoration(
                            //             color: Colors.white,
                            //               border: Border.all(
                            //                 color: Colors.white,
                            //               ),
                            //               borderRadius: BorderRadius.all(Radius.circular(18))
                            //           ),
                            //           margin: EdgeInsets.all(15),
                            //           width: MediaQuery.of(context).size.width*0.9,
                            //           child: TextButton(
                            //               onPressed: (){
                            //                 Navigator.push(context, MaterialPageRoute(builder: (context) {
                            //                   return BlocProvider(
                            //                     create: (ctx) => PurchaseBloc(),
                            //                     child: ParentSubscribePage(
                            //                       // childuid: widget.childuid,
                            //
                            //                     ),
                            //                   );
                            //                 }));
                            //               },
                            //               child: Text("Yangilash",style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),)
                            //           ),
                            //         )
                            //       ],
                            //     ),
                            //     color: Colors.redAccent,
                            //   ),
                            // ),

                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                AppLocalizations.of(context)!.myfamily,
                                style: TextStyle(

                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ])),
                BlocBuilder<DashBloc, DashState>(
                  builder: (context, state) {
                    if (state is DashSuccess) {
                      return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: state.childList.length,
                                (context, index) {
                              return InkWell(
                                onTap: () async {
                                  PermissionStatus status =
                                  await _getlocationPermission();
                                  if (status.isGranted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      return BlocProvider(
                                        create: (ctx) => ChildInfoBloc(),
                                        child: ChildInformationPage(
                                          childuid: state.childList[index].uid.toString(),
                                          name: state.childList[index].name.toString() ?? "",
                                        ),
                                      );
                                    }));
                                    // Navigator.of(context).push(
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             ChildInformationPage(
                                    //               childuid: state.childList[index].uid.toString(),
                                    //               name: state.childList[index].name.toString() ?? "",
                                    //             )));
            
                                    // Navigator.of(context).push(
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             ChildInfoPage(
                                    //               childuid: child['uid'],
                                    //               chname: child['name'] ??
                                    //                   'No name',
                                    //             )));
                                  }
                                },
                                child: Card(
                                  shadowColor: Colors.blue,
                                  margin: EdgeInsets.only(
                                      left: 15, right: 15, top: 15),
                                  color: Colors.blue[50],
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              child: Icon(
                                                size: 25,
                                                Icons.verified_user,
                                                color: Colors.white,
                                              ),
                                              backgroundColor: Colors.blue,
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  state.childList[index].name.toString() ?? 'No name',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 22),
                                                ),
                                                Text(
                                                  "child",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 16),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.blue,
                                          child: Icon(
                                            Icons.navigate_next,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ));
                    }
                    if(state is DashError){
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(height: MediaQuery.of(context).size.height*0.3,),
                          Center(
                            child: Text("Ошибка подключения к серверу!",style: TextStyle(fontSize: 16),),
                          )
                        ]
                        )
                      );
                    }
                    if(state is DashEmpty){
                      return SliverList(
                          delegate: SliverChildListDelegate([
                            SizedBox(height: MediaQuery.of(context).size.height*0.3,),
                            Center(
                              child: Text("Пустой!",style: TextStyle(fontSize: 16),),
                            )
                          ]
                          )
                      );
                    }
                    if(state is DashExpired){
                      return SliverList(
                          delegate: SliverChildListDelegate([
                            SizedBox(height: MediaQuery.of(context).size.height*0.2,),
                            UpgradeWidget()
                          ]
                          )
                      );
                    }
                    return   SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(height: MediaQuery.of(context).size.height*0.3,),
                            LoadingWidget()
                        ]));
                  },
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BlocProvider(
              create: (ctx) => DashBloc(),
              child: AddChildName(),
            );
          }));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
