import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import '../../api/child_web_block_list_model.dart';
import '../../api/parent_repository.dart';
part 'child_web_event.dart';
part 'child_web_state.dart';

class ChildWebBloc extends Bloc<ChildWebEvent, ChildWebState> {
  ChildWebBloc() : super(ChildWebState()) {
    on<ChildWebEvent>((event, emit) async{
      if (event is ReloadChildWebEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: ChildWeb.loading, islast: false,
            websites: []
        ));
        final web_response =  await ParentRepository().getchildweb(event.childuid,state.nextPageUrl);
        if(web_response == null){
          return emit(state.copyWith(
              status: ChildWeb.expired, islast: true));
        }
        else {
          return web_response!.websites!.data!.isEmpty
              ?emit(state.copyWith(
              status: ChildWeb.success, islast: true))
              : emit(state.copyWith(
              nextPageUrl: web_response.websites!.nextPageUrl,
              status: ChildWeb.success,
              websites: List.of(state.websites)..addAll(web_response.websites!.data!),
              islast: web_response.websites!.nextPageUrl == null ? true : false));
        }
      }

      if (event is GetChildWebEvent) {
        if (state.islast) return;
        try {
          if (state.status == ChildWeb.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final web_response =  await ParentRepository().getchildweb(event.childuid,state.nextPageUrl);
            if(web_response == null){
              return emit(state.copyWith(
                  status: ChildWeb.expired, islast: true));
            }
            else{
              return web_response!.websites!.data!.isEmpty
                  ? emit(state.copyWith(
                  status: ChildWeb.success, islast: true))
                  : emit(state.copyWith(
                  status: ChildWeb.success,
                  nextPageUrl: web_response.websites!.nextPageUrl,
                  websites: web_response.websites!.data!,
                  islast: web_response.websites!.nextPageUrl == null ? true : false));
            }
          } else {
            final web_response =  await ParentRepository().getchildweb(event.childuid,state.nextPageUrl);
            if(web_response == null){
              return emit(state.copyWith(
                  status: ChildWeb.expired, islast: true));
            }
            else {
              return web_response!.websites!.data!.isEmpty
                  ? emit(state.copyWith(islast: true))
                  : emit(state.copyWith(
                  nextPageUrl: web_response.websites!.nextPageUrl,
                  status: ChildWeb.success,
                  websites: List.of(state.websites)..addAll(web_response.websites!.data!),
                  islast: web_response.websites!.nextPageUrl == null ? true : false));
            }
          }
        } catch (e) {
          if(state.status == ChildWeb.loading){
            return emit(state.copyWith(
                status: ChildWeb.error, errorMessage: "failed to fetch posts"));
          }
          else{
            return;
          }
        }
      }
    });
  }
}
