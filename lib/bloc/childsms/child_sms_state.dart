part of 'child_sms_bloc.dart';

enum ChildSms { loading, success, error, expired }

class ChildSmsState extends Equatable {
  final ChildSms status;
  final List<Data> sms;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChildSmsState(
      {this.status = ChildSms.loading,
        this.islast = false,
        this.sms = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  ChildSmsState copyWith({
    ChildSms? status,
    List<Data>? sms,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChildSmsState(
      status: status ?? this.status,
      sms: sms ?? this.sms,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, sms, islast, errorMessage,nextPageUrl];
}