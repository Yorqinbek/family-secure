part of 'child_web_bloc.dart';

abstract class ChildWebEvent extends Equatable {
  final String childuid;
  const ChildWebEvent({required this.childuid});

  @override
  List<Object> get props => [];
}

class GetChildWebEvent extends ChildWebEvent{
  GetChildWebEvent({required super.childuid});
}
class ReloadChildWebEvent extends ChildWebEvent{
  ReloadChildWebEvent({required super.childuid});
}
