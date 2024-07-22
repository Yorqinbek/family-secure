import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:soqchi/screen/app_list.dart';
import 'package:soqchi/screen/call_list.dart';
import 'package:soqchi/screen/contact_list.dart';
import 'package:soqchi/screen/location_list.dart';
import 'package:soqchi/screen/sms_list.dart';

class ChildInfoPage extends StatefulWidget {
  final String childuid;
  final String chname;
  const ChildInfoPage(
      {super.key, required this.childuid, required this.chname});

  @override
  State<ChildInfoPage> createState() => _ChildInfoPageState();
}

class _ChildInfoPageState extends State<ChildInfoPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng _kMapCenter = LatLng(52.4478, -3.5402);
  GoogleMapController? controller;

  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text(widget.chname),
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
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height * 0.4,
              //   child: GoogleMap(
              //     initialCameraPosition: CameraPosition(
              //       target: _kMapCenter,
              //       zoom: 15.0,
              //     ),
              //     markers: <Marker>{
              //       Marker(
              //         markerId: const MarkerId('marker_1'),
              //         position: _kMapCenter,
              //         infoWindow: InfoWindow(
              //           title: 'Martin',
              //           snippet: '25 fevral 17:34',
              //         ),
              //       )
              //     },
              //     myLocationButtonEnabled: true,
              //     onMapCreated: _onMapCreated,
              //   ),
              // ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),

              Expanded(
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.location_history),
                      title: Text('Локации'),
                      subtitle: Text('История местоположений'),
                      trailing: Icon(Icons.navigate_next),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LocationListPage(
                                  childuid: widget.childuid,
                                )));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.call),
                      title: Text('Звонки'),
                      subtitle: Text('История звонков'),
                      trailing: Icon(Icons.navigate_next),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                CallListPage(childuid: widget.childuid)));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.sms_sharp),
                      title: Text('Сообщения'),
                      subtitle: Text('История сообщений'),
                      trailing: Icon(Icons.navigate_next),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SmsListPage(
                                  childuid: widget.childuid,
                                )));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.apps),
                      title: Text('Программы'),
                      subtitle: Text('Установленные программы'),
                      trailing: Icon(Icons.navigate_next),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AppListPage(
                                  childuid: widget.childuid,
                                )));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.contacts),
                      title: Text('Контакты'),
                      subtitle: Text('Список контактов'),
                      trailing: Icon(Icons.navigate_next),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ContactListPage(
                                  childuid: widget.childuid,
                                )));
                      },
                    ),
                    // Add more ListTiles here
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
