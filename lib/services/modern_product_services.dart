import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class ModernProductServices {
  late final Dio _dio;

  ModernProductServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  /// Get all products with filters and pagination
  Future<Map<String, dynamic>> getProducts({
    String? search,
    String? categoryId,
    int page = 1,
    int limit = 20,
    bool? isFavorite,
    bool? lowStock,
    int stockThreshold = 10,
  }) async {
    final store = await Store.getStore();

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
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch products',
          'data': null
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in getProducts: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in getProducts: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Get product by ID
  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final response = await _dio.get("$_baseUrl/products/$id");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Product not found',
          'data': null
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in getProductById: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch product details',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in getProductById: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Create new product
  Future<Map<String, dynamic>> createProduct({
    required String name,
    String? code,
    String? brand,
    String? categoryId,
    String? image,
    required String unitId,
    required int quantity,
    required String capitalPrice,
    required String price,
    int tax = 0,
    String discountRp = '0',
    int discountPercent = 0,
  }) async {
    final store = await Store.getStore();

    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
        'data': null
      };
    }

    try {
      // Prepare form data for multipart request
      FormData formData = FormData.fromMap({
        'name': name,
        'storeId': store['id'],
        if (code != null && code.isNotEmpty) 'code': code,
        if (brand != null && brand.isNotEmpty) 'brand': brand,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
        // Variant data for the default variant
        'unitId': unitId,
        'quantity': quantity,
        'capitalPrice': capitalPrice,
        'price': price,
        'tax': tax,
        'discountRp': discountRp,
        'discountPercent': discountPercent,
      });

      // Add image if provided
      if (image != null) {
        if (kIsWeb) {
          // For web, convert base64 to bytes and set proper MIME type
          try {
            Uint8List bytes;
            String filename = 'product_image.png';
            String contentType = 'image/png';

            if (image.startsWith('data:image/')) {
              final mimeMatch = RegExp(r'data:image/(\w+);base64,').firstMatch(image);
              if (mimeMatch != null) {
                final extension = mimeMatch.group(1)!.toLowerCase();
                filename = 'product_image.$extension';
                contentType = 'image/$extension';
                final base64String = image.split(',')[1];
                bytes = base64Decode(base64String);
              } else {
                bytes = base64Decode(image);
              }
            } else {
              bytes = base64Decode(image);
            }

            formData.files.add(MapEntry(
              'image',
              MultipartFile.fromBytes(
                bytes,
                filename: filename,
                contentType: MediaType.parse(contentType),
              ),
            ));
          } catch (e) {
            debugPrint('Error processing image for web: $e');
          }
        } else {
          // For mobile, image should be file path
          final extension = path.extension(image).toLowerCase();
          String contentType = 'image/png';

          if (extension == '.jpg' || extension == '.jpeg') {
            contentType = 'image/jpeg';
          } else if (extension == '.png') {
            contentType = 'image/png';
          }

          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(
              image,
              contentType: MediaType.parse(contentType),
            ),
          ));
        }
      }

      final response = await _dio.post(
        "$_baseUrl/products",
        data: formData,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to create product',
          'data': null
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in createProduct: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to create product',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in createProduct: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Update product
  Future<Map<String, dynamic>> updateProduct(
    String id, {
    String? name,
    String? code,
    String? brand,
    String? categoryId,
    String? image,
    bool? active,
    bool? isFavorite,
    String? unitId,
    int? quantity,
    String? capitalPrice,
    String? price,
    int? tax,
    String? discountRp,
    int? discountPercent,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      // Product level updates
      if (name != null) updateData['name'] = name;
      if (code != null) updateData['code'] = code;
      if (brand != null) updateData['brand'] = brand;
      if (categoryId != null) updateData['categoryId'] = categoryId;
      if (active != null) updateData['isActive'] = active;
      if (isFavorite != null) updateData['isFavorite'] = isFavorite;

      // Variant level updates
      if (unitId != null) updateData['unitId'] = unitId;
      if (quantity != null) updateData['quantity'] = quantity;
      if (capitalPrice != null) updateData['capitalPrice'] = capitalPrice;
      if (price != null) updateData['price'] = price;
      if (tax != null) updateData['tax'] = tax;
      if (discountRp != null) updateData['discountRp'] = discountRp;
      if (discountPercent != null) updateData['discountPercent'] = discountPercent;

      FormData? formData;
      if (image != null) {
        formData = FormData.fromMap(updateData);
        if (kIsWeb) {
          try {
            Uint8List bytes;
            String filename = 'product_image.png';
            String contentType = 'image/png';

            if (image.startsWith('data:image/')) {
              final mimeMatch = RegExp(r'data:image/(\w+);base64,').firstMatch(image);
              if (mimeMatch != null) {
                final extension = mimeMatch.group(1)!.toLowerCase();
                filename = 'product_image.$extension';
                contentType = 'image/$extension';
                final base64String = image.split(',')[1];
                bytes = base64Decode(base64String);
              } else {
                bytes = base64Decode(image);
              }
            } else {
              bytes = base64Decode(image);
            }

            formData.files.add(MapEntry(
              'image',
              MultipartFile.fromBytes(
                bytes,
                filename: filename,
                contentType: MediaType.parse(contentType),
              ),
            ));
          } catch (e) {
            debugPrint('Error processing image for web: $e');
          }
        } else {
          final extension = path.extension(image).toLowerCase();
          String contentType = 'image/png';

          if (extension == '.jpg' || extension == '.jpeg') {
            contentType = 'image/jpeg';
          } else if (extension == '.png') {
            contentType = 'image/png';
          }

          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(
              image,
              contentType: MediaType.parse(contentType),
            ),
          ));
        }
      }

      final response = await _dio.put(
        "$_baseUrl/products/$id",
        data: formData ?? updateData,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update product',
          'data': null
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in updateProduct: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to update product',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in updateProduct: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Toggle favorite
  Future<Map<String, dynamic>> toggleFavorite(String productId) async {
    try {
      final response = await _dio.patch("$_baseUrl/products/$productId/favorite");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to toggle favorite',
          'data': null
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in toggleFavorite: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to toggle favorite',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in toggleFavorite: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Delete product
  Future<Map<String, dynamic>> deleteProduct(String id) async {
    try {
      final response = await _dio.delete("$_baseUrl/products/$id");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to delete product',
          'data': null
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in deleteProduct: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to delete product',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in deleteProduct: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Get available units
  Future<Map<String, dynamic>> getUnits() async {
    try {
      final response = await _dio.get("$_baseUrl/products/units");

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch units',
          'data': []
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in getUnits: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch units',
        'data': []
      };
    } catch (e) {
      debugPrint('Error in getUnits: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': []
      };
    }
  }
}
