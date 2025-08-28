import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../core/dio_intercaptor.dart';
import '../core/use_store.dart';
import 'service_utils.dart';

class TransactionServices {
  late final Dio _dio;

  TransactionServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> list() async {
    final store = await Store.getStore();
    try {
      final resp = await _dio.get("$_baseUrl/order/${store['id']}");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> store(BuildContext context, Map<String, dynamic> body) async {
    context.loaderOverlay.show();
    try {
      final resp = await _dio.post("$_baseUrl/order/store", data: body);
      context.loaderOverlay.hide();
      return resp;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print(e.response);
    }
  }

  Future<dynamic> detail(String id) async {
    try {
      final resp = await _dio.get("$_baseUrl/order/$id/detail");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> destroy(String id) async {
    try {
      final resp = await _dio.delete("$_baseUrl/order/$id/destroy");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> payment(String orderId, Map<String, dynamic> body) async {
    try {
      final resp =
          await _dio.post("$_baseUrl/order/store/$orderId/payment", data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  // Create complete transaction with payment
  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> transactionData) async {
    final store = await Store.getStore();
    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
      };
    }

    try {
      // Add store_id to transaction data
      final body = {
        ...transactionData,
        'store_id': store['id'],
      };

      final resp = await _dio.post("$_baseUrl/transaction/create", data: body);
      
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {
          'success': true,
          'data': resp.data['data'],
          'message': resp.data['message'] ?? 'Transaction created successfully',
        };
      } else {
        return {
          'success': false,
          'message': resp.data['message'] ?? 'Failed to create transaction',
        };
      }
    } on DioException catch (e) {
      print('Transaction creation error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Get transaction history
  Future<Map<String, dynamic>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? search,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final store = await Store.getStore();
    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
      };
    }

    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'store_id': store['id'],
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        queryParams['payment_method'] = paymentMethod;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final resp = await _dio.get(
        "$_baseUrl/transaction/history",
        queryParameters: queryParams,
      );
      
      if (resp.statusCode == 200) {
        return {
          'success': true,
          'data': resp.data['data'],
          'pagination': resp.data['pagination'],
          'message': resp.data['message'] ?? 'Transaction history loaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': resp.data['message'] ?? 'Failed to load transaction history',
        };
      }
    } on DioException catch (e) {
      print('Transaction history error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Get transaction detail
  Future<Map<String, dynamic>> getTransactionDetail(String transactionId) async {
    try {
      final resp = await _dio.get("$_baseUrl/transaction/$transactionId");
      
      if (resp.statusCode == 200) {
        return {
          'success': true,
          'data': resp.data['data'],
          'message': resp.data['message'] ?? 'Transaction detail loaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': resp.data['message'] ?? 'Failed to load transaction detail',
        };
      }
    } on DioException catch (e) {
      print('Transaction detail error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Delete transaction
  Future<Map<String, dynamic>> deleteTransaction(String transactionId) async {
    try {
      final resp = await _dio.delete("$_baseUrl/transaction/$transactionId");
      
      if (resp.statusCode == 200) {
        return {
          'success': true,
          'message': resp.data['message'] ?? 'Transaction deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': resp.data['message'] ?? 'Failed to delete transaction',
        };
      }
    } on DioException catch (e) {
      print('Transaction deletion error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
}
