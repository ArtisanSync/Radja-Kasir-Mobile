
import 'package:dio/dio.dart';
import 'package:kasir/services/service_utils.dart';

import '../core/dio_intercaptor.dart';
import '../core/use_store.dart';

class StoreSettingServices {
  late final Dio _dio;

  StoreSettingServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> lists() async {
    final store = await Store.getStore();
    try {
      final response = await _dio.get("$_baseUrl/store/transaction-setting/${store['id']}");
      return response;
    } on DioException catch (e) {
      print(e);
      // return e.response!.statusCode ?? 500;
    }
  }

  Future<dynamic> store(int storeId, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        "$_baseUrl/store/transaction-setting/$storeId/update",
        data: body,
      );
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }
}