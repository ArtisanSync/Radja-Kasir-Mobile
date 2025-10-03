import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class UserServices {
  late final Dio _dio;

  UserServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  // Get User Profile (Authenticated User)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get("$_baseUrl/users/profile");

      if (response.data['success'] == true) {
        final Map<String, dynamic> user = response.data['data'];
        await Store.saveUser(user);
      }
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, 'Gagal memuat profil');
    }
  }
  Future<Map<String, dynamic>> updateProfile(
      {Map<String, dynamic>? data, XFile? avatarFile}) async {
    try {
      final formData = FormData();

      if (data != null) {
        data.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });
      }

      if (avatarFile != null) {
        if (kIsWeb) {
          formData.files.add(MapEntry(
            'avatar',
            MultipartFile.fromBytes(
              await avatarFile.readAsBytes(),
              filename: avatarFile.name,
              contentType: MediaType("image", avatarFile.name.split('.').last),
            ),
          ));
        } else {
          formData.files.add(MapEntry(
            'avatar',
            await MultipartFile.fromFile(avatarFile.path,
                filename: avatarFile.name),
          ));
        }
      }

      final response = await _dio.put(
        "$_baseUrl/users/profile",
        data: formData,
      );

      if (response.data['success'] == true) {
        final Map<String, dynamic> updatedUser = response.data['data'];
        await Store.saveUser(updatedUser);
      }
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, 'Gagal memperbarui profil');
    }
  }
  // Get All Users (Admin Only)
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await _dio.get("$_baseUrl/users/profile");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to fetch users'
        };
      }
    } on DioException catch (e) {
        return ServiceUtils.handleDioError(e, 'Failed to fetch users');
    }
  }

  // Create a new store member
  Future<Map<String, dynamic>> createMember(Map<String, dynamic> body) async {
    final store = await Store.getStore();
    if (store == null) {
        return {'success': false, 'message': 'Toko aktif tidak ditemukan'};
    }
    try {
      final response = await _dio.post(
        "$_baseUrl/users/${store['id']}/member/store",
        data: body,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to create member'
        };
      }
    } on DioException catch (e) {
        return ServiceUtils.handleDioError(e, 'Failed to create member');
    }
  }

  // Delete a store member (Admin Only)
  Future<Map<String, dynamic>> deleteMember(int id) async {
    try {
      final response = await _dio.delete("$_baseUrl/users/member/destroy/$id");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to delete member'
        };
      }
    } on DioException catch (e) {
        return ServiceUtils.handleDioError(e, 'Failed to delete member');
    }
  }
  
  // Get User Package (Subscription Info)
  Future<Map<String, dynamic>> getPackage(int id) async {
    try {
      final response = await _dio.get("$_baseUrl/users/package/$id");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': response.data['message'],
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.data['message'] ?? 'Failed to fetch package'
        };
      }
    } on DioException catch (e) {
        return ServiceUtils.handleDioError(e, 'Failed to fetch package');
    }
  }
}