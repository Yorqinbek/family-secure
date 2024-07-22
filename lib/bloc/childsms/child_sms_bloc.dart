import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:soqchi/api/child_sms_list_model.dart';

import '../../api/parent_repository.dart';

part 'child_sms_event.dart';
part 'child_sms_state.dart';

class ChildSmsBloc extends Bloc<ChildSmsEvent, ChildSmsState> {
  ChildSmsBloc() : super(ChildSmsState()) {
    on<ChildSmsEvent>((event, emit) async{
      if (event is GetChildSmsEvent) {
        if (state.islast) return;
        try {
          if (state.status == ChildSms.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final sms_response =  await ParentRepository().getchildsms(event.childuid,state.nextPageUrl);
            if(sms_response == null){
              return emit(state.copyWith(
                  status: ChildSms.expired, islast: true));
            }
            else{
              return sms_response!.sms!.data!.isEmpty
                  ? emit(state.copyWith(
                  status: ChildSms.success, islast: true))
                  : emit(state.copyWith(
                  status: ChildSms.success,
                  nextPageUrl: sms_response.sms!.nextPageUrl,
                  sms: sms_response.sms!.data!,
                  islast: sms_response.sms!.nextPageUrl == null ? true : false));
            }
          } else {
            final sms_response =  await ParentRepository().getchildsms(event.childuid,state.nextPageUrl);
            if(sms_response == null){
              return emit(state.copyWith(
                  status: ChildSms.expired, islast: true));
            }
            else {
              return sms_response.sms!.data!.isEmpty
                  ? emit(state.copyWith(islast: true))
                  : emit(state.copyWith(
                  nextPageUrl: sms_response.sms!.nextPageUrl,
                  status: ChildSms.success,
                  sms: List.of(state.sms)..addAll(sms_response.sms!.data!),
                  islast: sms_response.sms!.nextPageUrl == null ? true : false));
            }
          }
        } catch (e) {
          if(state.status == ChildSms.loading){
            return emit(state.copyWith(
                status: ChildSms.error, errorMessage: "failed to fetch posts"));
          }
          else{
            return;
          }
        }
      }
    });

    // on<ChildSmsLoadingData>((event, emit) async{
    //   emit(ChildSmsLoading());
    //   // await Future.delayed(Duration(seconds: 3), () {
    //   //   // Your code
    //   // });
    //   try{
    //     final result = await ParentRepository().getchildsms(event.childuid);
    //     if (result == null){
    //       emit(ChildSmsExpired());
    //     }
    //     else if(result.sms!.length == 0){
    //       emit(ChildSmsEmpty());
    //     }
    //     else if(result.sms != []){
    //       emit(ChildSmsSuccess(childSmsListModel: result));
    //     }
    //     else{
    //       emit(ChildSmsError());
    //     }
    //   }
    //   catch(e){
    //     emit(ChildSmsError());
    //   }
    // });
  }

}
