import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:soqchi/api/parent_repository.dart';

import '../../api/child_model.dart';

part 'dash_event.dart';
part 'dash_state.dart';

class DashBloc extends Bloc<DashEvent, DashState> {
  DashBloc() : super(DashInitial()) {
    on<DashEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<DashLoadingData>((event, emit) async {
      emit(DashLoading());
      // await Future.delayed(Duration(seconds: 3), () {
      //   // Your code
      // });
      try{
        final test = await ParentRepository().postSavedPosts();
        final result = await ParentRepository().getChilds();
        print(result);
        if (result == null){
          emit(DashExpired());
        }
        else if(result.length == 0){
          emit(DashEmpty());
        }
        else if(result != []){
          emit(DashSuccess(childList: result));
        }
        else{
          emit(DashError());
        }
      }
      catch(e){
          print(e.toString());
          emit(DashError());
      }
    });
  }
}
