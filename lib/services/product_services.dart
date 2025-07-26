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
  Future<dynamic> listProduct() async {
    final store = await Store.getStore();
    try {
      final response = await _dio.get("$_baseUrl/product/${store['id']}");
      return response;
    } on DioException catch (e) {
      return [];
    }
  }

  Future<dynamic> detailProduct(String id) async {
    try {
      final response = await _dio.get("$_baseUrl/product/$id/detail");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      return [];
    }
  }

  Future<dynamic> storeProduct(FormData body) async {
    try {
      final resp = await _dio.post(
        "$_baseUrl/product/add",
        data: body,
      );
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> destroyProduct(String id) async {
    try {
      final resp = await _dio.delete("$_baseUrl/product/$id/destroy");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> updateProduct(Map<String, dynamic> body, String id) async {
    try {
      var resp = await _dio.post("$_baseUrl/product/$id/update", data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> setFavorite(Map<String, dynamic> body, String id) async {
    try {
      final resp =
          await _dio.post("$_baseUrl/product/$id/favorite", data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> uploadPhotoProduct(String id, FormData body) async {
    try{
      var resp = await _dio.post("$_baseUrl/product/update/$id/image", data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> changeCategoryProduct(String id, Map<String, dynamic> body)  async {
    try{
      var resp = await _dio.post("$_baseUrl/product/update/$id/category", data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  // ============ CATEGORY ============
  Future<dynamic> listCategory() async {
    final store = await Store.getStore();

    try {
      final response =
          await _dio.get("$_baseUrl/product/category/${store['id']}");
      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      return [];
    }
  }

  Future<dynamic> storeCategory(String name) async {
    final store = await Store.getStore();

    try {
      final response = await _dio.post("$_baseUrl/product/category/add",
          data: {"store_id": store['id'], 'name': name});
      if (response.statusCode == 201) {
        return response.data;
      }
    } on DioException catch (e) {
      return [];
    }
  }

  Future<dynamic> removeCategory(String id) async {
    final store = await Store.getStore();
    try {
      final response = await _dio.delete(
        "$_baseUrl/product/category/${id}/destroy",
      );
      if (response.statusCode == 201) {
        return response.data;
      }
    } on DioException catch (e) {
      print(e.response);
      return [];
    }
  }

  Future<dynamic> updateCategory(Map<String, dynamic> body, String id) async {
    try {
      final response =
          await _dio.put("$_baseUrl/product/category/${id}/update", data: body);
      if (response.statusCode == 201) {
        return response.data;
      }
    } on DioException catch (e) {
      print(e.response);
    }
  }

  // ============ END CATEGORY ============
  // ============ VARIANT ============
  Future<dynamic> storeVariant(Map<String, dynamic> body) async {
    try {
      final response =
          await _dio.post("$_baseUrl/product-variant/store", data: body);
      return response.data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> destroyVariant(int id) async {
    try {
      final response =
          await _dio.delete("$_baseUrl/product-variant/destroy/${id}");
      return response.data;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> updateStock(
      BuildContext context, Map<String, dynamic> body, int id) async {
    context.loaderOverlay.show();
    try {
      final response = await _dio.post(
          "$_baseUrl/product-variant/update/$id/update-stock",
          data: body);
      context.loaderOverlay.hide();
      return response;
    } on DioException catch (e) {
      context.loaderOverlay.hide();
      print(e.response);
    }
  }

  Future<dynamic> detailVariant(int id) async {
    try {
      var resp = await _dio.get("$_baseUrl/product-variant/detail/$id");
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }

  Future<dynamic> updateVariant(int id, Map<String, dynamic> body) async {
    try {
      var resp =
          await _dio.post("$_baseUrl/product-variant/update/$id", data: body);
      return resp;
    } on DioException catch (e) {
      print(e.response);
    }
  }
  // ============ END VARIANT ============
}
