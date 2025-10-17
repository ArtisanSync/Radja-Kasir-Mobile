import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/services/service_utils.dart';

class PaymentServices {
  late final Dio _dio;
  final String _baseUrl = ServiceUtils().baseUrl;

  PaymentServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  Future<Map<String, dynamic>> createSubscriptionPayment(
      String packageId) async {
    try {
      final response = await _dio.post(
        "$_baseUrl/payments/create",
        data: {'packageId': packageId},
      );

      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, 'Gagal membuat pembayaran');
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(
      String merchantOrderId) async {
    try {
      final response =
          await _dio.get("$_baseUrl/payments/status/$merchantOrderId");
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, 'Gagal memeriksa status');
    }
  }
}
