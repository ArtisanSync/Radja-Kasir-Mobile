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
        'message':
            e.response?.data['message'] ?? 'Failed to fetch product details',
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
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
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
              // Handle data URL format (data:image/png;base64,...)
              final mimeMatch =
                  RegExp(r'data:image/(\w+);base64,').firstMatch(image);
              if (mimeMatch != null) {
                final extension = mimeMatch.group(1)!.toLowerCase();
                filename = 'product_image.$extension';
                contentType = 'image/$extension';
                // Remove data URL prefix and decode base64
                final base64String = image.split(',')[1];
                bytes = base64Decode(base64String);
              } else {
                // Fallback: treat as plain base64
                bytes = base64Decode(image);
              }
            } else {
              // Treat as plain base64 string
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
            // Fallback to original method
            formData.files.add(MapEntry(
              'image',
              MultipartFile.fromString(image, filename: 'product_image.png'),
            ));
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
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (code != null) updateData['code'] = code;
      if (brand != null) updateData['brand'] = brand;
      if (categoryId != null) updateData['categoryId'] = categoryId;
      if (active != null) updateData['active'] = active;
      if (isFavorite != null) updateData['isFavorite'] = isFavorite;

      // Handle image update separately if needed
      FormData? formData;
      if (image != null) {
        formData = FormData.fromMap(updateData);
        if (kIsWeb) {
          // For web, convert base64 to bytes and set proper MIME type
          try {
            Uint8List bytes;
            String filename = 'product_image.png';
            String contentType = 'image/png';

            if (image.startsWith('data:image/')) {
              // Handle data URL format (data:image/png;base64,...)
              final mimeMatch =
                  RegExp(r'data:image/(\w+);base64,').firstMatch(image);
              if (mimeMatch != null) {
                final extension = mimeMatch.group(1)!.toLowerCase();
                filename = 'product_image.$extension';
                contentType = 'image/$extension';
                // Remove data URL prefix and decode base64
                final base64String = image.split(',')[1];
                bytes = base64Decode(base64String);
              } else {
                // Fallback: treat as plain base64
                bytes = base64Decode(image);
              }
            } else {
              // Treat as plain base64 string
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
            // Fallback to original method
            formData.files.add(MapEntry(
              'image',
              MultipartFile.fromString(image, filename: 'product_image.png'),
            ));
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

  /// Update product variant (stock, price, etc.)
  Future<Map<String, dynamic>> updateProductVariant(
    String productId, {
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

      if (unitId != null) updateData['unitId'] = unitId;
      if (quantity != null) updateData['quantity'] = quantity;
      if (capitalPrice != null) updateData['capitalPrice'] = capitalPrice;
      if (price != null) updateData['price'] = price;
      if (tax != null) updateData['tax'] = tax;
      if (discountRp != null) updateData['discountRp'] = discountRp;
      if (discountPercent != null)
        updateData['discountPercent'] = discountPercent;

      final response = await _dio.put(
        "$_baseUrl/products/$productId",
        data: updateData,
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
          'message':
              response.data['message'] ?? 'Failed to update product variant',
          'data': null
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in updateProductVariant: ${e.message}');
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Failed to update product variant',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in updateProductVariant: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Upload product image
  Future<Map<String, dynamic>> uploadProductImage(
      String productId, String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.put(
        "$_baseUrl/products/$productId",
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
          'message': response.data['message'] ?? 'Failed to upload image',
          'data': null
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in uploadProductImage: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to upload image',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in uploadProductImage: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Get low stock products
  Future<Map<String, dynamic>> getLowStockProducts({int threshold = 10}) async {
    return await getProducts(lowStock: true, stockThreshold: threshold);
  }

  /// Toggle favorite status
  Future<Map<String, dynamic>> toggleFavorite(
      String productId, bool isFavorite) async {
    return await updateProduct(productId, isFavorite: isFavorite);
  }
}
