part of 'child_call_bloc.dart';

abstract class ChildCallEvent extends Equatable {
  final String childuid;
  final String date;
  const ChildCallEvent({required this.childuid,required this.date});

  @override
  List<Object> get props => [];
}

class GetChildCallEvent extends ChildCallEvent{
  GetChildCallEvent({required super.childuid,required super.date});
}
class ReloadChildCallEvent extends ChildCallEvent{
  ReloadChildCallEvent({required super.childuid,required super.date});
}
