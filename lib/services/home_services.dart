import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class HomeServices {
  late final Dio _dio;

  HomeServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> product(Map<String, dynamic> params) async {
    final store = await Store.getStore();

    try {
      final resp = await _dio.get(
        "$_baseUrl/home/product/${store['id']}",
        queryParameters: params,
      );
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> favorite(Map<String, dynamic> params) async {
    final store = await Store.getStore();

    try {
      final resp = await _dio.get(
          "$_baseUrl/home/product/${store['id']}/favorite",
          queryParameters: params);

      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }
}
