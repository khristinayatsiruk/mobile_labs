import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luna_app/repositories/auth_repository.dart';

class ProfileState {
  final String name;
  final String email;
  final bool isLoading;

  ProfileState({this.name = '', this.email = '', this.isLoading = false});
}

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository authRepo;

  ProfileCubit(this.authRepo) : super(ProfileState());

  Future<void> loadUserProfile() async {
    emit(ProfileState(isLoading: true));
    final user = await authRepo.getCurrentUser();

    if (user != null) {
      emit(
        ProfileState(
          name: user.name,
          email: user.email,
        ),
      );
    }
  }

  void updateName(String newName) {
    emit(ProfileState(name: newName, email: state.email));
  }
}
