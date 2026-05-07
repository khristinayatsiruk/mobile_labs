import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luna_app/services/api_service.dart';

class HomeState {
  final List<dynamic> tips;
  final bool isLoading;

  HomeState({this.tips = const [], this.isLoading = false});
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  // Виклик АПІ перенесено сюди з віджетів
  Future<void> fetchHomeData() async {
    emit(HomeState(tips: state.tips, isLoading: true));
    try {
      final tips = await ApiService.getTips();
      emit(HomeState(tips: tips));
    } catch (e) {
      emit(HomeState(tips: []));
    }
  }
}
