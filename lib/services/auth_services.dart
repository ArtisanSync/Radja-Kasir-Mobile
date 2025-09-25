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
  Future<Map<String, dynamic>> login(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/login", data: body);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data['data'];
        final user = responseData['user'];
        await Store.saveUser(user);
        await Store.setToken(responseData['token']);
        if (user['role'] == 'MEMBER' && user['storeMembers'] != null && (user['storeMembers'] as List).isNotEmpty) {
          final storeData = user['storeMembers'][0]['store'];
          if (storeData != null) {
            await Store.saveStore(storeData);
          }
        } else if (user['stores'] != null && (user['stores'] as List).isNotEmpty) {
        await Store.saveStore(user['stores'][0]);
        }
        
        if (user['currentSubscription'] != null) {
          await Store.saveSubscribe({
            'isSubscribed': user['isSubscribed'],
            'subscription': user['currentSubscription']
          });
        }

        context.loaderOverlay.hide();
        return {
          'success': true,
          'message': response.data['message'],
          'data': responseData,
          'mustChangePassword': user['mustChangePassword'] ?? false,
        };
      }

      context.loaderOverlay.hide();
      return {
        'success': false,
        'message': response.data['message'] ?? 'Login gagal'
      };
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Login gagal');
    }
  }
  Future<Map<String, dynamic>> changePassword(
      String newPassword, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.put("$_baseUrl/users/profile",
          data: {'password': newPassword});

      context.loaderOverlay.hide();
      return response.data;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, "Gagal mengganti password");
    }
  }

  Future<Map<String, dynamic>> register(
      Map<String, dynamic> body, BuildContext context) async {
    return {};
  }
  
  Future<Map<String, dynamic>> verifyEmail(
      Map<String, dynamic> body, BuildContext context) async {
    return {};
  }
  
  Future<Map<String, dynamic>> resendVerification(
      Map<String, dynamic> body, BuildContext context) async {
    return {};
  }
  
  Future<Map<String, dynamic>> forgotPassword(
      Map<String, dynamic> body, BuildContext context) async {
    return {};
  }

  Future<Map<String, dynamic>> resendResetPassword(
      Map<String, dynamic> body, BuildContext context) async {
    return {};
  }

  Future<Map<String, dynamic>> resetPassword(
      Map<String, dynamic> body, BuildContext context) async {
    return {};
  }
  
  Future<Map<String, dynamic>> getProfile(BuildContext context) async {
    return {};
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> body, BuildContext context) async {
    return {};
  }

  Future<void> logout() async {
    await Store.clear();
  }
}