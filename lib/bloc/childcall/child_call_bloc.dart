import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:soqchi/api/child_call_list_model.dart';

import '../../api/parent_repository.dart';

part 'child_call_event.dart';
part 'child_call_state.dart';

class ChildCallBloc extends Bloc<ChildCallEvent, ChildCallState> {
  ChildCallBloc() : super(ChildCallState()) {
    on<ChildCallEvent>((event, emit) async{

      if (event is ReloadChildCallEvent) {
        print("ReloadChildCallEvent");
        emit(state.copyWith(
            nextPageUrl: "",
            status: ChildCall.loading, islast: false,
            calls: []
        ));
        print("call_response");
        final call_response = await ParentRepository().getchildcall(event.childuid,state.nextPageUrl,event.date);
        print("call_response");
        if(call_response == null){
          return emit(state.copyWith(
              status: ChildCall.expired, islast: true));
        }
        else {
          return call_response!.calls!.data!.isEmpty
              ?emit(state.copyWith(
              status: ChildCall.success, islast: true))
              : emit(state.copyWith(
              nextPageUrl: call_response.calls!.nextPageUrl,
              status: ChildCall.success,
              calls: List.of(state.calls)..addAll(call_response.calls!.data!),
              islast: call_response.calls!.nextPageUrl == null ? true : false));
        }
      }

      if (event is GetChildCallEvent) {
        if (state.islast) return;
        try {
          if (state.status == ChildCall.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final call_response =  await ParentRepository().getchildcall(event.childuid,state.nextPageUrl,event.date);
            if(call_response == null){
              return emit(state.copyWith(
                  status: ChildCall.expired, islast: true));
            }
            else{
              return call_response!.calls!.data!.isEmpty
                  ? emit(state.copyWith(
                  status: ChildCall.success, islast: true))
                  : emit(state.copyWith(
                  status: ChildCall.success,
                  nextPageUrl: call_response.calls!.nextPageUrl,
                  calls: call_response.calls!.data!,
                  islast: call_response.calls!.nextPageUrl == null ? true : false));
            }
          } else {
            final call_response =  await ParentRepository().getchildcall(event.childuid,state.nextPageUrl,event.date);
            if(call_response == null){
              return emit(state.copyWith(
                  status: ChildCall.expired, islast: true));
            }
            else {
              return call_response!.calls!.data!.isEmpty
                  ? emit(state.copyWith(islast: true))
                  : emit(state.copyWith(
                  nextPageUrl: call_response.calls!.nextPageUrl,
                  status: ChildCall.success,
                  calls: List.of(state.calls)..addAll(call_response.calls!.data!),
                  islast: call_response.calls!.nextPageUrl == null ? true : false));
            }
          }
        } catch (e) {
          if(state.status == ChildCall.loading){
            return emit(state.copyWith(
                status: ChildCall.error, errorMessage: "failed to fetch posts"));
          }
          else{
            return;
          }
        }
      }
    });
  }
}
