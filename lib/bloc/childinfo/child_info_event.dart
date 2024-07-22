part of 'child_info_bloc.dart';

@immutable
sealed class ChildInfoEvent {}

class ChildInfoLoadingData extends ChildInfoEvent{
  final String childuid;
  ChildInfoLoadingData({required this.childuid});
}
