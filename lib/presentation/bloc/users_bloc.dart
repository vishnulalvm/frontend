import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/get_selected_users_usecase.dart';
import '../../domain/usecases/select_user_usecase.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  final GetSelectedUsersUseCase getSelectedUsersUseCase;
  final SelectUserUseCase selectUserUseCase;

  UsersBloc({
    required this.getAllUsersUseCase,
    required this.getSelectedUsersUseCase,
    required this.selectUserUseCase,
  }) : super(UsersInitial()) {
    on<LoadAllUsersEvent>(_onLoadAllUsers);
    on<LoadSelectedUsersEvent>(_onLoadSelectedUsers);
    on<SelectUserEvent>(_onSelectUser);
    on<SearchUsersEvent>(_onSearchUsers);
    on<SearchSelectedUsersEvent>(_onSearchSelectedUsers);
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final users = await getAllUsersUseCase(forceRefresh: event.forceRefresh);
      emit(AllUsersLoaded(users: users, filteredUsers: users));
    } catch (e) {
      emit(UsersError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadSelectedUsers(
    LoadSelectedUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final users = await getSelectedUsersUseCase();
      emit(SelectedUsersLoaded(users: users));
    } catch (e) {
      emit(UsersError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSelectUser(
    SelectUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    try {
      await selectUserUseCase(event.userId);
      // Reload selected users after selection
      add(LoadSelectedUsersEvent());
    } catch (e) {
      emit(UsersError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state is AllUsersLoaded) {
      final currentState = state as AllUsersLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredUsers: currentState.users,
          searchQuery: '',
        ));
      } else {
        final filteredUsers = currentState.users.where((user) {
          return user.username.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }).toList();

        emit(currentState.copyWith(
          filteredUsers: filteredUsers,
          searchQuery: query,
        ));
      }
    }
  }

  Future<void> _onSearchSelectedUsers(
    SearchSelectedUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state is SelectedUsersLoaded) {
      final currentState = state as SelectedUsersLoaded;
      final query = event.query.toLowerCase();

      print('🔍 Search Query: "$query"');
      print('📋 Total Users: ${currentState.users.length}');

      if (query.isEmpty) {
        print('✅ Resetting search - showing all ${currentState.users.length} users');
        emit(currentState.copyWith(
          filteredUsers: currentState.users,
          searchQuery: '',
        ));
      } else {
        final filteredUsers = currentState.users.where((user) {
          return user.username.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }).toList();

        print('✅ Filtered Results: ${filteredUsers.length} users');
        filteredUsers.forEach((user) => print('  - ${user.username}'));

        emit(currentState.copyWith(
          filteredUsers: filteredUsers,
          searchQuery: query,
        ));
      }
    } else {
      print('❌ Current state is not SelectedUsersLoaded: ${state.runtimeType}');
    }
  }
}
