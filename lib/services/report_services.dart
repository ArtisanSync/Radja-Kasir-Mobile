import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportServices {
  late final Dio _dio;

  ReportServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  // Get sales report
  Future<Map<String, dynamic>> getSalesReport({
    String period = 'realtime',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final store = await Store.getStore();

      if (store == null || store['id'] == null) {
        return {
          'success': false,
          'message': 'Store information not found. Please login again.',
          'data': null
        };
      }

      Map<String, dynamic> queryParams = {
        'period': period,
      };

      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate;
        queryParams['endDate'] = endDate;
      }

      final response = await _dio.get(
        "$_baseUrl/reports/${store['id']}/sales",
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get sales report',
          'data': null
        };
      }
    } on DioException catch (e) {
      print('Sales report error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      print('Sales report error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  // Get stock report
  Future<Map<String, dynamic>> getStockReport({String? categoryId}) async {
    try {
      final store = await Store.getStore();

      if (store == null || store['id'] == null) {
        return {
          'success': false,
          'message': 'Store information not found. Please login again.',
          'data': null
        };
      }

      Map<String, dynamic> queryParams = {};
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _dio.get(
        "$_baseUrl/reports/${store['id']}/stock",
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get stock report',
          'data': null
        };
      }
    } on DioException catch (e) {
      print('Stock report error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      print('Stock report error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  // Get dashboard summary
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final store = await Store.getStore();

      if (store == null || store['id'] == null) {
        return {
          'success': false,
          'message': 'Store information not found. Please login again.',
          'data': null
        };
      }

      final response = await _dio.get(
        "$_baseUrl/reports/${store['id']}/dashboard",
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Failed to get dashboard summary',
          'data': null
        };
      }
    } on DioException catch (e) {
      print('Dashboard summary error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      print('Dashboard summary error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  // Get profit report
  Future<Map<String, dynamic>> getProfitReport({
    String period = 'realtime',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final store = await Store.getStore();

      if (store == null || store['id'] == null) {
        return {
          'success': false,
          'message': 'Store information not found. Please login again.',
          'data': null
        };
      }

      Map<String, dynamic> queryParams = {
        'period': period,
      };

      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate;
        queryParams['endDate'] = endDate;
      }

      final response = await _dio.get(
        "$_baseUrl/reports/${store['id']}/profit",
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get profit report',
          'data': null
        };
      }
    } on DioException catch (e) {
      print('Profit report error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      print('Profit report error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  // Get margin report
  Future<Map<String, dynamic>> getMarginReport({
    String period = 'realtime',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final store = await Store.getStore();

      if (store == null || store['id'] == null) {
        return {
          'success': false,
          'message': 'Store information not found. Please login again.',
          'data': null
        };
      }

      Map<String, dynamic> queryParams = {
        'period': period,
      };

      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate;
        queryParams['endDate'] = endDate;
      }

      final response = await _dio.get(
        "$_baseUrl/reports/${store['id']}/margin",
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get margin report',
          'data': null
        };
      }
    } on DioException catch (e) {
      print('Margin report error: ${e.response}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      print('Margin report error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  // Download sales report Excel
  Future<bool> downloadSalesReport({
    String period = 'realtime',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final store = await Store.getStore();

      if (store == null || store['id'] == null) {
        return false;
      }

      Map<String, dynamic> queryParams = {
        'period': period,
      };

      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate;
        queryParams['endDate'] = endDate;
      }

      // Build URL with query parameters
      final uri = Uri.parse("$_baseUrl/reports/${store['id']}/sales/download");
      final finalUri = uri.replace(queryParameters: queryParams);

      // Launch URL to download file
      if (await canLaunchUrl(finalUri)) {
        await launchUrl(
          finalUri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
        return true;
      }

      return false;
    } catch (e) {
      print('Download sales report error: $e');
      return false;
    }
  }

  // Download stock report Excel
  Future<bool> downloadStockReport({String? categoryId}) async {
    try {
      final store = await Store.getStore();

      if (store == null || store['id'] == null) {
        return false;
      }

      Map<String, dynamic> queryParams = {};
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      // Build URL with query parameters
      final uri = Uri.parse("$_baseUrl/reports/${store['id']}/stock/download");
      final finalUri = uri.replace(queryParameters: queryParams);

      // Launch URL to download file
      if (await canLaunchUrl(finalUri)) {
        await launchUrl(
          finalUri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
        return true;
      }

      return false;
    } catch (e) {
      print('Download stock report error: $e');
      return false;
    }
  }
}
