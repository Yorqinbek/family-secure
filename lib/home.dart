import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/poster_help/post_helper.dart';

class HomePage extends StatefulWidget {
  // final String childuid;
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng _center = LatLng(double.parse('41.3279503'), double.parse('69.34076'));

  GoogleMapController? controller;

  void _onMapCreated(GoogleMapController controllerParam) {
    String sty =
        '[  {    "elementType": "geometry",    "stylers": [      {        "color": "#242f3e"      }    ]  },  {    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#746855"      }    ]  },  {    "elementType": "labels.text.stroke",    "stylers": [      {        "color": "#242f3e"      }    ]  },  {    "featureType": "administrative.locality",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "poi",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "poi.park",    "elementType": "geometry",    "stylers": [      {        "color": "#263c3f"      }    ]  },  {    "featureType": "poi.park",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#6b9a76"      }    ]  },  {    "featureType": "road",    "elementType": "geometry",    "stylers": [      {        "color": "#38414e"      }    ]  },  {    "featureType": "road",    "elementType": "geometry.stroke",    "stylers": [      {        "color": "#212a37"      }    ]  },  {    "featureType": "road",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#9ca5b3"      }    ]  },  {    "featureType": "road.highway",    "elementType": "geometry",    "stylers": [      {        "color": "#746855"      }    ]  },  {    "featureType": "road.highway",    "elementType": "geometry.stroke",    "stylers": [      {        "color": "#1f2835"      }    ]  },  {    "featureType": "road.highway",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#f3d19c"      }    ]  },  {    "featureType": "transit",    "elementType": "geometry",    "stylers": [      {        "color": "#2f3948"      }    ]  },  {    "featureType": "transit.station",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "water",    "elementType": "geometry",    "stylers": [      {        "color": "#17263c"      }    ]  },  {    "featureType": "water",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#515c6d"      }    ]  },  {    "featureType": "water",    "elementType": "labels.text.stroke",    "stylers": [      {        "color": "#17263c"      }    ]  }]';
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

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    final bitmapIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(64, 64)), 'assets/images/loc4.png');
    setState(() {
      _center = LatLng(double.parse('41.3279503'), double.parse('69.34076'));
      final marker = Marker(
        markerId: MarkerId("initial_marker"),
        position: _center,
        icon: bitmapIcon,
        infoWindow: InfoWindow(
            title: "Initial Marker", snippet: "An interesting location"),
      );
      setState(() {
        _markers["initial_marker"] = marker;
      });
    });

    // await Jiffy.setLocale('ru');
    // final SharedPreferences prefs = await _prefs;
    // String token = prefs.getString('bearer_token') ?? '';

    // Map data = {'chuid': widget.childuid};

    // String response =
    //     await post_helper_token(data, '/getchildlocations', token);
    // if (response != "Error") {
    //   final Map response_json = json.decode(response);
    //   if (response_json['status']) {
    //     setState(() {
    //       locations = response_json['locations'];
    //     });
    //     if (locations != null && !locations!.isEmpty) {
    //       Map<String, dynamic> location_list = locations![0];
    //       setState(() {
    //         _center = LatLng(double.parse(location_list['lat']),
    //             double.parse(location_list['lon']));
    //         final marker = Marker(
    //           markerId: MarkerId("initial_marker"),
    //           position: _center,
    //           infoWindow: InfoWindow(
    //               title: "Initial Marker", snippet: "An interesting location"),
    //         );
    //         setState(() {
    //           _markers["initial_marker"] = marker;
    //         });
    //       });
    //     }
    //   }
    // } else {
    //   print('response Error');
    // }

    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   centerTitle: true, // this is all you need
      //   leading: IconButton(
      //     icon: Icon(
      //       Icons.arrow_back_ios,
      //       color: Colors.black,
      //     ),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15.0,
                    ),
                    mapType: MapType.terrain,
                    markers: _markers.values.toSet(),
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
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Text(
                            "Farzandlarim",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          child: Expanded(
                            child: ListView.builder(
                                itemCount: 2,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Material(
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            ListTile(
                                              // tileColor: index == active_index
                                              //     // ? Color(0XFFedf9fc)
                                              //     ? Colors.grey[200]
                                              //     : null,
                                              // leading: Icon(Icons.person),
                                              leading: Container(
                                                height: 46,
                                                width: 46,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue,
                                                ),
                                                child: Icon(
                                                  CupertinoIcons.person_fill,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                              trailing: Icon(
                                                Icons.navigate_next,
                                                color: Colors.blue,
                                              ),
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Akmal",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  // Text(
                                                  //   // From X
                                                  //   Jiffy.parse(sms_list['time']).from(
                                                  //       Jiffy.parse(
                                                  //           DateTime.now().toString())),
                                                  //   style: TextStyle(fontSize: 12),
                                                  // ),
                                                ],
                                              ),
                                              subtitle: Text("o'g'lim"),
                                              // subtitle: Text(
                                              //     location_list['lat'] +
                                              //         "," +
                                              //         location_list[
                                              //             'lon']),
                                              // trailing: Icon(Icons.navigate_next),
                                              onTap: () async {},
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.03,
              // ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 20),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
          ),
        ],
      ),
    );
  }
}
