import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/chat_local_data_source.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/datasources/profile_local_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/datasources/users_local_data_source.dart';
import '../../data/datasources/users_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/users_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/users_repository.dart';
import '../../domain/usecases/connect_websocket_usecase.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/get_selected_users_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/mark_messages_read_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/select_user_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/chat_bloc.dart';
import '../../presentation/bloc/online_status_bloc.dart';
import '../../presentation/bloc/profile_bloc.dart';
import '../../presentation/bloc/users_bloc.dart';
import '../constants/api_constants.dart';
import '../services/websocket_service.dart';

class Injection {
  static Dio? _dio;
  static SharedPreferences? _sharedPreferences;
  static WebSocketService? _webSocketService;
  static AuthRemoteDataSource? _authRemoteDataSource;
  static AuthLocalDataSource? _authLocalDataSource;
  static AuthRepository? _authRepository;
  static ProfileRemoteDataSource? _profileRemoteDataSource;
  static ProfileLocalDataSource? _profileLocalDataSource;
  static ProfileRepository? _profileRepository;
  static UsersRemoteDataSource? _usersRemoteDataSource;
  static UsersLocalDataSource? _usersLocalDataSource;
  static UsersRepository? _usersRepository;
  static ChatRemoteDataSource? _chatRemoteDataSource;
  static ChatLocalDataSource? _chatLocalDataSource;
  static ChatRepository? _chatRepository;
  static LoginUseCase? _loginUseCase;
  static RegisterUseCase? _registerUseCase;
  static LogoutUseCase? _logoutUseCase;
  static GetCurrentUserUseCase? _getCurrentUserUseCase;
  static GetProfileUseCase? _getProfileUseCase;
  static GetAllUsersUseCase? _getAllUsersUseCase;
  static GetSelectedUsersUseCase? _getSelectedUsersUseCase;
  static SelectUserUseCase? _selectUserUseCase;
  static GetChatHistoryUseCase? _getChatHistoryUseCase;
  static SendMessageUseCase? _sendMessageUseCase;
  static MarkMessagesReadUseCase? _markMessagesReadUseCase;
  static ConnectWebSocketUseCase? _connectWebSocketUseCase;
  static AuthBloc? _authBloc;
  static ProfileBloc? _profileBloc;
  static UsersBloc? _usersBloc;
  static OnlineStatusBloc? _onlineStatusBloc;

  static Future<void> init() async {
    // Initialize SharedPreferences
    _sharedPreferences ??= await SharedPreferences.getInstance();

    // Initialize Dio
    _dio ??= Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: ApiConstants.headers,
      ),
    );

    // Initialize WebSocket Service
    _webSocketService ??= WebSocketService(baseUrl: ApiConstants.socketUrl);

    // Data sources
    _authRemoteDataSource ??= AuthRemoteDataSourceImpl(dio: _dio!);
    _authLocalDataSource ??= AuthLocalDataSourceImpl(sharedPreferences: _sharedPreferences!);
    _profileRemoteDataSource ??= ProfileRemoteDataSourceImpl(dio: _dio!);
    _profileLocalDataSource ??= ProfileLocalDataSourceImpl(sharedPreferences: _sharedPreferences!);
    _usersRemoteDataSource ??= UsersRemoteDataSourceImpl(dio: _dio!);
    _usersLocalDataSource ??= UsersLocalDataSourceImpl(sharedPreferences: _sharedPreferences!);
    _chatRemoteDataSource ??= ChatRemoteDataSourceImpl(dio: _dio!);
    _chatLocalDataSource ??= ChatLocalDataSourceImpl(sharedPreferences: _sharedPreferences!);

    // Repository
    _authRepository ??= AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource!,
      localDataSource: _authLocalDataSource!,
    );
    _profileRepository ??= ProfileRepositoryImpl(
      remoteDataSource: _profileRemoteDataSource!,
      localDataSource: _profileLocalDataSource!,
      authRepository: _authRepository!,
    );
    _usersRepository ??= UsersRepositoryImpl(
      remoteDataSource: _usersRemoteDataSource!,
      localDataSource: _usersLocalDataSource!,
      authRepository: _authRepository!,
    );
    _chatRepository ??= ChatRepositoryImpl(
      remoteDataSource: _chatRemoteDataSource!,
      localDataSource: _chatLocalDataSource!,
      webSocketService: _webSocketService!,
      authRepository: _authRepository!,
    );

    // Use cases
    _loginUseCase ??= LoginUseCase(repository: _authRepository!);
    _registerUseCase ??= RegisterUseCase(repository: _authRepository!);
    _logoutUseCase ??= LogoutUseCase(repository: _authRepository!);
    _getCurrentUserUseCase ??= GetCurrentUserUseCase(repository: _authRepository!);
    _getProfileUseCase ??= GetProfileUseCase(repository: _profileRepository!);
    _getAllUsersUseCase ??= GetAllUsersUseCase(repository: _usersRepository!);
    _getSelectedUsersUseCase ??= GetSelectedUsersUseCase(repository: _usersRepository!);
    _selectUserUseCase ??= SelectUserUseCase(repository: _usersRepository!);
    _getChatHistoryUseCase ??= GetChatHistoryUseCase(repository: _chatRepository!);
    _sendMessageUseCase ??= SendMessageUseCase(repository: _chatRepository!);
    _markMessagesReadUseCase ??= MarkMessagesReadUseCase(repository: _chatRepository!);
    _connectWebSocketUseCase ??= ConnectWebSocketUseCase(repository: _chatRepository!);

    // BLoC
    _authBloc ??= AuthBloc(
      loginUseCase: _loginUseCase!,
      registerUseCase: _registerUseCase!,
      logoutUseCase: _logoutUseCase!,
      getCurrentUserUseCase: _getCurrentUserUseCase!,
    );
    _profileBloc ??= ProfileBloc(
      getProfileUseCase: _getProfileUseCase!,
    );
    _usersBloc ??= UsersBloc(
      getAllUsersUseCase: _getAllUsersUseCase!,
      getSelectedUsersUseCase: _getSelectedUsersUseCase!,
      selectUserUseCase: _selectUserUseCase!,
    );
  }

  // Getters
  static AuthBloc get authBloc => _authBloc!;
  static ProfileBloc get profileBloc {
    return ProfileBloc(getProfileUseCase: _getProfileUseCase!);
  }
  static UsersBloc get usersBloc {
    _usersBloc ??= UsersBloc(
      getAllUsersUseCase: _getAllUsersUseCase!,
      getSelectedUsersUseCase: _getSelectedUsersUseCase!,
      selectUserUseCase: _selectUserUseCase!,
    );
    return _usersBloc!;
  }
  static ChatBloc get chatBloc {
    return ChatBloc(
      getChatHistoryUseCase: _getChatHistoryUseCase!,
      sendMessageUseCase: _sendMessageUseCase!,
      markMessagesReadUseCase: _markMessagesReadUseCase!,
      connectWebSocketUseCase: _connectWebSocketUseCase!,
      chatRepository: _chatRepository!,
    );
  }
  static OnlineStatusBloc get onlineStatusBloc {
    _onlineStatusBloc ??= OnlineStatusBloc(
      webSocketService: _webSocketService!,
    );
    return _onlineStatusBloc!;
  }
  static Dio get dio => _dio!;
  static SharedPreferences get sharedPreferences => _sharedPreferences!;
  static WebSocketService get webSocketService => _webSocketService!;
}
