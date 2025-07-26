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
      final response = await _dio.post("$_baseUrl/login", data: body);
      if (response.statusCode == 201) {
        await Store.saveUser(response.data!['data']['user']);
        await Store.setToken(response.data!['data']['access_token']);
        await Store.saveStore(response.data!['data']['store']);
        // await Store.saveSubscribe(response.data!['data']['subscribe']);
        return response.statusCode;
      }
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
    } on DioException catch (e) {
      // ignore: use_build_context_synchronously
      print(e);
      context.loaderOverlay.hide();
      // return e.response!.statusCode ?? 500;
      // return e.response;
    }
  }
}
