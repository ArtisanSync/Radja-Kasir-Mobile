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

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  // Login user
  Future<Map<String, dynamic>> login(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/login", data: body);

      if (response.statusCode == 200) {
        // Save user data
        await Store.saveUser(response.data['data']['user']);

        // Save token
        await Store.setToken(response.data['data']['token']);

        // Handle subscribe data from user object
        if (response.data['data']['user'].containsKey('isSubscribe')) {
          await Store.saveSubscribe(
              {'isSubscribe': response.data['data']['user']['isSubscribe']});
        }

        context.loaderOverlay.hide();
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Login successful',
          'data': response.data['data']
        };
      }

      context.loaderOverlay.hide();
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Login failed'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Login error: $e');

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
          'message': response.data['message'] ?? 'Registration successful',
          'data': response.data['data']
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Registration failed'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Register error: $e');

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
      final response =
          await _dio.post("$_baseUrl/users/verify-email", data: body);

      if (response.statusCode == 200) {
        // Save user data and token after verification
        await Store.saveUser(response.data['data']['user']);
        await Store.setToken(response.data['data']['token']);

        context.loaderOverlay.hide();
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Email verified successfully',
          'data': response.data['data']
        };
      }

      context.loaderOverlay.hide();
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Email verification failed'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Verify email error: $e');

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
      final response =
          await _dio.post("$_baseUrl/users/resend-verification", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Verification email sent',
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Failed to send verification email'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Resend verification error: $e');

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
      final response =
          await _dio.post("$_baseUrl/users/forgot-password", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Password reset email sent',
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Failed to send password reset email'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Forgot password error: $e');

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
      final response =
          await _dio.post("$_baseUrl/users/resend-reset", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Reset token sent',
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Failed to send reset token'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Resend reset error: $e');

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
      final response =
          await _dio.post("$_baseUrl/users/reset-password", data: body);

      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Password reset successful',
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Password reset failed'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Reset password error: $e');

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
          'message':
              response.data['message'] ?? 'Profile retrieved successfully',
          'data': response.data['data']
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Failed to get profile'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Get profile error: $e');

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
          'message': response.data['message'] ?? 'Profile updated successfully',
          'data': response.data['data']
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Failed to update profile'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print('Update profile error: $e');

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
