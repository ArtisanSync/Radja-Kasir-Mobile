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

  // Dashboard endpoint
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      developer.log('Fetching dashboard stats from: $_baseUrl/admin/dashboard');
      
      final response = await _dio.get("$_baseUrl/admin/dashboard");
      
      developer.log('Dashboard response: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
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

  // Subscribers endpoint - GET /subscribers
  Future<Map<String, dynamic>> getAllActiveSubscribers({
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
      developer.log('DioException in getAllActiveSubscribers: ${e.toString()}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error: ${e.message}',
        'data': []
      };
    } catch (e) {
      developer.log('General exception in getAllActiveSubscribers: ${e.toString()}');
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'data': []
      };
    }
  }

  // User deletion endpoint - DELETE /users/:userId
  Future<Map<String, dynamic>> removeUserAccount(String userId) async {
    try {
      developer.log('Deleting user account: $_baseUrl/admin/users/$userId');
      
      final response = await _dio.delete("$_baseUrl/admin/users/$userId");
      
      developer.log('Delete user response: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'] ?? true,
          'data': data['data'],
          'message': data['message'] ?? 'User account deleted successfully'
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to delete user account',
        'data': null
      };
      
    } on DioException catch (e) {
      developer.log('DioException in removeUserAccount: ${e.toString()}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      developer.log('General exception in removeUserAccount: ${e.toString()}');
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'data': null
      };
    }
  }

  // Change subscription endpoint - PUT /users/:userId/subscription
  Future<Map<String, dynamic>> changeUserSubscription(String userId, String packageId) async {
    try {
      developer.log('Changing user subscription: $_baseUrl/admin/users/$userId/subscription');
      
      final response = await _dio.put(
        "$_baseUrl/admin/users/$userId/subscription",
        data: {'packageId': packageId},
      );
      
      developer.log('Change subscription response: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'] ?? true,
          'data': data['data'],
          'message': data['message'] ?? 'Subscription changed successfully'
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to change subscription',
        'data': null
      };
      
    } on DioException catch (e) {
      developer.log('DioException in changeUserSubscription: ${e.toString()}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      developer.log('General exception in changeUserSubscription: ${e.toString()}');
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'data': null
      };
    }
  }

  // Extend subscription endpoint - PUT /users/:userId/extend
  Future<Map<String, dynamic>> extendUserSubscription(String userId, int additionalDays) async {
    try {
      developer.log('Extending user subscription: $_baseUrl/admin/users/$userId/extend');
      
      final response = await _dio.put(
        "$_baseUrl/admin/users/$userId/extend",
        data: {'additionalDays': additionalDays},
      );
      
      developer.log('Extend subscription response: ${response.data}');
      
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
      developer.log('DioException in extendUserSubscription: ${e.toString()}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      developer.log('General exception in extendUserSubscription: ${e.toString()}');
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'data': null
      };
    }
  }

  // Remove store member endpoint - DELETE /members/:memberId
  Future<Map<String, dynamic>> removeStoreMember(String memberId) async {
    try {
      developer.log('Removing store member: $_baseUrl/admin/members/$memberId');
      
      final response = await _dio.delete("$_baseUrl/admin/members/$memberId");
      
      developer.log('Remove member response: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'] ?? true,
          'data': data['data'],
          'message': data['message'] ?? 'Store member removed successfully'
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to remove store member',
        'data': null
      };
      
    } on DioException catch (e) {
      developer.log('DioException in removeStoreMember: ${e.toString()}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      developer.log('General exception in removeStoreMember: ${e.toString()}');
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
        'data': null
      };
    }
  }

  // Helper method untuk debugging
  void logRequest(String method, String url, dynamic data) {
    developer.log('$method Request to: $url');
    if (data != null) {
      developer.log('Request Data: $data');
    }
  }
}