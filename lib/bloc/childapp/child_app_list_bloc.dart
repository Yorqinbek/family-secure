import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/child_app_list_model.dart';
import '../../api/parent_repository.dart';

part 'child_app_list_event.dart';
part 'child_app_list_state.dart';

class ChildAppListBloc extends Bloc<ChildAppEvent, ChildAppState> {
  ChildAppListBloc() : super(ChildAppState()) {
    on<ChildAppEvent>((event, emit) async{
      if (event is GetChildAppEvent) {
        if (state.islast) return;
        try {
          if (state.status == ChildApp.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final app_response =  await ParentRepository().getchildapp(event.childuid,state.nextPageUrl);
            if(app_response == null){
              return emit(state.copyWith(
                  status: ChildApp.expired, islast: true));
            }
            else{
              return app_response!.apps!.data!.isEmpty
                  ? emit(state.copyWith(
                  status: ChildApp.success, islast: true))
                  : emit(state.copyWith(
                  status: ChildApp.success,
                  nextPageUrl: app_response.apps!.nextPageUrl,
                  apps: app_response.apps!.data!,
                  islast: app_response.apps!.nextPageUrl == null ? true : false));
            }
          } else {
            final app_response =  await ParentRepository().getchildapp(event.childuid,state.nextPageUrl);
            if(app_response == null){
              return emit(state.copyWith(
                  status: ChildApp.expired, islast: true));
            }
            else {
              return app_response!.apps!.data!.isEmpty
                  ? emit(state.copyWith(islast: true))
                  : emit(state.copyWith(
                  nextPageUrl: app_response.apps!.nextPageUrl,
                  status: ChildApp.success,
                  apps: List.of(state.apps)..addAll(app_response.apps!.data!),
                  islast: app_response.apps!.nextPageUrl == null ? true : false));
            }
          }
        } catch (e) {
          if(state.status == ChildApp.loading){
            return emit(state.copyWith(
                status: ChildApp.error, errorMessage: "failed to fetch posts"));
          }
          else{
            return;
          }
        }
      }
    });
  }
}
