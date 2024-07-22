import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:soqchi/api/child_location_list_model.dart';

import '../../api/parent_repository.dart';

part 'child_location_list_event.dart';
part 'child_location_list_state.dart';

class ChildLocationListBloc extends Bloc<ChildLocationListEvent, ChildLocationListState> {
  ChildLocationListBloc() : super(ChildLocationListInitial()) {
    on<ChildLocationListEvent>((event, emit) {
      // TODO: implement event handler
    });

    Future<String> get_loca_name(String lat, String lon) async {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(double.parse(lat), double.parse(lon));
      Placemark place = placemarks[0];
      // print(placemarks);
      // return "${place.locality}, ${place.name}, ${place.country}";
      return "${place.subLocality} , ${place.locality}";
      // return "${place.subLocality}";
    }

    on<ChildLocationsLoadingData>((event, emit) async{
      emit(ChildLocationListLoading());
      // await Future.delayed(Duration(seconds: 3), () {
      //   // Your code
      // });
      try{
        final result = await ParentRepository().getchildlocations(event.childuid,event.date);
        if (result == null){
          emit(ChildLocationListExpired());
        }
        else if(result.locations!.isEmpty){
          emit(ChildLocationListEmpty());
        }
        else if(result.locations!.length>0){
          Set<Polyline> _polylines = {};
          Set<Marker> _markers = {};
          List<LatLng> _routePoints = [];
          List<String> _location_names = [];
          List<LatLng> _latlng = [];
          for (final location in result.locations!) {
            final loc_name = await get_loca_name(location.lat!, location.lon!);
            _location_names.add(loc_name);
            LatLng a = new LatLng(double.parse(location.lat.toString()), double.parse(location.lon.toString()));
            _markers.add(
              Marker(
                infoWindow: InfoWindow(
                  title:location.time

                ),
                markerId: MarkerId(a.toString()),
                position: a,
              ),
            );
            _latlng.add(a);
          }


          // final polylinePoints = PolylinePoints();
          // final result1 = await polylinePoints.getRouteBetweenCoordinates(
          //   'AIzaSyBVLsnpreKU19VpliskFe_puujj-NI3avU',
          //   PointLatLng(double.parse(result.locations![0].lat.toString()), double.parse(result.locations![0].lon.toString())),
          //   PointLatLng(double.parse(result.locations![0].lat.toString()), double.parse(result.locations![0].lon.toString())),
          // );
          // if (result1.points.isNotEmpty) {
          //     _routePoints = result1.points
          //         .map((point) => LatLng(point.latitude, point.longitude))
          //         .toList();
          //
          //     _polylines.add(Polyline(
          //       polylineId: PolylineId('route'),
          //       points: _latlng,
          //       color: Colors.blue,
          //       width: 5,
          //     ));
          // }
          // print(result);
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: _latlng,
            color: Colors.blue,
            width: 5,
          ));
          emit(ChildLocationListSuccess(childlocationslist: result,polylines: _polylines,location_names: _location_names,markers: _markers));
        }
        else{
          emit(ChildLocationListError());
        }
      }
      catch(e){
        print(e.toString());
        emit(ChildLocationListError());
      }
    });
  }
}
