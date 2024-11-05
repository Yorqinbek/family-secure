import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/child_app_usage_list_model.dart';
import '../../api/parent_repository.dart';

part 'child_app_usage_event.dart';
part 'child_app_usage_state.dart';

class ChildAppUsageBloc extends Bloc<ChildAppUsageEvent, ChildAppUsageState> {
  ChildAppUsageBloc() : super(ChildAppUsageState()) {
    on<ChildAppUsageEvent>((event, emit) async{
      if (event is ReloadChildAppUsageEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: ChildAppUsage.loading, islast: false,
            apps: []
        ));
        final call_response =  await ParentRepository().getchildappusage(event.childuid,state.nextPageUrl,event.date);
        if(call_response == null){
          return emit(state.copyWith(
              status: ChildAppUsage.expired, islast: true));
        }
        else {
          return call_response!.appsUsage!.data!.isEmpty
              ?emit(state.copyWith(
              status: ChildAppUsage.success, islast: true))
              : emit(state.copyWith(
              nextPageUrl: call_response.appsUsage!.nextPageUrl,
              status: ChildAppUsage.success,
              apps: List.of(state.apps)..addAll(call_response.appsUsage!.data!),
              islast: call_response.appsUsage!.nextPageUrl == null ? true : false));
        }
      }
      if (event is GetChildAppUsageEvent) {
        if (state.islast) return;
        try {
          if (state.status == ChildAppUsage.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final app_usage_response =  await ParentRepository().getchildappusage(event.childuid,state.nextPageUrl,event.date);
            if(app_usage_response == null){
              return emit(state.copyWith(
                  status: ChildAppUsage.expired, islast: true));
            }
            else{
              return app_usage_response!.appsUsage!.data!.isEmpty
                  ? emit(state.copyWith(
                  status: ChildAppUsage.success, islast: true))
                  : emit(state.copyWith(
                  status: ChildAppUsage.success,
                  nextPageUrl: app_usage_response.appsUsage!.nextPageUrl,
                  apps: app_usage_response.appsUsage!.data!,
                  islast: app_usage_response.appsUsage!.nextPageUrl == null ? true : false));
            }
          } else {
            final app_usage_response =  await ParentRepository().getchildappusage(event.childuid,state.nextPageUrl,event.date);
            if(app_usage_response == null){
              return emit(state.copyWith(
                  status: ChildAppUsage.expired, islast: true));
            }
            else {
              return app_usage_response!.appsUsage!.data!.isEmpty
                  ? emit(state.copyWith(islast: true))
                  : emit(state.copyWith(
                  nextPageUrl: app_usage_response.appsUsage!.nextPageUrl,
                  status: ChildAppUsage.success,
                  apps: List.of(state.apps)..addAll(app_usage_response.appsUsage!.data!),
                  islast: app_usage_response.appsUsage!.nextPageUrl == null ? true : false));
            }
          }
        } catch (e) {
          if(state.status == ChildAppUsage.loading){
            return emit(state.copyWith(
                status: ChildAppUsage.error, errorMessage: "failed to fetch posts"));
          }
          else{
            return;
          }
        }
      }
    });
  }
}
