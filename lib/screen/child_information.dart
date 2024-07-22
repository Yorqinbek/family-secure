import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childapp/child_app_list_bloc.dart';
import 'package:soqchi/bloc/childappusage/child_app_usage_bloc.dart';
import 'package:soqchi/screen/app_list.dart';
import 'package:soqchi/bloc/childcall/child_call_bloc.dart';
import 'package:soqchi/bloc/childcontact/child_contact_bloc.dart';
import 'package:soqchi/bloc/childlocation/child_location_list_bloc.dart';
import 'package:soqchi/bloc/childnotif/child_notification_bloc.dart';
import 'package:soqchi/bloc/childsms/child_sms_bloc.dart';
import 'package:soqchi/screen/call_list.dart';
import 'package:soqchi/screen/contact_list.dart';
import 'package:soqchi/screen/location_list.dart';
import 'package:soqchi/screen/notif_list.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'package:soqchi/screen/sms_list.dart';
import 'package:soqchi/widgets/upgradewidget.dart';

import '../bloc/childinfo/child_info_bloc.dart';
import '../widgets/loadingwidget.dart';

class ChildInformationPage extends StatefulWidget {
  final String childuid;
  final String name;
  const ChildInformationPage(
      {super.key, required this.childuid, required this.name});

  @override
  State<ChildInformationPage> createState() => _ChildInformationPageState();
}

class _ChildInformationPageState extends State<ChildInformationPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng _center = LatLng(double.parse('41.3279503'), double.parse('69.34076'));

  GoogleMapController? controller;

  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
      // controller!.setMapStyle(sty);
    });
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  var token = '';
  var counts;

  int active_index = 0;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChildInfoBloc>(context).add(ChildInfoLoadingData(childuid: widget.childuid));

    // _onRefresh();
  }

  // Future<void> _onRefresh() async {
  //   final SharedPreferences prefs = await _prefs;
  //   String token = prefs.getString('bearer_token') ?? '';
  //   Map data = {'chid': widget.childuid};
  //
  //   String response = await post_helper_token(data, '/getchildinfo', token);
  //
  //   if (response != "Error") {
  //     final Map response_json = json.decode(response);
  //     if (response_json['status']) {
  //       if (response_json['loc'] != null) {
  //         final bitmapIcon = await BitmapDescriptor.fromAssetImage(
  //             ImageConfiguration(size: Size(64, 64)),
  //             'assets/images/location_blue.png');
  //         List<Placemark> placemarks = await placemarkFromCoordinates(
  //             double.parse(response_json['loc']['lat']),
  //             double.parse(response_json['loc']['lon']));
  //         Placemark place = placemarks[0]; // Taking the first returned result
  //         print(
  //             "Qani:${place.locality}, ${place.postalCode}, ${place.country}");
  //         setState(() {
  //           counts = response_json['counts'];
  //           _center = LatLng(double.parse(response_json['loc']['lat']),
  //               double.parse(response_json['loc']['lon']));
  //           final marker = Marker(
  //             markerId: MarkerId("initial_marker"),
  //             position: _center,
  //             icon: bitmapIcon,
  //             infoWindow: InfoWindow(
  //                 title: "${place.locality}, ${place.name}, ${place.country}",
  //                 snippet: "${response_json['loc']['time']}"),
  //           );
  //           setState(() {
  //             _markers["initial_marker"] = marker;
  //           });
  //         });
  //       } else {
  //         print('lokatsiya yoq');
  //       }
  //     }
  //   } else {
  //     print('response Error');
  //   }
  //
  //   // await Jiffy.setLocale('ru');
  //   // final SharedPreferences prefs = await _prefs;
  //   // String token = prefs.getString('bearer_token') ?? '';
  //
  //   // Map data = {'chuid': widget.childuid};
  //
  //   // String response =
  //   //     await post_helper_token(data, '/getchildlocations', token);
  //   // if (response != "Error") {
  //   //   final Map response_json = json.decode(response);
  //   //   if (response_json['status']) {
  //   //     setState(() {
  //   //       locations = response_json['locations'];
  //   //     });
  //   //     if (locations != null && !locations!.isEmpty) {
  //   //       Map<String, dynamic> location_list = locations![0];
  //   //       setState(() {
  //   //         _center = LatLng(double.parse(location_list['lat']),
  //   //             double.parse(location_list['lon']));
  //   //         final marker = Marker(
  //   //           markerId: MarkerId("initial_marker"),
  //   //           position: _center,
  //   //           infoWindow: InfoWindow(
  //   //               title: "Initial Marker", snippet: "An interesting location"),
  //   //         );
  //   //         setState(() {
  //   //           _markers["initial_marker"] = marker;
  //   //         });
  //   //       });
  //   //     }
  //   //   }
  //   // } else {
  //   //   print('response Error');
  //   // }
  //
  //   _refreshController.refreshCompleted();
  // }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true, // this is all you need
        title: Text(
          widget.name,
        ),
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
      body:SafeArea(
        child: BlocBuilder<ChildInfoBloc, ChildInfoState>(
          builder: (ctx, state)  {
            if(state is ChildInfoSuccess){
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: GoogleMap(
                      circles: state.circles,
                      tiltGesturesEnabled: true,
                      myLocationEnabled: true,

                      // zoomControlsEnabled: true,
                      mapToolbarEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse("${state.childInfoModel.loc?.lat}"),
                            double.parse("${state.childInfoModel.loc?.lon}")),
                        zoom: 15.0,
                      ),
                      mapType: MapType.terrain,
                      markers: {
                         state.marker
                      },
                      myLocationButtonEnabled: false,
                      onMapCreated: _onMapCreated,
                      gestureRecognizers: Set()
                        ..add(Factory<PanGestureRecognizer>(
                                () => PanGestureRecognizer()))
                        ..add(Factory<ScaleGestureRecognizer>(
                                () => ScaleGestureRecognizer())),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10,
                          // offset: Offset(4, 8), // Shadow position
                        ),
                      ],
                    ),
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Geolocations',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Geolocations history'),
                          trailing: Wrap(
                            children: <Widget>[
                              Text(
                                "${state.childInfoModel.counts!.locCount}",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.navigate_next,
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             LocationListPage(
                            //               childuid: widget.childuid,
                            //             )));
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return BlocProvider(
                                create: (ctx) => ChildLocationListBloc(),
                                child: LocationListPage(
                                  childuid: widget.childuid,

                                ),
                              );
                            }));
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Notification',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Notification history'),
                          trailing: Wrap(
                            children: <Widget>[
                              Text(
                                "${state.childInfoModel.counts!.notifCount}",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.navigate_next,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return BlocProvider(
                                create: (ctx) => ChildNotificationBloc(),
                                child: NotificationListPage(
                                  childuid: widget.childuid,

                                ),
                              );
                            }));
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.call,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Calls',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Call history'),
                          trailing: Wrap(
                            children: <Widget>[
                              Text(
                                "${state.childInfoModel.counts!.callCount}",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.navigate_next,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return BlocProvider(
                                create: (ctx) => ChildCallBloc(),
                                child: CallListPage(
                                  childuid: widget.childuid,

                                ),
                              );
                            }));
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.sms_sharp,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Sms',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Sms history'),
                          trailing: Wrap(
                            children: <Widget>[
                              Text(
                                "${state.childInfoModel.counts!.smsCount}",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.navigate_next,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return BlocProvider(
                                create: (ctx) => ChildSmsBloc(),
                                child: SmsListPage(
                                  childuid: widget.childuid,

                                ),
                              );
                            }));
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.apps,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Apps',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Apps List'),
                          trailing: Wrap(
                            children: <Widget>[
                              Text(
                                "${state.childInfoModel.counts!.appCount}",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.navigate_next,
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigator.of(context)
                            //     .push(MaterialPageRoute(
                            //     builder: (context) => AppListPage(
                            //       childuid: widget.childuid,
                            //     )));
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (ctx) => ChildAppListBloc(),
                                  ),
                                  BlocProvider(
                                    create: (context) => ChildAppUsageBloc(),
                                  ),
                                ],
                                child: AppListPage(
                                childuid: widget.childuid,
                                ),
                              );
                            }));
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.contacts,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Contacts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Contact history',

                          ),
                          trailing: Wrap(
                            children: <Widget>[
                              Text(
                                "${state.childInfoModel.counts!.contactCount}",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.navigate_next,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return BlocProvider(
                                create: (ctx) => ChildContactBloc(),
                                child: ContactListPage(
                                  childuid: widget.childuid,

                                ),
                              );
                            }));
                          },
                        ),
                        // Add more ListTiles here
                      ],
                    ),
                  ),
                ),

                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 0.03,
                // ),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 10, top: 20),
            //   child: IconButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     icon: Icon(Icons.arrow_back_ios),
            //   ),
            // ),
          ],
        );
            }
            if(state is ChildInfoError){
                return Center(child: Icon(Icons.error),);
            }
            if(state is ChildInfoExpired){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UpgradeWidget(),
                ],
              );
            }
            return LoadingWidget();
          },
        ),
      ),
    );
  }
}
