part of 'subscript_bloc.dart';

@immutable
sealed class SubscriptState {}

final class SubscriptInitial extends SubscriptState {}

final class SubscriptLoading extends SubscriptState {}
final class SubscriptSuccess extends SubscriptState {
  UserModel userModel;
  SubscriptSuccess({required this.userModel});
}
final class SubscriptError extends SubscriptState {}
final class SubscriptExpired extends SubscriptState {}
