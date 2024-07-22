part of 'child_call_bloc.dart';


enum ChildCall { loading, success, error, expired }

class ChildCallState extends Equatable {
  final ChildCall status;
  final List<Data> calls;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChildCallState(
      {this.status = ChildCall.loading,
        this.islast = false,
        this.calls = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  ChildCallState copyWith({
    ChildCall? status,
    List<Data>? calls,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChildCallState(
      status: status ?? this.status,
      calls: calls ?? this.calls,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, calls, islast, errorMessage,nextPageUrl];
}