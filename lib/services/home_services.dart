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

  Future<Map<String, dynamic>> product(Map<String, dynamic> params) async {
    try {
      final store = await Store.getStore();
      
      if (store == null || store['id'] == null) {
        return {
          'success': false,
          'message': 'Store information not found. Please login again.',
          'data': []
        };
      }

      final resp = await _dio.get(
        "$_baseUrl/home/product/${store['id']}",
        queryParameters: params,
      );
      
      return {
        'success': true,
        'data': resp.data,
        'message': 'Products loaded successfully'
      };
    } on DioException catch (e) {
      print('Home service product error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to load products',
        'data': []
      };
    } catch (e) {
      print('Home service product error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': []
      };
    }
  }

  Future<Map<String, dynamic>> favorite(Map<String, dynamic> params) async {
    try {
      final store = await Store.getStore();
      
      if (store == null || store['id'] == null) {
        return {
          'success': false,
          'message': 'Store information not found. Please login again.',
          'data': []
        };
      }

      final resp = await _dio.get(
        "$_baseUrl/home/product/${store['id']}/favorite",
        queryParameters: params
      );

      return {
        'success': true,
        'data': resp.data,
        'message': 'Favorite products loaded successfully'
      };
    } on DioException catch (e) {
      print('Home service favorite error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to load favorite products',
        'data': []
      };
    } catch (e) {
      print('Home service favorite error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': []
      };
    }
  }
}