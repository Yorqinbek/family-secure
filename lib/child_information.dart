import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/app_list.dart';
import 'package:soqchi/call_list.dart';
import 'package:soqchi/contact_list.dart';
import 'package:soqchi/location_list.dart';
import 'package:soqchi/notif_list.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'package:soqchi/sms_list.dart';

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
  var counts;

  final Map<String, Marker> _markers = {};

  int active_index = 0;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';
    Map data = {'chid': widget.childuid};

    String response = await post_helper_token(data, '/getchildinfo', token);

    if (response != "Error") {
      final Map response_json = json.decode(response);
      if (response_json['status']) {
        if (response_json['loc'] != null) {
          final bitmapIcon = await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(64, 64)),
              'assets/images/location_blue.png');
          List<Placemark> placemarks = await placemarkFromCoordinates(
              double.parse(response_json['loc']['lat']),
              double.parse(response_json['loc']['lon']));
          Placemark place = placemarks[0]; // Taking the first returned result
          print(
              "Qani:${place.locality}, ${place.postalCode}, ${place.country}");
          setState(() {
            counts = response_json['counts'];
            _center = LatLng(double.parse(response_json['loc']['lat']),
                double.parse(response_json['loc']['lon']));
            final marker = Marker(
              markerId: MarkerId("initial_marker"),
              position: _center,
              icon: bitmapIcon,
              infoWindow: InfoWindow(
                  title: "${place.locality}, ${place.name}, ${place.country}",
                  snippet: "${response_json['loc']['time']}"),
            );
            setState(() {
              _markers["initial_marker"] = marker;
            });
          });
        } else {
          print('lokatsiya yoq');
        }
      }
    } else {
      print('response Error');
    }

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
      body: _refreshController.isRefresh || counts == null
          ? SizedBox()
          : counts!.isEmpty
              ? Center(
                  child: Text("Пустой"),
                )
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: GoogleMap(
                              tiltGesturesEnabled: true,
                              myLocationEnabled: true,
                              // zoomControlsEnabled: true,
                              mapToolbarEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: _center,
                                zoom: 13.0,
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
                              child: ListView(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      'Geolokatsiya',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Geolokatsiyalar tarixi'),
                                    trailing: Wrap(
                                      children: <Widget>[
                                        Text(
                                          "${counts['loc_count']}",
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
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LocationListPage(
                                                    childuid: widget.childuid,
                                                  )));
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
                                    subtitle: Text('Notification tarixi'),
                                    trailing: Wrap(
                                      children: <Widget>[
                                        Text(
                                          "${counts['notif_count']}",
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
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NotificationListPage(
                                                    childuid: widget.childuid,
                                                  )));
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.call,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      'Qo`ng`iroqlar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Qo`ng`iroqlar tarixi'),
                                    trailing: Wrap(
                                      children: <Widget>[
                                        Text(
                                          "${counts['call_count']}",
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
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CallListPage(
                                                      childuid:
                                                          widget.childuid)));
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.sms_sharp,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      'Xabarlar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Xabarlar tarixi'),
                                    trailing: Wrap(
                                      children: <Widget>[
                                        Text(
                                          "${counts['sms_count']}",
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
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => SmsListPage(
                                                    childuid: widget.childuid,
                                                  )));
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.apps,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      'Dasturlar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('O`rnatilgan dasturlar'),
                                    trailing: Wrap(
                                      children: <Widget>[
                                        Text(
                                          "${counts['app_count']}",
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
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => AppListPage(
                                                    childuid: widget.childuid,
                                                  )));
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.contacts,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      'Kontaktlar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Kontaktlar ro`yxati',

                                    ),
                                    trailing: Wrap(
                                      children: <Widget>[
                                        Text(
                                          "${counts['contact_count']}",
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
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ContactListPage(
                                                    childuid: widget.childuid,
                                                  )));
                                    },
                                  ),
                                  // Add more ListTiles here
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
                ),
    );
  }
}
