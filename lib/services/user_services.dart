import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class UserServices {
  late final Dio _dio;

  UserServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  // Get All Users (Admin Only)
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await _dio.get("$_baseUrl/users/profile");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to fetch users'
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 500,
        'message': e.response?.data['message'] ?? 'Failed to fetch users'
      };
    }
  }

  // Create a new store member
  Future<Map<String, dynamic>> createMember(Map<String, dynamic> body) async {
    final store = await Store.getStore();
    try {
      final response = await _dio.post(
        "$_baseUrl/users/${store['id']}/member/store",
        data: body,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to create member'
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': e.response?.data['message'] ?? 'Failed to create member'
      };
    }
  }

  // Delete a store member (Admin Only)
  Future<Map<String, dynamic>> deleteMember(int id) async {
    try {
      final response = await _dio.delete("$_baseUrl/users/member/destroy/$id");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to delete member'
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': e.response?.data['message'] ?? 'Failed to delete member'
      };
    }
  }

  // Get User Profile (Authenticated User)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get("$_baseUrl/users/profile");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to get profile'
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': e.response?.data['message'] ?? 'Failed to get profile'
      };
    }
  }

  // Get User Package (Subscription Info)
  Future<Map<String, dynamic>> getPackage(int id) async {
    try {
      final response = await _dio.get("$_baseUrl/users/package/$id");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to fetch package'
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': e.response?.data['message'] ?? 'Failed to fetch package'
      };
    }
  }
}