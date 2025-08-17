// services/auth_services.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AuthServices {
  late final Dio _dio;

  AuthServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  // Login user
  Future<Map<String, dynamic>> login(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/login", data: body);

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        
        // Save user data
        await Store.saveUser(responseData['user']);
        
        // Save token
        await Store.setToken(responseData['token']);
        
        // Save store if exists
        if (responseData['user']['firstStore'] != null) {
          await Store.saveStore(responseData['user']['firstStore']);
        }
        
        // Save subscription if exists
        if (responseData['user']['currentSubscription'] != null) {
          await Store.saveSubscribe({
            'isSubscribe': responseData['user']['isSubscribed'],
            'subscription': responseData['user']['currentSubscription']
          });
        }

        context.loaderOverlay.hide();
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': responseData,
          'accessType': responseData['accessType'],
          'userType': responseData['userType'],
        };
      }

      context.loaderOverlay.hide();
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Login failed'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Login failed';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 500,
        'message': errorMessage
      };
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/register", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 201) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Registration failed'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Registration failed';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': errorMessage
      };
    }
  }

  // Verify email
  Future<Map<String, dynamic>> verifyEmail(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/verify-email", data: body);

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        
        // Save user data and token after verification
        await Store.saveUser(responseData['user']);
        await Store.setToken(responseData['token']);

        context.loaderOverlay.hide();
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': responseData
        };
      }

      context.loaderOverlay.hide();
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Email verification failed'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Email verification failed';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': errorMessage
      };
    }
  }

  // Resend verification email
  Future<Map<String, dynamic>> resendVerification(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/resend-verification", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Failed to send verification email'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Failed to send verification email';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': errorMessage
      };
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/forgot-password", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Failed to send password reset email'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Failed to send password reset email';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': errorMessage
      };
    }
  }

  // Resend reset password token
  Future<Map<String, dynamic>> resendResetPassword(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/resend-reset", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Failed to send reset token'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Failed to send reset token';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': errorMessage
      };
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/reset-password", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Password reset failed'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Password reset failed';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': errorMessage
      };
    }
  }

  // Get profile (requires authentication)
  Future<Map<String, dynamic>> getProfile(BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.get("$_baseUrl/users/profile");

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        // Update stored user data
        await Store.saveUser(response.data['data']);

        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Failed to get profile'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Failed to get profile';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': errorMessage
      };
    }
  }

  // Update profile (requires authentication)
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.put("$_baseUrl/users/profile", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        // Update stored user data
        await Store.saveUser(response.data['data']);

        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Failed to update profile'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      
      String errorMessage = 'Failed to update profile';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': errorMessage
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await Store.clear();
  }
}