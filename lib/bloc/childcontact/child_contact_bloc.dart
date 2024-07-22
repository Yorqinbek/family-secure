import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/child_contact_model.dart';
import '../../api/parent_repository.dart';

part 'child_contact_event.dart';
part 'child_contact_state.dart';

class ChildContactBloc extends Bloc<ChildContactEvent, ChildContactState> {
  ChildContactBloc() : super(ChildContactState()) {
    on<ChildContactEvent>((event, emit) async {
      if (event is GetChildContactEvent) {
        if (state.islast) return;
        try {
          if (state.status == ChildContact.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final contact_response =  await ParentRepository().getchildcontact(event.childuid,state.nextPageUrl);
            if(contact_response == null){
              return emit(state.copyWith(
                  status: ChildContact.expired, islast: true));
            }
            else{
              return contact_response!.contacts!.data!.isEmpty
                  ? emit(state.copyWith(
                  status: ChildContact.success, islast: true))
                  : emit(state.copyWith(
                  status: ChildContact.success,
                  nextPageUrl: contact_response.contacts!.nextPageUrl,
                  contacts: contact_response.contacts!.data!,
                  islast: contact_response.contacts!.nextPageUrl == null ? true : false));
            }
          } else {
            final contact_response =  await ParentRepository().getchildcontact(event.childuid,state.nextPageUrl);
            if(contact_response == null){
              return emit(state.copyWith(
                  status: ChildContact.expired, islast: true));
            }
            else {
              return contact_response!.contacts!.data!.isEmpty
                  ? emit(state.copyWith(islast: true))
                  : emit(state.copyWith(
                  nextPageUrl: contact_response.contacts!.nextPageUrl,
                  status: ChildContact.success,
                  contacts: List.of(state.contacts)..addAll(contact_response.contacts!.data!),
                  islast: contact_response.contacts!.nextPageUrl == null ? true : false));
            }
          }
        } catch (e) {
          if(state.status == ChildContact.loading){
            return emit(state.copyWith(
                status: ChildContact.error, errorMessage: "failed to fetch posts"));
          }
          else{
            return;
          }
        }
      }
    });
  }
}
