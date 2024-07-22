part of 'child_contact_bloc.dart';

enum ChildContact { loading, success, error, expired }

class ChildContactState extends Equatable {
  final ChildContact status;
  final List<Data> contacts;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChildContactState(
      {this.status = ChildContact.loading,
        this.islast = false,
        this.contacts = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  ChildContactState copyWith({
    ChildContact? status,
    List<Data>? contacts,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChildContactState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, contacts, islast, errorMessage,nextPageUrl];
}
