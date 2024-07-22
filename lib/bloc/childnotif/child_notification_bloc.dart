import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/child_notification_model.dart';
import '../../api/parent_repository.dart';

part 'child_notification_event.dart';
part 'child_notification_state.dart';

class ChildNotificationBloc extends Bloc<ChildNotificationEvent, ChildNotificationState> {
  ChildNotificationBloc() : super(ChildNotificationState()) {

    // on<ChildNotificationEvent>((event, emit) {
    //   if (event is GetChildNotificationEvent) {
    //     if (state.hasReachedMax) return;
    //   }
    //   // TODO: implement event handler
    // });

    on<ChildNotificationEvent>((event, emit) async {
      if (event is ReloadChildNotificationEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: ChildNotification.loading, islast: false,
            notification: []
        ));
        final notification =  await ParentRepository().getchildnotif(event.childuid,state.nextPageUrl,event.date);
        if(notification == null){
          return emit(state.copyWith(
              status: ChildNotification.expired, islast: true));
        }
        else {
          return notification!.notif!.data!.isEmpty
              ?emit(state.copyWith(
              status: ChildNotification.success, islast: true))
              : emit(state.copyWith(
              nextPageUrl: notification.notif!.nextPageUrl,
              status: ChildNotification.success,
              notification: List.of(state.notification!)..addAll(notification.notif!.data!),
              islast: notification.notif!.nextPageUrl == null ? true : false));
        }
      }
      if (event is GetChildNotificationEvent) {
        if (state.islast) return;
        try {
            if (state.status == ChildNotification.loading) {
              print("state.status == ChildNotification.loading");
              // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
              final notification =  await ParentRepository().getchildnotif(event.childuid,state.nextPageUrl,event.date);

              print(notification);// print(notification!.notif!.nextPageUrl);
              if(notification == null){
                return emit(state.copyWith(
                    status: ChildNotification.expired, islast: true,notification: null));
              }
              else{
                return notification!.notif!.data!.isEmpty
                    ? emit(state.copyWith(
                    status: ChildNotification.success, islast: true))
                    : emit(state.copyWith(
                    status: ChildNotification.success,
                    nextPageUrl: notification.notif!.nextPageUrl,
                    notification: notification.notif!.data!,
                    islast: notification.notif!.nextPageUrl == null ? true : false));
              }
            } else {
              final notification =  await ParentRepository().getchildnotif(event.childuid,state.nextPageUrl,event.date);
              if(notification == null){
                return emit(state.copyWith(status: ChildNotification.success,islast: true,notification: null));
              }
              else {
                return notification!.notif!.data!.isEmpty
                    ? emit(state.copyWith(islast: true))
                    : emit(state.copyWith(
                    nextPageUrl: notification.notif!.nextPageUrl,
                    status: ChildNotification.success,
                    notification: List.of(state.notification!)..addAll(notification.notif!.data!),
                    islast: notification.notif!.nextPageUrl == null ? true : false));
              }
            }
        } catch (e) {
          if(state.status == ChildNotification.loading){
            return emit(state.copyWith(
                status: ChildNotification.error, errorMessage: "failed to fetch posts"));
          }
          else{
            return;
          }
        }
      }
    });

    // on<ChildNotificationLoadingData>((event, emit) async{
    //   // await Future.delayed(Duration(seconds: 3), () {
    //   //   // Your code
    //   // });
    //   if(next_page_url == ''){
    //     emit(ChildNotificationLoading());
    //     print(next_page_url);
    //     try{
    //       final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
    //       if (result == null){
    //         emit(ChildNotificationExpired());
    //       }
    //       else if(result.notif!.data!.length == 0){
    //         emit(ChildNotificationEmpty());
    //       }
    //       else if(result.notif!.data! != []){
    //         data.addAll(result.notif!.data!);
    //         next_page_url = result.notif!.nextPageUrl!;
    //         emit(ChildNotificationSuccess(data: data));
    //       }
    //       else{
    //         emit(ChildNotificationError());
    //       }
    //     }
    //     catch(e){
    //       emit(ChildNotificationError());
    //     }
    //   }
    //   else{
    //     try{
    //       final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
    //       if(result!.notif!.data! != []){
    //         next_page_url = result.notif!.nextPageUrl!;
    //         data.addAll(result.notif!.data!);
    //         emit(ChildNotificationSuccess(data: data));
    //       }
    //       else{
    //         emit(ChildNotificationSuccess(data: data));
    //       }
    //     }
    //     catch(e){
    //       emit(ChildNotificationSuccess(data: data));
    //     }
    //   }
    // });
  }
}
