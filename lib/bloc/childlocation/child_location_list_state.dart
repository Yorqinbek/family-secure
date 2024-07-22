part of 'child_location_list_bloc.dart';

@immutable
sealed class ChildLocationListState {}

final class ChildLocationListInitial extends ChildLocationListState {}

final class ChildLocationListLoading extends ChildLocationListState {}
final class ChildLocationListSuccess extends ChildLocationListState {
  ChildLocationListModel childlocationslist;
  Set<Polyline> polylines;
  List<String> location_names;
  Set<Marker> markers;
  ChildLocationListSuccess({required this.childlocationslist,required this.polylines,required this.location_names,required this.markers});
}
final class ChildLocationListError extends ChildLocationListState {}
final class ChildLocationListExpired extends ChildLocationListState {}
final class ChildLocationListEmpty extends ChildLocationListState {}