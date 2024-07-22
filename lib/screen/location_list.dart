import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/childlocation/child_location_list_bloc.dart';
import 'package:soqchi/components/dialogs.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'package:soqchi/widgets/upgradewidget.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../api/child_location_list_model.dart';
import '../widgets/EmptyListWidget.dart';
import '../widgets/loadingwidget.dart';

class LocationListPage extends StatefulWidget {
  final String childuid;
  const LocationListPage({super.key, required this.childuid});

  @override
  State<LocationListPage> createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng _center = LatLng(-34.603684, -58.381559);

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
  List<dynamic>? locations;

  final Map<String, Marker> _markers = {};

  int active_index = 0;

  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    BlocProvider.of<ChildLocationListBloc>(context).add(ChildLocationsLoadingData(childuid: widget.childuid,date: now.toString()));
    // _onRefresh();
  }

  Future<String> get_loca_name(String lat, String lon) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(double.parse(lat), double.parse(lon));
    Placemark place = placemarks[0];
    // print(placemarks);
    // return "${place.locality}, ${place.name}, ${place.country}";
    return "${place.subLocality} , ${place.locality}";
    // return "${place.subLocality}";
  }

  Future<void> driwe_route(List<Locations> locations) async {
    print("Keldi");
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyBVLsnpreKU19VpliskFe_puujj-NI3avU',
      PointLatLng(double.parse(locations.first.lat.toString()), double.parse(locations.first.lon.toString())),
      PointLatLng(double.parse(locations.last.lat.toString()), double.parse(locations.last.lon.toString())),
    );
    if (result.points.isNotEmpty) {
      print(result.points);
      setState(() {
        _routePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: _routePoints,
          color: Colors.blue,
          width: 5,
        ));
      });
    }
  }

  int selected_index = 0;

  Future<void> _onRefresh() async {
    await Jiffy.setLocale('ru');
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';

    Map data = {'chuid': widget.childuid};

    String response =
        await post_helper_token(data, '/getchildlocations', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      print(response_json);
      if (response_json['status']) {
        setState(() {
          locations = response_json['locations'];
        });
        if (locations != null && !locations!.isEmpty) {
          Map<String, dynamic> location_list = locations![0];
          final bitmapIcon = await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(64, 64)),
              'assets/images/location_blue.png');
          List<Placemark> placemarks = await placemarkFromCoordinates(
              double.parse(location_list['lat']),
              double.parse(location_list['lon']));
          Placemark place = placemarks[0]; // Taking the first returned result
          setState(() {
            _center = LatLng(double.parse(location_list['lat']),
                double.parse(location_list['lon']));
            final marker = Marker(
              markerId: MarkerId("initial_marker"),
              position: _center!,
              icon: bitmapIcon,
              infoWindow: InfoWindow(
                title: Jiffy.parse(
                    location_list[
                    'time'])
                    .format(
                    pattern:
                    'MMMM do yyyy, h:mm:ss')
                    .toString(),
                // snippet: "An interesting location"
              ),
            );
            controller!.animateCamera(
                CameraUpdate
                    .newLatLngZoom(
                    _center!,
                    15));

            _markers[
            "initial_marker"] =
                marker;
          });
        }
      }
    } else {
      print('response Error');
    }

    _refreshController.refreshCompleted();
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

        initialDate: _selectedDate == null ? DateTime.now() : _selectedDate,
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
        selected_index = 0;
      });
      print(_selectedDate.toString());
      BlocProvider.of<ChildLocationListBloc>(context).add(ChildLocationsLoadingData(childuid: widget.childuid,date: _selectedDate.toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
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
        title: Text("Joylashuvlar"),
        // backgroundColor: Colors.transparent,
        // centerTitle: true, // this is all you need
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
        child: BlocBuilder<ChildLocationListBloc, ChildLocationListState>(builder: (context, state)
        {
          if(state is ChildLocationListSuccess){

              _center = LatLng(
                  double.parse(
                      state.childlocationslist.locations!.first.lat.toString()),
                  double.parse(
                    state.childlocationslist.locations!.first.lon.toString(),));
            // setState(() {
            //   controller!.animateCamera(
            //       CameraUpdate
            //           .newLatLngZoom(
            //           _center!,
            //           15));
            //
            // });
            // FutureBuilder<void>(
            //     future: driwe_route(state.childlocationslist.locations!),
            //     builder: (context, snapshot) {
            //       return Text("-");
            //     });
              return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.50,
                        child: GoogleMap(

                          // myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: _center!,
                            zoom: 18.0,
                          ),
                          polylines: state.polylines,
                          markers: state.markers,
                          myLocationButtonEnabled: true,
                          onMapCreated: _onMapCreated,
                          gestureRecognizers: Set()
                            ..add(Factory<PanGestureRecognizer>(
                                    () => PanGestureRecognizer()))
                            ..add(Factory<ScaleGestureRecognizer>(
                                    () => ScaleGestureRecognizer())),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.03,
                    // ),

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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, top: 20),
                              child: Row(
                                children: [
                                  Text(
                                    "Локации",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.3,),
                                  TextButton(
                                    onPressed: _pickDateDialog,
                                    child: Text(
                                      Jiffy.parse(_selectedDate == null ? DateTime.now().toString(): _selectedDate.toString())
                                          .yMMMMd,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 16,
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                child: ListView.builder(
                                    itemCount: state.childlocationslist.locations!.length,
                                    itemBuilder: (context, index) {
                                     Locations location_list = state.childlocationslist.locations![index];

                                      // var loc_name = FutureBuilder<
                                      //     String>(
                                      //     future: get_loca_name(
                                      //         location_list.lat.toString(),
                                      //         location_list.lon.toString(),
                                      //     ),
                                      //     builder: (context, snapshot) {
                                      //       if (snapshot
                                      //           .connectionState ==
                                      //           ConnectionState.waiting) {
                                      //         return Text("-"); // Show loading indicator
                                      //       } else if (snapshot
                                      //           .hasError) {
                                      //         return Text(
                                      //             "Error: ${snapshot.error}");
                                      //       } else {
                                      //         return Text(snapshot.data!,
                                      //             style: TextStyle(
                                      //                 fontWeight:
                                      //                 FontWeight
                                      //                     .bold));
                                      //       }
                                      //     });
                                     return InkWell(
                                       onTap: (){
                                         controller!.animateCamera(
                                             CameraUpdate
                                                 .newLatLngZoom(
                                                 LatLng(double.parse(state.childlocationslist.locations![index].lat.toString()), double.parse(state.childlocationslist.locations![index].lon.toString())),
                                                 18));
                                         setState(() {
                                           selected_index = index;
                                         });
                                       },
                                       child: TimelineTile(

                                         alignment: TimelineAlign.manual,
                                         lineXY: 0.08,
                                         isFirst: state.childlocationslist.locations![index] == state.childlocationslist.locations!.first,
                                         isLast: state.childlocationslist.locations![index] == state.childlocationslist.locations!.last,
                                         beforeLineStyle: LineStyle(color: Colors.grey),
                                         indicatorStyle: IndicatorStyle(color: Colors.blue,padding: EdgeInsets.all(10),indicator: Icon(Icons.location_on,size: 20,color: Colors.blue,),),
                                         endChild: Container(
                                           constraints: const BoxConstraints(
                                             minHeight: 30,
                                             // minWidth: 120,
                                           ),
                                           child: Container(
                                             constraints: const BoxConstraints(
                                               minHeight: 30,
                                               // minWidth: 120,
                                             ),
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               mainAxisAlignment: MainAxisAlignment.center,
                                               children: [
                                                 Text(state.location_names[index],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: index == selected_index ? Colors.blue:Colors.black),),
                                                Row(
                                                  children: [
                                                    Icon(Icons.timer_sharp,size: 18,color: Colors.black,),
                                                    SizedBox(width: 5,),
                                                    Text(
                                                    Jiffy.parse(location_list.time.toString())
                                                        // .fromNow()
                                                        .format(
                                                        pattern:
                                                        'h:mm:ss')
                                                    // .format(
                                                    //     pattern: 'h:mm')
                                                        .toString(),
                                                      style: TextStyle(fontSize: 18,color: Colors.black),
                                                                                                  ),
                                                  ],
                                                )
                                               ],
                                             ),
                                           ),
                                         ),
                                         // startChild: Icon(Icons.location_on_outlined),
                                       ),
                                     );

                                      // return Material(
                                      //   color: Colors.white,
                                      //   child: Column(
                                      //     children: [
                                      //       ListTile(
                                      //         tileColor: index ==
                                      //             active_index
                                      //         // ? Color(0XFFedf9fc)
                                      //             ? Colors.grey[200]
                                      //             : null,
                                      //         // leading: Icon(Icons.person),
                                      //         leading: Icon(
                                      //           Icons.location_pin,
                                      //           // color: Colors.blueAccent,
                                      //           // color: Colors.white,
                                      //         ),
                                      //         title: Row(
                                      //           mainAxisAlignment:
                                      //           MainAxisAlignment
                                      //               .spaceBetween,
                                      //           children: [
                                      //             loc_name,
                                      //             // Text(
                                      //             //   // From X
                                      //             //   Jiffy.parse(sms_list['time']).from(
                                      //             //       Jiffy.parse(
                                      //             //           DateTime.now().toString())),
                                      //             //   style: TextStyle(fontSize: 12),
                                      //             // ),
                                      //           ],
                                      //         ),
                                      //         subtitle: Text(
                                      //           Jiffy.parse(location_list.time.toString())
                                      //               .format(
                                      //               pattern:
                                      //               'MMMM do yyyy, h:mm:ss')
                                      //           // .format(
                                      //           //     pattern: 'h:mm')
                                      //               .toString(),
                                      //         ),
                                      //         // subtitle: Text(
                                      //         //     location_list['lat'] +
                                      //         //         "," +
                                      //         //         location_list[
                                      //         //             'lon']),
                                      //         // trailing: Icon(Icons.navigate_next),
                                      //         onTap: () async {
                                      //           setState(() {
                                      //             active_index = index;
                                      //             _center = LatLng(
                                      //                 double.parse(
                                      //                   location_list.lat.toString()),
                                      //                 double.parse(
                                      //                   location_list.lon.toString(),));
                                      //           });
                                      //           final bitmapIcon = await BitmapDescriptor.fromAssetImage(
                                      //               ImageConfiguration(size: Size(64, 64)),
                                      //               'assets/images/location_blue.png');
                                      //           final marker = Marker(
                                      //             markerId: MarkerId(
                                      //                 "initial_marker"),
                                      //             position: _center!,
                                      //             icon: bitmapIcon,
                                      //             infoWindow: InfoWindow(
                                      //               title: Jiffy.parse(
                                      //                 location_list.time.toString(),)
                                      //                   .format(
                                      //                   pattern:
                                      //                   'MMMM do yyyy, h:mm:ss')
                                      //                   .toString(),
                                      //               // snippet: "An interesting location"
                                      //             ),
                                      //           );
                                      //           setState(() {
                                      //             controller!.animateCamera(
                                      //                 CameraUpdate
                                      //                     .newLatLngZoom(
                                      //                     _center!,
                                      //                     15));
                                      //
                                      //             _markers[
                                      //             "initial_marker"] =
                                      //                 marker;
                                      //           });
                                      //           // Navigator.of(context)
                                      //           //     .push(MaterialPageRoute(
                                      //           //         builder: (context) => SmsInfoPage(
                                      //           //               sender: sms_list['sender'],
                                      //           //             )));
                                      //         },
                                      //       ),
                                      //     ],
                                      //   ),
                                      // );
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          if(state is ChildLocationListExpired){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UpgradeWidget(),
                ],
              );
          }
          if(state is ChildLocationListError){
            return MyCustomDialogs.server_conn_err();
          }
          if(state is ChildLocationListEmpty){
            return EmptyListWidget();
          }
          return LoadingWidget();
        },

),
              ),
    );
  }
}
