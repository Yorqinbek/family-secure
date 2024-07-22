part of 'child_app_list_bloc.dart';

abstract class ChildAppEvent extends Equatable {
  final String childuid;
  const ChildAppEvent({required this.childuid});

  @override
  List<Object> get props => [];
}

class GetChildAppEvent extends ChildAppEvent{
  GetChildAppEvent({required super.childuid});
}
