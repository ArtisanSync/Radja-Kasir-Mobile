import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';


class ProductServices {
  late final Dio _dio;

  ProductServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  // ============ PRODUCT METHODS ============

  /// Get all products with filters and pagination
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
      debugPrint('DioException in listProduct: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in listProduct: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Get product by ID
  Future<Map<String, dynamic>> detailProduct(String id) async {
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
      debugPrint('DioException in detailProduct: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch product details',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in detailProduct: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Create new product
  Future<Map<String, dynamic>> storeProduct({
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
      FormData formData = FormData.fromMap({
        'name': name,
        'storeId': store['id'],
        if (code != null && code.isNotEmpty) 'code': code,
        if (brand != null && brand.isNotEmpty) 'brand': brand,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
        'unitId': unitId,
        'quantity': quantity,
        'capitalPrice': capitalPrice,
        'price': price,
        'tax': tax,
        'discountRp': discountRp,
        'discountPercent': discountPercent,
      });

      if (image != null) {
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
      debugPrint('DioException in storeProduct: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to create product',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in storeProduct: $e');
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

      if (name != null) updateData['name'] = name;
      if (code != null) updateData['code'] = code;
      if (brand != null) updateData['brand'] = brand;
      if (categoryId != null) updateData['categoryId'] = categoryId;
      if (active != null) updateData['isActive'] = active;
      if (isFavorite != null) updateData['isFavorite'] = isFavorite;
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
  Future<Map<String, dynamic>> setFavorite(String productId) async {
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
      debugPrint('DioException in setFavorite: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to toggle favorite',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in setFavorite: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
        'data': null
      };
    }
  }

  /// Delete product
  Future<Map<String, dynamic>> destroyProduct(String id) async {
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
      debugPrint('DioException in destroyProduct: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to delete product',
        'data': null
      };
    } catch (e) {
      debugPrint('Error in destroyProduct: $e');
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

  // ============ CATEGORY METHODS ============

  Future<Map<String, dynamic>> listCategory() async {
    final store = await Store.getStore();

    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
        'data': []
      };
    }

    try {
      final response = await _dio.get("$_baseUrl/categories/store/${store['id']}");

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

    if (store == null || store['id'] == null) {
      return {
        'success': false,
        'message': 'Store information not found. Please login again.',
        'data': null
      };
    }

    try {
      final response = await _dio.post("$_baseUrl/categories", data: {
        "storeId": store['id'],
        'name': name
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

  Future<Map<String, dynamic>> updateCategory(Map<String, dynamic> body, String id) async {
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

  // ============ LEGACY VARIANT METHODS ============
  // For backward compatibility with existing UI

  Future<Map<String, dynamic>> storeVariant(Map<String, dynamic> body) async {
    return await storeProduct(
      name: body['name'] ?? '',
      unitId: body['unitId'] ?? '',
      quantity: int.tryParse(body['quantity']?.toString() ?? '0') ?? 0,
      capitalPrice: body['capital_price']?.toString() ?? '0',
      price: body['price']?.toString() ?? '0',
      tax: int.tryParse(body['tax']?.toString() ?? '0') ?? 0,
      discountRp: body['dic_rp']?.toString() ?? '0',
      discountPercent: int.tryParse(body['dic_percent']?.toString() ?? '0') ?? 0,
    );
  }

  Future<Map<String, dynamic>> destroyVariant(dynamic id) async {
    String productId = id.toString();
    return await destroyProduct(productId);
  }

  Future<Map<String, dynamic>> detailVariant(dynamic id) async {
    String productId = id.toString();
    return await detailProduct(productId);
  }

  Future<Map<String, dynamic>> updateVariant(dynamic id, Map<String, dynamic> body) async {
    String productId = id.toString();
    
    return await updateProduct(
      productId,
      name: body['name'],
      quantity: int.tryParse(body['quantity']?.toString() ?? '0'),
      capitalPrice: body['capitalPrice']?.toString(),
      price: body['price']?.toString(),
      tax: int.tryParse(body['tax']?.toString() ?? '0'),
      discountRp: body['discountRp']?.toString(),
      discountPercent: int.tryParse(body['discountPercent']?.toString() ?? '0'),
    );
  }

  Future<Map<String, dynamic>> updateStock(context, Map<String, dynamic> body, String productId) async {
    Map<String, dynamic> updateData = {};

    if (body.containsKey('quantity'))
      updateData['quantity'] = int.tryParse(body['quantity']?.toString() ?? '0');
    if (body.containsKey('price')) 
      updateData['price'] = body['price']?.toString();
    if (body.containsKey('capital_price'))
      updateData['capitalPrice'] = body['capital_price']?.toString();
    if (body.containsKey('tax'))
      updateData['tax'] = int.tryParse(body['tax']?.toString() ?? '0');

    return await updateProduct(
      productId,
      quantity: updateData['quantity'],
      price: updateData['price'],
      capitalPrice: updateData['capitalPrice'],
      tax: updateData['tax'],
    );
  }
}