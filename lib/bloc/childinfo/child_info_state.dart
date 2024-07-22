part of 'child_info_bloc.dart';

@immutable
sealed class ChildInfoState {}

final class ChildInfoInitial extends ChildInfoState {}

final class ChildInfoLoading extends ChildInfoState {}
final class ChildInfoSuccess extends ChildInfoState {
  ChildInfoModel childInfoModel;
  Marker marker;
  Set <Circle> circles;
  ChildInfoSuccess({required this.childInfoModel,required this.marker,required this.circles});
}
final class ChildInfoExpired extends ChildInfoState {}
final class ChildInfoError extends ChildInfoState {}