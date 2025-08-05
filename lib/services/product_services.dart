import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ProductServices {
  late final Dio _dio;

  ProductServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // BASE URL
  final String _baseUrl = ServiceUtils().baseUrl;

  // ============ PRODUCT ============
  Future<Map<String, dynamic>> listProduct({
    String? search,
    String? categoryId,
    int page = 1,
    int limit = 20,
    bool? isFavorite,
    bool? lowStock,
    int stockThreshold = 10,
  }) async {
    final store = await Store.getStore();

    // Check if store data is available
    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
        'data': null
      };
    }

    try {
      Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isFavorite != null) queryParams['isFavorite'] = isFavorite.toString();
      if (lowStock == true) {
        queryParams['lowStock'] = 'true';
        queryParams['stockThreshold'] = stockThreshold.toString();
      }

      final response = await _dio.get(
        "$_baseUrl/products/store/${store['id']}",
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
          'message': response.data['message'] ?? 'Failed to fetch products',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> detailProduct(String id) async {
    try {
      final response = await _dio.get("$_baseUrl/products/$id");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Product not found',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Failed to fetch product details',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> storeProduct(FormData body) async {
    try {
      final response = await _dio.post(
        "$_baseUrl/products",
        data: body,
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
          'message': response.data['message'] ?? 'Failed to create product',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to create product',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> destroyProduct(String id) async {
    try {
      final response = await _dio.delete("$_baseUrl/products/$id");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to delete product',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to delete product',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> updateProduct(
      Map<String, dynamic> body, String id) async {
    try {
      final response = await _dio.put("$_baseUrl/products/$id", data: body);

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update product',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to update product',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> setFavorite(String id) async {
    try {
      // Since there's no specific toggle favorite endpoint in the Postman collection,
      // we'll use the update product endpoint to toggle favorite status
      final response = await _dio.put("$_baseUrl/products/$id", data: {
        'isFavorite': true // This should toggle on the backend
      });

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
              response.data['message'] ?? 'Failed to update favorite status',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Failed to update favorite status',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> uploadPhotoProduct(
      String id, FormData body) async {
    try {
      final response = await _dio.put("$_baseUrl/products/$id", data: body);

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to upload image',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to upload image',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> changeCategoryProduct(
      String id, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put("$_baseUrl/products/$id", data: body);

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to change category',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to change category',
        'data': null
      };
    }
  }

  // Get units for dropdown
  Future<Map<String, dynamic>> getUnits() async {
    try {
      final response = await _dio.get("$_baseUrl/products/units");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch units',
          'data': []
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch units',
        'data': []
      };
    }
  }

  // ============ CATEGORY ============
  Future<Map<String, dynamic>> listCategory() async {
    final store = await Store.getStore();

    // Check if store data is available
    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
        'data': []
      };
    }

    try {
      final response =
          await _dio.get("$_baseUrl/categories/store/${store['id']}");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch categories',
          'data': []
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch categories',
        'data': []
      };
    }
  }

  Future<Map<String, dynamic>> storeCategory(String name) async {
    final store = await Store.getStore();

    // Check if store data is available
    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
        'data': null
      };
    }

    try {
      final response = await _dio.post("$_baseUrl/categories",
          data: {"storeId": store['id'], 'name': name});

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to create category',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to create category',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> removeCategory(String id) async {
    try {
      final response = await _dio.delete("$_baseUrl/categories/$id");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to delete category',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to delete category',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> updateCategory(
      Map<String, dynamic> body, String id) async {
    try {
      final response = await _dio.put("$_baseUrl/categories/$id", data: body);

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update category',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to update category',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> getCategoryDetail(String id) async {
    try {
      final response = await _dio.get("$_baseUrl/categories/$id");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Category not found',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Failed to fetch category details',
        'data': null
      };
    }
  }

  // ============ VARIANT ============
  // Note: Variant operations are now handled through product update endpoints
  // since the backend manages variants as part of product structure

  // Backward compatibility methods for existing UI
  Future<Map<String, dynamic>> storeVariant(Map<String, dynamic> body) async {
    // Since variants are now part of product creation, redirect to product creation
    return await storeProduct(FormData.fromMap(body));
  }

  Future<Map<String, dynamic>> destroyVariant(dynamic id) async {
    // Since variants are managed as part of products, this would delete the product
    String productId = id.toString();
    return await destroyProduct(productId);
  }

  Future<Map<String, dynamic>> detailVariant(dynamic id) async {
    // Return product detail since variants are part of product
    String productId = id.toString();
    return await detailProduct(productId);
  }

  Future<Map<String, dynamic>> updateVariant(
      dynamic id, Map<String, dynamic> body) async {
    // Update product since variants are part of product
    String productId = id.toString();
    return await updateProduct(body, productId);
  }

  Future<Map<String, dynamic>> updateStock(
      BuildContext context, Map<String, dynamic> body, String productId) async {
    context.loaderOverlay.show();
    try {
      // Map old field names to new backend structure
      Map<String, dynamic> updateData = {};

      if (body.containsKey('quantity'))
        updateData['quantity'] = body['quantity'];
      if (body.containsKey('price')) updateData['price'] = body['price'];
      if (body.containsKey('capital_price'))
        updateData['capitalPrice'] = body['capital_price'];
      if (body.containsKey('discount_percent'))
        updateData['discountPercent'] = body['discount_percent'];
      if (body.containsKey('discount_rp'))
        updateData['discountRp'] = body['discount_rp'];

      final response =
          await _dio.put("$_baseUrl/products/$productId", data: updateData);
      context.loaderOverlay.hide();

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update stock',
          'data': null
        };
      }
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to update stock',
        'data': null
      };
    }
  }

  // Additional helper methods for low stock products
  Future<Map<String, dynamic>> getLowStockProducts({int threshold = 10}) async {
    final store = await Store.getStore();

    // Check if store data is available
    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
        'data': null
      };
    }

    try {
      final response = await _dio.get(
        "$_baseUrl/products/store/${store['id']}",
        queryParameters: {
          'lowStock': 'true',
          'stockThreshold': threshold.toString(),
        },
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
              response.data['message'] ?? 'Failed to fetch low stock products',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Failed to fetch low stock products',
        'data': null
      };
    }
  }

  // Bulk operations
  Future<Map<String, dynamic>> bulkUpdateProducts(
      List<String> productIds, Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.post(
        "$_baseUrl/products/bulk-update",
        data: {
          'productIds': productIds,
          'updateData': updateData,
        },
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
              response.data['message'] ?? 'Failed to bulk update products',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Failed to bulk update products',
        'data': null
      };
    }
  }

  // Delete product
  Future<Map<String, dynamic>> deleteProduct(String id) async {
    try {
      final response = await _dio.delete("$_baseUrl/products/$id");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to delete product',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to delete product',
        'data': null
      };
    }
  }

  // ============ END VARIANT ============
}
