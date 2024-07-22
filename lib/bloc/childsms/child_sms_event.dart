part of 'child_sms_bloc.dart';


abstract class ChildSmsEvent extends Equatable {
  final String childuid;
  const ChildSmsEvent({required this.childuid});

  @override
  List<Object> get props => [];
}

class GetChildSmsEvent extends ChildSmsEvent{
  GetChildSmsEvent({required super.childuid});
}

