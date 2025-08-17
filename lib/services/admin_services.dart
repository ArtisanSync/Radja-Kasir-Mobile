import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/services/service_utils.dart';

class AdminServices {
  late final Dio _dio;

  AdminServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      developer.log('Fetching dashboard stats from: $_baseUrl/admin/dashboard');
      
      final response = await _dio.get("$_baseUrl/admin/dashboard");
      
      developer.log('Dashboard response: ${response.data}');
      
      // Check if response is successful
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle both success field check and direct data
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success')) {
            if (data['success'] == true) {
              developer.log('Dashboard data received successfully');
              return {
                'success': true,
                'data': data['data'],
                'message': data['message'] ?? 'Dashboard loaded successfully'
              };
            } else {
              developer.log('API returned success: false - ${data['message']}');
              return {
                'success': false,
                'message': data['message'] ?? 'API returned error',
                'data': null
              };
            }
          } else {
            // Direct data without success wrapper
            developer.log('Direct data received without success wrapper');
            return {
              'success': true,
              'data': data,
              'message': 'Dashboard loaded successfully'
            };
          }
        }
      }
      
      developer.log('Invalid response format or status code: ${response.statusCode}');
      return {
        'success': false,
        'message': 'Invalid response format',
        'data': null
      };
      
    } on DioException catch (e) {
      developer.log('DioException in getDashboardStats: ${e.toString()}');
      developer.log('Response data: ${e.response?.data}');
      
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error: ${e.message}',
        'data': null
      };
    } catch (e) {
      developer.log('General exception in getDashboardStats: ${e.toString()}');
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> getAllSubscribers({
    String? search,
    String? packageType,
    bool? expiringOnly,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (packageType != null) queryParams['packageType'] = packageType;
      if (expiringOnly == true) queryParams['expiringOnly'] = 'true';

      developer.log('Fetching subscribers from: $_baseUrl/admin/subscribers');
      developer.log('Query params: $queryParams');

      final response = await _dio.get(
        "$_baseUrl/admin/subscribers",
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      developer.log('Subscribers response: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success')) {
            if (data['success'] == true) {
              return {
                'success': true,
                'data': data['data'] ?? [],
                'message': data['message'] ?? 'Subscribers loaded successfully'
              };
            } else {
              return {
                'success': false,
                'message': data['message'] ?? 'Failed to load subscribers',
                'data': []
              };
            }
          } else {
            // Direct array data
            return {
              'success': true,
              'data': data is List ? data : [data],
              'message': 'Subscribers loaded successfully'
            };
          }
        }
      }
      
      return {
        'success': false,
        'message': 'Invalid response format',
        'data': []
      };
      
    } on DioException catch (e) {
      developer.log('DioException in getAllSubscribers: ${e.toString()}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error: ${e.message}',
        'data': []
      };
    } catch (e) {
      developer.log('General exception in getAllSubscribers: ${e.toString()}');
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'data': []
      };
    }
  }

  Future<Map<String, dynamic>> extendUserSubscription(String userId, int additionalDays) async {
    try {
      final response = await _dio.put(
        "$_baseUrl/admin/users/$userId/extend",
        data: {'additionalDays': additionalDays},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'] ?? true,
          'data': data['data'],
          'message': data['message'] ?? 'Subscription extended successfully'
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to extend subscription',
        'data': null
      };
      
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error occurred',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> deleteUserAccount(String userId) async {
    try {
      final response = await _dio.delete("$_baseUrl/admin/users/$userId");
      
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'] ?? true,
          'data': data['data'],
          'message': data['message'] ?? 'User deleted successfully'
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to delete user',
        'data': null
      };
      
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error occurred',
        'data': null
      };
    }
  }
}
