import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class StoreServices {
  late final Dio _dio;

  StoreServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  // Get my stores
  Future<Map<String, dynamic>> getMyStores() async {
    try {
      final response = await _dio.get("$_baseUrl/stores/my-stores");

      if (response.data['success'] == true) {
        final List<dynamic> stores = response.data['data'] ?? [];

        // Save the first store as default (if exists)
        if (stores.isNotEmpty) {
          await Store.saveStore(stores.first);
        }

        return {
          'success': true,
          'data': stores,
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch stores',
          'data': []
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch stores',
        'data': []
      };
    }
  }

  // Get store by ID
  Future<Map<String, dynamic>> getStore(String storeId) async {
    try {
      final response = await _dio.get("$_baseUrl/stores/$storeId");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Store not found',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch store',
        'data': null
      };
    }
  }

  // Initialize store data (call this after login)
  Future<bool> initializeStore() async {
    try {
      final result = await getMyStores();
      return result['success'] == true;
    } catch (e) {
      debugPrint('Error initializing store: $e');
      return false;
    }
  }
}
