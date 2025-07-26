import 'package:dio/dio.dart';
import 'package:kasir/services/service_utils.dart';

import '../core/dio_intercaptor.dart';
import '../core/use_store.dart';

class SettingServices {
  late final Dio _dio;

  SettingServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> subcribe() async {
    final store = await Store.getStore();
    try {
      final response = await _dio.get("$_baseUrl/setting/subscribe");
      return response;
    } on DioException catch (e) {
      print(e);
      // return e.response!.statusCode ?? 500;
    }
  }
}
