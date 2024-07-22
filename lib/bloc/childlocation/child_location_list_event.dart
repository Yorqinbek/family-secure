part of 'child_location_list_bloc.dart';

@immutable
sealed class ChildLocationListEvent {}

class ChildLocationsLoadingData extends ChildLocationListEvent{
  final String childuid;
  final String date;
  ChildLocationsLoadingData({required this.childuid,required this.date});
}