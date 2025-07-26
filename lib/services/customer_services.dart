import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class CustomerServices {
  late final Dio _dio;

  CustomerServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> list() async {
    final store = await Store.getStore();
    try {
      final resp = await _dio.get("$_baseUrl/customer/${store['id']}");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> store(Map<String, dynamic> body) async {
    final store = await Store.getStore();
    try {
      final resp = await _dio.post("$_baseUrl/customer/store/${store['id']}",
          data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> detail(String id) async {
    try {
      final resp = await _dio.get("$_baseUrl/customer/detail/$id");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> update(String id, Map<String, dynamic> body) async {
    try {
      final resp = await _dio.post(
        "$_baseUrl/customer/update/$id",
        data: body,
      );
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> destroy(String id) async {
    try {
      final resp = await _dio.delete(
        "$_baseUrl/customer/destroy/$id",
      );
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }
}
