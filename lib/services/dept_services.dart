import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class DeptServices {
  late final Dio _dio;

  DeptServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> list() async {
    final store = await Store.getStore();
    try {
      final resp = await _dio.get("$_baseUrl/dept/${store['id']}");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> detail(String id) async {
    try {
      final resp = await _dio.get("$_baseUrl/dept/$id/detail");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> store(Map<String, dynamic> body) async {
    final store = await Store.getStore();
    try {
      final resp =
          await _dio.post("$_baseUrl/dept/${store['id']}/store", data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> paid(String id) async {
    try {
      final resp = await _dio.post("$_baseUrl/dept/$id/paid");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }
}
