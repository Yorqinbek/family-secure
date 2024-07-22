part of 'child_sms_info_bloc.dart';

enum ChildSmsInfo { loading, success, error }

class ChildSmsInfoState extends Equatable {
  final ChildSmsInfo status;
  final List<Data> messages;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChildSmsInfoState(
      {this.status = ChildSmsInfo.loading,
        this.islast = false,
        this.messages = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  ChildSmsInfoState copyWith({
    ChildSmsInfo? status,
    List<Data>? messages,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChildSmsInfoState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, messages, islast, errorMessage,nextPageUrl];
}
