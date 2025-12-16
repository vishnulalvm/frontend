class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://chat-backend-r9cf.onrender.com';

  // Socket URL (same as base URL for socket.io)
  static const String socketUrl = 'https://chat-backend-r9cf.onrender.com';

  // API Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String profile = '/api/users/profile';
  static const String users = '/api/users';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Cache duration
  static const Duration cacheValidDuration = Duration(minutes: 5);
}
