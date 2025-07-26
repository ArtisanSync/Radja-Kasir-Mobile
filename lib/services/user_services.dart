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

  Future<dynamic> lists() async {
    final store = await Store.getStore();

    try {
      final response = await _dio.get("$_baseUrl/users/${store['id']}/member");
      return response;
    } on DioException catch (e) {
      print(e);
      // return e.response!.statusCode ?? 500;
    }
  }

  Future<dynamic> store(Map<String, dynamic> body) async {
    final store = await Store.getStore();
    try {
      final response = await _dio.post(
        "$_baseUrl/users/${store['id']}/member/store",
        data: body,
      );
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> destroy(int id) async {
    try {
      final response = await _dio.delete("$_baseUrl/users/member/destroy/$id");
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  // USER PACKAGE
  Future<dynamic> package(int id) async {
    try {
      return await _dio.get("$_baseUrl/users/package/$id");
    } on DioException catch (e) {
      return e.response!.statusMessage;
    }
  }
}
