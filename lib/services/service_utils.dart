import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ServiceUtils {
  final String webUrl = 'http://localhost:3000/api/v1';
  final String baseUrl =
      'https://radjakasir-api-680795216338.asia-southeast2.run.app/api/v1';

  static final ServiceUtils _instance = ServiceUtils._internal();

  factory ServiceUtils() {
    return _instance;
  }

  ServiceUtils._internal();
  static Map<String, dynamic> handleDioError(DioException e, String defaultMessage) {
    debugPrint('DioException: ${e.message}');
    return {
      'success': false,
      'message': e.response?.data?['message'] ?? defaultMessage,
      'data': null,
    };
  }
}