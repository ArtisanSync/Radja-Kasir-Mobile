import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class ProfileServices {
  late final Dio _dio;

  ProfileServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;
  Future<dynamic> profile() async {
    final user = await Store.getUser();
    try {
      final resp = await _dio.get("$_baseUrl/users/profile");

      if (resp.statusCode == 200) {
        return resp.data;
      } else {
        return {
          'success': false,
          'message': resp.data['message'] ?? 'Failed to fetch profile',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch profile',
      };
    }
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> body) async {
    try {
      final store = await Store.getStore();
      if (store == null || store['id'] == null) {
        return {
          'success': false,
          'message': 'Informasi toko tidak ditemukan',
        };
      }

      final response = await _dio
          .post("$_baseUrl/settings/store/${store['id']}/update", data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Perbarui data store yang tersimpan
        if (response.data['data']) {
          await Store.saveStore(response.data['data']);
        }

        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Gagal memperbarui profil'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 400,
        'message': e.response?.data['message'] ?? 'Gagal memperbarui profil'
      };
    }
  }

  Future<dynamic> uploadLogo(FormData body) async {
    final store = await Store.getStore();
    final resp = await _dio.post(
        "$_baseUrl/settings/store/${store['id']}/logo/upload",
        data: body);
    try {
      return resp;
    } on DioException catch (e) {
      return e;
    }
  }

  Future<dynamic> uploadStamp(FormData body) async {
    final store = await Store.getStore();
    final resp = await _dio.post(
        "$_baseUrl/settings/store/${store['id']}/stamp/upload",
        data: body);
    try {
      return resp;
    } on DioException catch (e) {
      return e;
    }
  }
}
