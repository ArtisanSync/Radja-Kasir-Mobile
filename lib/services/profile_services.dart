import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/service_utils.dart';

class ProfileServices {
  late final Dio _dio;

  ProfileServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  final String _baseUrl = ServiceUtils().baseUrl;

  Future<dynamic> detailStore() async {
    final store = await Store.getStore();
    final response = await _dio.get("$_baseUrl/setting/store/${store['id']}");
    if (response.statusCode == 200) {
      return response.data;
    }
  }

  Future<dynamic> profile() async {
    final user = await Store.getUser();
    final resp = await _dio.get("$_baseUrl/settings/profile/${user['id']}");
    try {
      return resp;
    } on DioException catch (e) {
      return e;
    }
  }

  Future<dynamic> update(Map<String, dynamic> body) async {
    final store = await Store.getStore();
    final resp = await _dio
        .post("$_baseUrl/settings/store/${store['id']}/update", data: body);
    try {
      return resp;
    } on DioException catch (e) {
      return e;
    }
  }

  Future<dynamic> uploadLogo(FormData body) async {
    final store = await Store.getStore();
    final resp = await _dio.post(
        "$_baseUrl/settings/store/${store['id']}/logo/upload",
        data: body);
    try {
      return resp;
    } on DioException catch (e) {
      return e;
    }
  }

  Future<dynamic> uploadStamp(FormData body) async {
    final store = await Store.getStore();
    final resp = await _dio.post(
        "$_baseUrl/settings/store/${store['id']}/stamp/upload",
        data: body);
    try {
      return resp;
    } on DioException catch (e) {
      return e;
    }
  }

  // settings/store/2bc24ffe-7d51-11ee-a870-9d9102b9ccf2/logo/upload
}
