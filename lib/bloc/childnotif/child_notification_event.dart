part of 'child_notification_bloc.dart';

// @immutable
// sealed class ChildNotificationEvent {}
//
// class ChildNotificationLoadingData extends ChildNotificationEvent{
//   final String childuid;
//   ChildNotificationLoadingData({required this.childuid});
// }

abstract class ChildNotificationEvent extends Equatable {
  final String childuid;
  final String date;
  const ChildNotificationEvent({required this.childuid,required this.date});

  @override
  List<Object> get props => [];
}

class GetChildNotificationEvent extends ChildNotificationEvent{
  GetChildNotificationEvent({required super.childuid,required super.date});
}

class ReloadChildNotificationEvent extends ChildNotificationEvent{
  ReloadChildNotificationEvent({required super.childuid,required super.date});
}

