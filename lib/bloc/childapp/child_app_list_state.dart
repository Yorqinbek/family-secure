part of 'child_app_list_bloc.dart';



enum ChildApp { loading, success, error, expired }

class ChildAppState extends Equatable {
  final ChildApp status;
  final List<Data> apps;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChildAppState(
      {this.status = ChildApp.loading,
        this.islast = false,
        this.apps = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  ChildAppState copyWith({
    ChildApp? status,
    List<Data>? apps,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChildAppState(
      status: status ?? this.status,
      apps: apps ?? this.apps,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, apps, islast, errorMessage,nextPageUrl];
}