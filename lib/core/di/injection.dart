import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../constants/api_constants.dart';

class Injection {
  static Dio? _dio;
  static SharedPreferences? _sharedPreferences;
  static AuthRemoteDataSource? _authRemoteDataSource;
  static AuthLocalDataSource? _authLocalDataSource;
  static AuthRepository? _authRepository;
  static LoginUseCase? _loginUseCase;
  static RegisterUseCase? _registerUseCase;
  static LogoutUseCase? _logoutUseCase;
  static AuthBloc? _authBloc;

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

    // Data sources
    _authRemoteDataSource ??= AuthRemoteDataSourceImpl(dio: _dio!);
    _authLocalDataSource ??= AuthLocalDataSourceImpl(sharedPreferences: _sharedPreferences!);

    // Repository
    _authRepository ??= AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource!,
      localDataSource: _authLocalDataSource!,
    );

    // Use cases
    _loginUseCase ??= LoginUseCase(repository: _authRepository!);
    _registerUseCase ??= RegisterUseCase(repository: _authRepository!);
    _logoutUseCase ??= LogoutUseCase(repository: _authRepository!);

    // BLoC
    _authBloc ??= AuthBloc(
      loginUseCase: _loginUseCase!,
      registerUseCase: _registerUseCase!,
      logoutUseCase: _logoutUseCase!,
    );
  }

  // Getters
  static AuthBloc get authBloc => _authBloc!;
  static Dio get dio => _dio!;
  static SharedPreferences get sharedPreferences => _sharedPreferences!;
}
