import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/poster_help/post_helper.dart';

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
    await Jiffy.setLocale('ru');
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('bearer_token') ?? '';

    Map data = {'chuid': widget.childuid};

    String response =
        await post_helper_token(data, '/getchildlocations', token);
    if (response != "Error") {
      final Map response_json = json.decode(response);
      if (response_json['status']) {
        setState(() {
          locations = response_json['locations'];
        });
        if (locations != null && !locations!.isEmpty) {
          Map<String, dynamic> location_list = locations![0];
          setState(() {
            _center = LatLng(double.parse(location_list['lat']),
                double.parse(location_list['lon']));
            final marker = Marker(
              markerId: MarkerId("initial_marker"),
              position: _center,
              infoWindow: InfoWindow(
                  title: "Initial Marker", snippet: "An interesting location"),
            );
            setState(() {
              _markers["initial_marker"] = marker;
            });
          });
        }
      }
    } else {
      print('response Error');
    }

    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text("Местоположение"),
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
        child: Container(
          child: locations == null
              ? SizedBox()
              : locations!.isEmpty
                  ? Center(
                      child: Text("Пустой"),
                    )
                  : Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: GoogleMap(
                            myLocationEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: _center,
                              zoom: 15.0,
                            ),
                            markers: _markers.values.toSet(),
                            myLocationButtonEnabled: true,
                            onMapCreated: _onMapCreated,
                            gestureRecognizers: Set()
                              ..add(Factory<PanGestureRecognizer>(
                                  () => PanGestureRecognizer()))
                              ..add(Factory<ScaleGestureRecognizer>(
                                  () => ScaleGestureRecognizer())),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: locations!.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> location_list =
                                    locations![index];
                                return ListTile(
                                  tileColor: index == active_index
                                      ? Colors.black12
                                      : null,
                                  // leading: Icon(Icons.person),
                                  leading: Icon(
                                    Icons.location_history,
                                    // color: Colors.white,
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Jiffy.parse(location_list['time'])
                                            .format(
                                                pattern:
                                                    'MMMM do yyyy, h:mm:ss a')
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
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
                                  subtitle: Text(location_list['lat'] +
                                      "," +
                                      location_list['lon']),
                                  // trailing: Icon(Icons.navigate_next),
                                  onTap: () async {
                                    setState(() {
                                      active_index = index;
                                      _center = LatLng(
                                          double.parse(location_list['lat']),
                                          double.parse(location_list['lon']));
                                    });
                                    final marker = Marker(
                                      markerId: MarkerId("initial_marker"),
                                      position: _center,
                                      infoWindow: InfoWindow(
                                        title:
                                            Jiffy.parse(location_list['time'])
                                                .format(
                                                    pattern:
                                                        'MMMM do yyyy, h:mm:ss')
                                                .toString(),
                                        // snippet: "An interesting location"
                                      ),
                                    );
                                    setState(() {
                                      controller!.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                              _center, 15));

                                      _markers["initial_marker"] = marker;
                                    });
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
      ),
    );
  }
}
