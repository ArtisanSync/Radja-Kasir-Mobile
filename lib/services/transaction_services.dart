import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../core/dio_intercaptor.dart';
import '../core/use_store.dart';
import 'service_utils.dart';

class TransactionServices {
  late final Dio _dio;

  TransactionServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> list() async {
    final store = await Store.getStore();
    try {
      final resp = await _dio.get("$_baseUrl/order/${store['id']}");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> store(BuildContext context, Map<String, dynamic> body) async {
    context.loaderOverlay.show();
    try {
      final resp = await _dio.post("$_baseUrl/order/store", data: body);
      context.loaderOverlay.hide();
      return resp;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print(e.response);
    }
  }

  Future<dynamic> detail(String id) async {
    try {
      final resp = await _dio.get("$_baseUrl/order/$id/detail");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> destroy(String id) async {
    try {
      final resp = await _dio.delete("$_baseUrl/order/$id/destroy");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> payment(String orderId, Map<String, dynamic> body) async {
    try {
      final resp =
          await _dio.post("$_baseUrl/order/store/$orderId/payment", data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }
}
