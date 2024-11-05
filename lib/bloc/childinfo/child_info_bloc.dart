import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:soqchi/api/child_info_model.dart';
import 'package:soqchi/api/parent_repository.dart';
import 'package:flutter/material.dart';
import '../../api/child_model.dart';

part 'child_info_event.dart';
part 'child_info_state.dart';

class ChildInfoBloc extends Bloc<ChildInfoEvent, ChildInfoState> {
  ChildInfoBloc() : super(ChildInfoInitial()) {
    on<ChildInfoEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<ChildInfoLoadingData>((event, emit) async {
      emit(ChildInfoLoading());
      // await Future.delayed(Duration(seconds: 3), () {
      //   // Your code
      // });
      try{
        final result = await ParentRepository().getChildInfo(event.childuid);
        if(result == null){
          emit(ChildInfoExpired());
        }
        else if(result.status!){
          final bitmapIcon;
          if(Platform.isAndroid){
            bitmapIcon = await BitmapDescriptor.fromAssetImage(
                ImageConfiguration(size: Size(64, 64)),
                'assets/images/location_blue.png');
          }
          else{
            bitmapIcon = await BitmapDescriptor.fromAssetImage(
              mipmaps: false,
                ImageConfiguration(devicePixelRatio: 2.5,),

                'assets/images/location_blue.png');
          }
          List<Placemark> placemarks = await placemarkFromCoordinates(
              double.parse("${result.loc?.lat}"),
              double.parse("${result.loc?.lon}"));
          Placemark place = placemarks[0];

          var address = '';

          if (placemarks.isNotEmpty) {

            // Concatenate non-null components of the address
            var streets = placemarks.reversed
                .map((placemark) => placemark.street)
                .where((street) => street != null);

            // Filter out unwanted parts
            streets = streets.where((street) =>
            street!.toLowerCase() !=
                placemarks.reversed.last.locality!
                    .toLowerCase()); // Remove city names
            streets =
                streets.where((street) => !street!.contains('+')); // Remove street codes

            address += streets.join(', ');
            //
            // address += ', ${placemarks.reversed.last.subLocality ?? ''}';
            // address += ', ${placemarks.reversed.last.locality ?? ''}';
            // address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
            // address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
            // address += ', ${placemarks.reversed.last.postalCode ?? ''}';
            // address += ', ${placemarks.reversed.last.country ?? ''}';
          }


          final marker = Marker(
            markerId: MarkerId("initial_marker"),
            position: LatLng(double.parse("${result.loc?.lat}"),
                double.parse("${result.loc?.lon}")),
            icon: bitmapIcon,

            infoWindow: InfoWindow(

                // title: "${place.locality}, ${place.subLocality}, ${place.country}",
                title: address,
                snippet: "${result.loc!.time}"),
          );
          Set <Circle> circles = Set.from([Circle(
            circleId: CircleId("myid"),
            center: LatLng(double.parse("${result.loc?.lat}"),
                double.parse("${result.loc?.lon}")),
            radius: 300,
              fillColor: Colors.blue.shade100.withOpacity(0.5),
              strokeColor:  Colors.blue.shade100.withOpacity(0.1)
          )]);
          emit(ChildInfoSuccess(childInfoModel: result,marker: marker,circles: circles));
        }
        else{
          emit(ChildInfoError());
        }
      }
      catch(e){
        emit(ChildInfoError());
      }
    });
  }
}
