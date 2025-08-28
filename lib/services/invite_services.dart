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

  // Invite member
  Future<Map<String, dynamic>> inviteMember(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("$_baseUrl/invites", data: data);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Undangan berhasil dikirim',
          'data': response.data['data']
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mengirim undangan',
        'data': null
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mengirim undangan',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': null
      };
    }
  }

  // Get store members
  Future<Map<String, dynamic>> getStoreMembers(String storeId) async {
    try {
      final response = await _dio.get("$_baseUrl/invites/store/$storeId/members");
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Daftar member berhasil diambil',
          'data': response.data['data'] ?? []
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mendapatkan daftar member',
        'data': []
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mendapatkan daftar member',
        'data': []
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': []
      };
    }
  }
  
  // Revoke invitation
  Future<Map<String, dynamic>> revokeInvitation(String inviteId) async {
    try {
      final response = await _dio.delete("$_baseUrl/invites/$inviteId");
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Undangan berhasil dibatalkan',
          'data': response.data['data']
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal membatalkan undangan',
        'data': null
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal membatalkan undangan',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': null
      };
    }
  }
}
