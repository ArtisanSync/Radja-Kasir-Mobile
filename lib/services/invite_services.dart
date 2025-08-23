import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class InviteServices {
  late final Dio _dio;

  InviteServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  // Get store members
  Future<dynamic> getMembers(String storeId) async {
    try {
      final response = await _dio.get("$_baseUrl/invites/store/$storeId/members");
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  // Invite new member
  Future<dynamic> inviteMember(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("$_baseUrl/invites", data: data);
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  // Revoke invitation
  Future<dynamic> revokeInvitation(String inviteId) async {
    try {
      final response = await _dio.delete("$_baseUrl/invites/$inviteId");
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  // Remove member
  Future<dynamic> removeMember(String storeId, String memberId) async {
    try {
      final response = await _dio.delete(
        "$_baseUrl/invites/store/$storeId/members/$memberId"
      );
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }
}
