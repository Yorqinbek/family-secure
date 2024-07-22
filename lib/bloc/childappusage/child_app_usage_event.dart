part of 'child_app_usage_bloc.dart';

abstract class ChildAppUsageEvent extends Equatable {
  final String childuid;
  const ChildAppUsageEvent({required this.childuid});

  @override
  List<Object> get props => [];
}

class GetChildAppUsageEvent extends ChildAppUsageEvent{
  GetChildAppUsageEvent({required super.childuid});
}
