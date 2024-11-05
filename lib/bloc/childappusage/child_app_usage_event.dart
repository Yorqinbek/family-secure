part of 'child_app_usage_bloc.dart';

abstract class ChildAppUsageEvent extends Equatable {
  final String childuid;
  final String date;
  const ChildAppUsageEvent({required this.childuid,required this.date});

  @override
  List<Object> get props => [];
}

class GetChildAppUsageEvent extends ChildAppUsageEvent{
  GetChildAppUsageEvent({required super.childuid,required super.date});
}

class ReloadChildAppUsageEvent extends ChildAppUsageEvent{
  ReloadChildAppUsageEvent({required super.childuid,required super.date});
}