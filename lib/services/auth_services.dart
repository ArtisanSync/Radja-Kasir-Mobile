import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/helpers/store.dart';
import 'package:kasir/services/service_utils.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AuthServices {
  late final Dio _dio;
  AuthServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<Map<String, dynamic>> register(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/register", data: body);
      final responseData = response.data;

      if (responseData['success'] == true) {
        final data = responseData['data'];
        final token = data['token'];

        if (token != null) {
          final Map<String, dynamic> user = data['user']; 
          await Store.saveUser(user);
          await Store.setToken(token);
          context.loaderOverlay.hide();
          return {'success': true, 'needsVerification': false, 'message': 'Registrasi berhasil.'};
        } 
        else {
          context.loaderOverlay.hide();
          return {'success': true, 'needsVerification': true, 'message': responseData['message']};
        }
      } else {
        context.loaderOverlay.hide();
        return {'success': false, 'message': responseData['message'] ?? 'Registrasi gagal'};
      }
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Registrasi gagal');
    }
  }

  Future<Map<String, dynamic>> login(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/login", data: body);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data['data'];
        final Map<String, dynamic> user = responseData['user']; 
        await Store.saveUser(user);
        await Store.setToken(responseData['token']);
        
        context.loaderOverlay.hide();
        return {
          'success': true,
          'mustChangePassword': user['mustChangePassword'] ?? false,
        };
      }
      context.loaderOverlay.hide();
      return {'success': false, 'message': response.data['message'] ?? 'Login gagal'};
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Login gagal');
    }
  }


  Future<Map<String, dynamic>> verifyEmail(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/verify-email", data: body);
      final responseData = response.data;

      if (responseData['success'] == true) {
        final data = responseData['data'];
        final token = data['token'];
        final Map<String, dynamic> user = data['user'];

        await Store.saveUser(user);
        await Store.setToken(token);

        context.loaderOverlay.hide();
        return {'success': true, 'message': responseData['message']};
      } else {
        context.loaderOverlay.hide();
        return {'success': false, 'message': responseData['message'] ?? 'Verifikasi gagal'};
      }
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Verifikasi email gagal');
    }
  }
  
  Future<Map<String, dynamic>> resendVerification(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/resend-verification", data: body);
      context.loaderOverlay.hide();
      return response.data;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Gagal mengirim ulang verifikasi');
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/forgot-password", data: body);
      context.loaderOverlay.hide();
      return response.data;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Gagal mengirim email reset');
    }
  }
  Future<Map<String, dynamic>> resendResetPassword(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/resend-reset", data: body);
      context.loaderOverlay.hide();
      return response.data;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Gagal mengirim ulang token');
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/reset-password", data: body);
      context.loaderOverlay.hide();
      return response.data;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Gagal mereset password');
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String newPassword, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.put("$_baseUrl/users/profile",
          data: {'password': newPassword});
      context.loaderOverlay.hide();
      if (response.data['success'] == true) {
        await getProfile(context, showLoader: false);
      }
      return response.data;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, "Gagal mengganti password");
    }
  }
  Future<Map<String, dynamic>> getProfile(BuildContext context, {bool showLoader = true}) async {
    if (showLoader) context.loaderOverlay.show();
    try {
      final response = await _dio.get("$_baseUrl/users/profile");
      if (response.data['success'] == true) {
        final Map<String, dynamic> user = response.data['data'];
        await Store.saveUser(user);
      }
      if (showLoader) context.loaderOverlay.hide();
      return response.data;
    } on DioException catch (e) {
      if (showLoader) context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Gagal memuat profil');
    }
  }
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.put("$_baseUrl/users/profile", data: body);
      if (response.data['success'] == true) {
        final Map<String, dynamic> user = response.data['data'];
        await Store.saveUser(user);
      }
      context.loaderOverlay.hide();
      return response.data;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return ServiceUtils.handleDioError(e, 'Gagal memperbarui profil');
    }
  }

  Future<void> logout() async {
    await Store.clear();
  }
}