part of 'child_app_usage_bloc.dart';


enum ChildAppUsage { loading, success, error, expired }

class ChildAppUsageState extends Equatable {
  final ChildAppUsage status;
  final List<Data> apps;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChildAppUsageState(
      {this.status = ChildAppUsage.loading,
        this.islast = false,
        this.apps = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  ChildAppUsageState copyWith({
    ChildAppUsage? status,
    List<Data>? apps,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChildAppUsageState(
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