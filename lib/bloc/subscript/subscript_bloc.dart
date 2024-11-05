import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/parent_repository.dart';
import '../../api/user_model.dart';

part 'subscript_event.dart';
part 'subscript_state.dart';

class SubscriptBloc extends Bloc<SubscriptEvent, SubscriptState> {
  SubscriptBloc() : super(SubscriptInitial()) {
    on<SubscriptEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<SubscriptLoadingData>((event, emit) async {
      emit(SubscriptLoading());
      // await Future.delayed(Duration(seconds: 3), () {
      //   // Your code
      // });
      try{
        final result = await ParentRepository().get_sub();
        if (result != null){
          emit(SubscriptSuccess(userModel: result));
        }
        else if(result == null){
          emit(SubscriptExpired());
        }
        else{
          emit(SubscriptError());
        }
      }
      catch(e){
        print(e.toString());
        emit(SubscriptError());
      }
    });
  }
}
