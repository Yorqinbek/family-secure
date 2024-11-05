part of 'child_web_bloc.dart';

enum ChildWeb { loading, success, error, expired }

class ChildWebState extends Equatable {
  final ChildWeb status;
  final List<Data> websites;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChildWebState(
      {this.status = ChildWeb.loading,
        this.islast = false,
        this.websites = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  ChildWebState copyWith({
    ChildWeb? status,
    List<Data>? websites,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChildWebState(
      status: status ?? this.status,
      websites: websites ?? this.websites,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, websites, islast, errorMessage,nextPageUrl];
}
