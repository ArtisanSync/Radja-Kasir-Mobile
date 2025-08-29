class ServiceUtils {
  final String webUrl = 'http://localhost:3000/api/v1';
  final String baseUrl =
      'https://radjakasir-api-680795216338.asia-southeast2.run.app/api/v1';

  static final ServiceUtils _instance = ServiceUtils._internal();

  factory ServiceUtils() {
    return _instance;
  }

  ServiceUtils._internal();
}
