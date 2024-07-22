part of 'child_notification_bloc.dart';


enum ChildNotification { loading, success, error, expired }

class ChildNotificationState extends Equatable {
  final ChildNotification status;
  final List<Data>? notification;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChildNotificationState(
      {this.status = ChildNotification.loading,
        this.islast = false,
        this.notification = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  ChildNotificationState copyWith({
    ChildNotification? status,
    List<Data>? notification,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChildNotificationState(
      status: status ?? this.status,
      notification: notification ?? this.notification,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, notification, islast, errorMessage,nextPageUrl];
}
