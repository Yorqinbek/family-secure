import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/child_sms_info_model.dart';
import '../../api/parent_repository.dart';

part 'child_sms_info_event.dart';
part 'child_sms_info_state.dart';

class ChildSmsInfoBloc extends Bloc<ChildSmsInfoEvent, ChildSmsInfoState> {
  ChildSmsInfoBloc() : super(ChildSmsInfoState()) {
    on<ChildSmsInfoEvent>((event, emit) async{
      if (event is GetChildSmsInfoEvent) {
        if (state.islast) return;
        try {
          if (state.status == ChildSmsInfo.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final sms_response =  await ParentRepository().getchildsmsinfo(event.childuid,event.sender,state.nextPageUrl);
            return sms_response!.messages!.data!.isEmpty
                ? emit(state.copyWith(
                status: ChildSmsInfo.success, islast: true))
                : emit(state.copyWith(
                status: ChildSmsInfo.success,
                nextPageUrl: sms_response.messages!.nextPageUrl,
                messages: sms_response.messages!.data!,
                islast: sms_response.messages!.nextPageUrl == null ? true : false));
          } else {
            final sms_response =  await ParentRepository().getchildsmsinfo(event.childuid,event.sender,state.nextPageUrl);
            if(sms_response == null){
              return emit(state.copyWith(islast: true));
            }
            else {
              return sms_response!.messages!.data!.isEmpty
                  ? emit(state.copyWith(islast: true))
                  : emit(state.copyWith(
                  nextPageUrl: sms_response.messages!.nextPageUrl,
                  status: ChildSmsInfo.success,
                  messages: List.of(state.messages)..addAll(sms_response.messages!.data!),
                  islast: sms_response.messages!.nextPageUrl == null ? true : false));
            }
          }
        } catch (e) {
          if(state.status == ChildSmsInfo.loading){
            return emit(state.copyWith(
                status: ChildSmsInfo.error, errorMessage: "failed to fetch posts"));
          }
          else{
            return;
          }
        }
      }
    });
  }
}
