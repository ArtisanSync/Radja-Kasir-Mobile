import 'package:dio/dio.dart';
import 'package:kasir/core/dio_intercaptor.dart';
import 'package:kasir/helpers/store.dart';
import 'package:kasir/services/service_utils.dart';

class StoreServices {
  late final Dio _dio;
  final String _baseUrl = ServiceUtils().baseUrl;

  StoreServices() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptor());
  }

  // Mendapatkan daftar toko user
  Future<Map<String, dynamic>> getMyStores() async {
    try {
      final response = await _dio.get("$_baseUrl/stores/my-stores");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Daftar toko berhasil diambil'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mengambil daftar toko',
        'data': []
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan jaringan',
        'data': []
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga',
        'data': []
      };
    }
  }

  // Mendapatkan detail toko
  Future<Map<String, dynamic>> getStoreDetail(String storeId) async {
    try {
      final response = await _dio.get("$_baseUrl/stores/$storeId");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Detail toko berhasil diambil'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mengambil detail toko',
        'data': null
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan jaringan',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga',
        'data': null
      };
    }
  }

  // Membuat toko pertama
  Future<Map<String, dynamic>> createFirstStore(Map<String, dynamic> storeData) async {
    try {
      final response = await _dio.post(
        "$_baseUrl/stores/first",
        data: storeData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Simpan toko baru ke local storage
        await Store.saveStore(response.data['data']);
        
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Toko pertama berhasil dibuat'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal membuat toko',
        'data': null
      };
    } on DioException catch (e) {
      // Cek apakah error karena subscription
      if (e.response?.statusCode == 403 && 
          e.response?.data['data']?['subscriptionRequired'] == true) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Langganan diperlukan',
          'data': e.response?.data['data'],
          'subscriptionRequired': true
        };
      }
      
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan jaringan',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga',
        'data': null
      };
    }
  }

  // Membuat toko tambahan
  Future<Map<String, dynamic>> createStore(Map<String, dynamic> storeData) async {
    try {
      final response = await _dio.post(
        "$_baseUrl/stores",
        data: storeData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Toko berhasil dibuat'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal membuat toko',
        'data': null
      };
    } on DioException catch (e) {
      // Cek apakah error karena subscription
      if (e.response?.statusCode == 403 && 
          e.response?.data['data']?['subscriptionRequired'] == true) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Langganan diperlukan',
          'data': e.response?.data['data'],
          'subscriptionRequired': true
        };
      }
      
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan jaringan',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga',
        'data': null
      };
    }
  }

  // Update toko
  Future<Map<String, dynamic>> updateStore(String storeId, Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.put(
        "$_baseUrl/stores/$storeId",
        data: updateData,
      );

      if (response.statusCode == 200) {
        // Update toko di local storage jika itu toko aktif
        final currentStore = await Store.getStore();
        if (currentStore != null && currentStore['id'] == storeId) {
          await Store.saveStore(response.data['data']);
        }
        
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Toko berhasil diperbarui'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal memperbarui toko',
        'data': null
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan jaringan',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga',
        'data': null
      };
    }
  }

  // Delete toko
  Future<Map<String, dynamic>> deleteStore(String storeId) async {
    try {
      final response = await _dio.delete("$_baseUrl/stores/$storeId");

      if (response.statusCode == 200) {
        // Jika toko yang dihapus adalah toko aktif, hapus dari local storage
        final currentStore = await Store.getStore();
        if (currentStore != null && currentStore['id'] == storeId) {
          await Store.removeStore();
        }
        
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Toko berhasil dihapus'
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal menghapus toko',
        'data': null
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan jaringan',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga',
        'data': null
      };
    }
  }
}