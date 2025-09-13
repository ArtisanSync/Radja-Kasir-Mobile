import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/services/service_utils.dart';

class SubscriptionServices {
  late final Dio _dio;

  SubscriptionServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  // Get all subscription packages
  Future<Map<String, dynamic>> getPackages() async {
    try {
      final response = await _dio.get("$_baseUrl/subscriptions/packages");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'] ?? {},
          'message': response.data['message'] ?? 'Packages loaded successfully'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load packages',
        'data': {}
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': {}
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': {}
      };
    }
  }

  // Get user's current subscription
  Future<Map<String, dynamic>> getMySubscription() async {
    try {
      final response =
          await _dio.get("$_baseUrl/subscriptions/my-subscription");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message':
              response.data['message'] ?? 'Subscription loaded successfully'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load subscription',
        'data': null
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  // Check subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await _dio.get("$_baseUrl/subscriptions/status");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Status loaded successfully'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to load status',
        'data': null
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }
}
