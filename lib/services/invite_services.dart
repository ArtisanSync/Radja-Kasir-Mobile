import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/services/service_utils.dart';

class InviteServices {
  late final Dio _dio;

  InviteServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;
  Future<Map<String, dynamic>> acceptInvitation({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post("$_baseUrl/invites/accept", data: {
        'email': email,
        'password': password,
        'name': name,
      });
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, "Gagal menerima undangan");
    }
  }
  Future<Map<String, dynamic>> inviteMember({
    required String storeId,
    required String name,
    required String email,
  }) async {
    try {
      final response = await _dio.post("$_baseUrl/invites", data: {
        'storeId': storeId,
        'invitedName': name,
        'invitedEmail': email,
        'role': 'CASHIER',
      });
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, "Gagal mengirim undangan");
    }
  }

  /// Mendapatkan daftar anggota yang sudah bergabung
  Future<Map<String, dynamic>> getStoreMembers(String storeId) async {
    try {
      final response =
          await _dio.get("$_baseUrl/invites/store/$storeId/members");
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, "Gagal memuat anggota");
    }
  }

  /// Mendapatkan daftar undangan yang masih pending
  Future<Map<String, dynamic>> getStoreInvitations(String storeId) async {
    try {
      final response = await _dio.get("$_baseUrl/invites/store/$storeId");
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, "Gagal memuat undangan");
    }
  }
  
  /// Membatalkan undangan yang masih pending
  Future<Map<String, dynamic>> revokeInvitation(String inviteId) async {
    try {
      final response = await _dio.delete("$_baseUrl/invites/$inviteId");
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, "Gagal membatalkan undangan");
    }
  }

  Future<Map<String, dynamic>> removeMember({
    required String storeId,
    required String memberId,
  }) async {
    try {
      final response = await _dio
          .delete("$_baseUrl/invites/store/$storeId/members/$memberId");
      return response.data;
    } on DioException catch (e) {
      return ServiceUtils.handleDioError(e, "Gagal mengeluarkan anggota");
    }
  }
}