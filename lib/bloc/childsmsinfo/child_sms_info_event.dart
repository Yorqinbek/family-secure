part of 'child_sms_info_bloc.dart';

abstract class ChildSmsInfoEvent extends Equatable {
  final String childuid;
  final String sender;
  const ChildSmsInfoEvent({required this.childuid,required this.sender});

  @override
  List<Object> get props => [];
}

class GetChildSmsInfoEvent extends ChildSmsInfoEvent{
  GetChildSmsInfoEvent({required super.childuid,required super.sender});
}

