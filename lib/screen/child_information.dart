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
import 'package:soqchi/bloc/childwebblock/child_web_bloc.dart';
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
import 'package:soqchi/screen/web_block_list.dart';
import 'package:soqchi/widgets/upgradewidget.dart';

import '../bloc/childinfo/child_info_bloc.dart';
import '../widgets/loadingwidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  int online = -1;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChildInfoBloc>(context).add(ChildInfoLoadingData(childuid: widget.childuid));
  }

  LatLng? child_latlong;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true, // this is all you need
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.name,
              style: TextStyle(fontSize: 20)
            ),
            online == -1 ? SizedBox() : online == 1 ? Text(AppLocalizations.of(context)!.online,style: TextStyle(fontSize: 12,color: Colors.blue)):Text(AppLocalizations.of(context)!.offline,style: TextStyle(fontSize: 12,color: Colors.red))
          ],
        ),
        actions: [
          IconButton(onPressed: (){
            controller!.animateCamera(
                CameraUpdate
                    .newLatLngZoom(
                    child_latlong!,
                    15));


          }, icon: Icon(Icons.location_on,color:  Colors.blue,)),
          IconButton(onPressed: (){
            setState(() {
              online = -1;
            });
            BlocProvider.of<ChildInfoBloc>(context).add(ChildInfoLoadingData(childuid: widget.childuid));

          }, icon: Icon(Icons.refresh,color:  Colors.blue,)),


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
      body:SafeArea(
        child: BlocBuilder<ChildInfoBloc, ChildInfoState>(
          builder: (ctx, state)  {
            if(state is ChildInfoSuccess){
              child_latlong = LatLng(double.parse("${state.childInfoModel.loc?.lat}"),
                  double.parse("${state.childInfoModel.loc?.lon}"));
              online = state.childInfoModel.online!;
              print(online);
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
                            AppLocalizations.of(context)!.geolocation,
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(AppLocalizations.of(context)!.geolocation_history),
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
                            Icons.apps,
                            color: Colors.blue,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.apps,
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(AppLocalizations.of(context)!.apps_sub),
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
                            Icons.call,
                            color: Colors.blue,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.calls,
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(AppLocalizations.of(context)!.calls_sub),
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
                            AppLocalizations.of(context)!.sms,
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(AppLocalizations.of(context)!.sms_sub),
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
                            Icons.language,
                            color: Colors.blue,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.web,
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(AppLocalizations.of(context)!.web_sub),
                          trailing: Wrap(
                            children: <Widget>[
                              Text(
                                "${state.childInfoModel.counts!.webCount}",
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
                                create: (ctx) => ChildWebBloc(),
                                child: WebBlockPage(
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
                            AppLocalizations.of(context)!.notification,
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(AppLocalizations.of(context)!.notification_sub),
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
                            Icons.contacts,
                            color: Colors.blue,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.contacts,
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.contacts_sub,

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
