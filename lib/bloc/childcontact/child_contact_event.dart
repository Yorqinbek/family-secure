part of 'child_contact_bloc.dart';

abstract class ChildContactEvent extends Equatable {
  final String childuid;
  const ChildContactEvent({required this.childuid});

  @override
  List<Object> get props => [];
}

class GetChildContactEvent extends ChildContactEvent{
  GetChildContactEvent({required super.childuid});
}