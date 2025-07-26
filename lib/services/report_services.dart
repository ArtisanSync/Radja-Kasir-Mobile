import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class ReportServices {
  late final Dio _dio;

  ReportServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> daily(Map<String, dynamic> params) async {
    final store = await Store.getStore();

    try {
      final resp =
          await _dio.get("$_baseUrl/report/${store['id']}/daily", data: params);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }
}
