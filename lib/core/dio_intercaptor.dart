import 'package:dio/dio.dart';
import 'package:kasir/core/use_store.dart';

class DioInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await Store.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }

  // void onResponse(Response response, ResponseInterceptorHandler handler) {
  //   print(
  //       'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
  //   super.onResponse(response, handler);
  // }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    print('ERROR[${err.response?.statusCode}]');
    super.onError(err, handler);
  }
}
