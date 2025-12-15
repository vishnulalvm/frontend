class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:3000';

  // API Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
