part of 'dash_bloc.dart';

@immutable
sealed class DashState {}

final class DashInitial extends DashState {}
final class DashLoading extends DashState {}
final class DashSuccess extends DashState {
  List<Childs> childList;
  DashSuccess({required this.childList});
}
final class DashError extends DashState {}
final class DashEmpty extends DashState {}
final class DashExpired extends DashState {}
