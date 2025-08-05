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

  Future<dynamic> login(Map<String, dynamic> body, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post("$_baseUrl/users/login", data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save user data
        await Store.saveUser(response.data!['data']['user']);

        // Save token (Express.js menggunakan 'token' bukan 'access_token')
        await Store.setToken(response.data!['data']['token']);

        // Handle store data - jika ada di response
        if (response.data!['data'].containsKey('store')) {
          await Store.saveStore(response.data!['data']['store']);
        }

        // Handle subscribe data - ambil dari user object atau set default
        if (response.data!['data']['user'].containsKey('isSubscribe')) {
          await Store.saveSubscribe(
              {'isSubscribe': response.data!['data']['user']['isSubscribe']});
        }

        // ignore: use_build_context_synchronously
        context.loaderOverlay.hide();
        return response.statusCode;
      }
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
      return response.statusCode;
    } on DioException catch (e) {
      // ignore: use_build_context_synchronously
      print('Login error: $e');
      if (e.response != null) {
        print('Error response: ${e.response!.data}');
      }
      context.loaderOverlay.hide();
      return e.response?.statusCode ?? 500;
    }
  }

  Future register(Map<String, String> map, BuildContext context) async {}
}
