import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/helpers/store.dart';
import 'package:kasir/services/service_utils.dart';
import 'package:http_parser/http_parser.dart';

class StoreServices {
  late final Dio _dio;
  final String _baseUrl = ServiceUtils().baseUrl;

  StoreServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  Future<FormData> _createStoreFormData(
      Map<String, dynamic> storeData, XFile? logoFile) async {
    storeData.removeWhere((key, value) => value == null);
    final formData = FormData.fromMap(storeData);

    if (logoFile != null) {
      final mediaType = MediaType('image', logoFile.name.split('.').last);
      if (kIsWeb) {
        final bytes = await logoFile.readAsBytes();
        formData.files.add(MapEntry(
          'logo',
          MultipartFile.fromBytes(bytes,
              filename: logoFile.name, contentType: mediaType),
        ));
      } else {
        formData.files.add(MapEntry(
          'logo',
          await MultipartFile.fromFile(logoFile.path,
              filename: logoFile.name, contentType: mediaType),
        ));
      }
    }
    return formData;
  }

  Future<Map<String, dynamic>> createFirstStore(
      Map<String, dynamic> storeData, XFile? logo) async {
    try {
      final formData = await _createStoreFormData(storeData, logo);
      final response =
          await _dio.post("$_baseUrl/stores/first", data: formData);
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['data']?['subscriptionRequired'] == true) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Langganan diperlukan',
          'data': e.response?.data['data'],
          'subscriptionRequired': true
        };
      }
      return e.response?.data ??
          {
            'success': false,
            'message':
                e.response?.data['message'] ?? 'Terjadi kesalahan jaringan'
          };
    }
  }

  Future<Map<String, dynamic>> createStore(
      Map<String, dynamic> storeData, XFile? logo) async {
    try {
      final formData = await _createStoreFormData(storeData, logo);
      final response = await _dio.post("$_baseUrl/stores", data: formData);
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['data']?['subscriptionRequired'] == true) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Langganan diperlukan',
          'data': e.response?.data['data'],
          'subscriptionRequired': true
        };
      }
      return e.response?.data ??
          {
            'success': false,
            'message':
                e.response?.data['message'] ?? 'Terjadi kesalahan jaringan'
          };
    }
  }

  Future<Map<String, dynamic>> updateStore(
      String storeId, Map<String, dynamic> updateData, XFile? logo) async {
    try {
      final formData = await _createStoreFormData(updateData, logo);
      final response =
          await _dio.put("$_baseUrl/stores/$storeId", data: formData);

      if (response.statusCode == 200) {
        final currentStore = await Store.getStore();
        if (currentStore != null && currentStore['id'] == storeId) {
          await Store.saveStore(response.data['data']);
        }
      }
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {
            'success': false,
            'message':
                e.response?.data['message'] ?? 'Terjadi kesalahan jaringan'
          };
    }
  }

  Future<Map<String, dynamic>> getMyStores() async {
    try {
      final response = await _dio.get("$_baseUrl/stores/my-stores");
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  Future<Map<String, dynamic>> getStoreDetail(String storeId) async {
    try {
      final response = await _dio.get("$_baseUrl/stores/$storeId");
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  Future<Map<String, dynamic>> deleteStore(String storeId) async {
    try {
      final response = await _dio.delete("$_baseUrl/stores/$storeId");
      if (response.statusCode == 200) {
        final currentStore = await Store.getStore();
        if (currentStore != null && currentStore['id'] == storeId) {
          await Store.removeStore();
        }
      }
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {'success': false, 'message': 'Gagal menghapus toko'};
    }
  }
}
