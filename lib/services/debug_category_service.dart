import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/product_services.dart';
import 'package:kasir/services/store_services.dart';

class DebugCategoryService {
  static final ProductServices _productServices = ProductServices();
  static final StoreServices _storeServices = StoreServices();

  static Future<Map<String, dynamic>> debugStoreInfo() async {
    try {
      final token = await Store.getToken();
      final user = await Store.getUser();
      final store = await Store.getStore();

      return {
        'success': true,
        'data': {
          'token': token,
          'user': user,
          'store': store,
          'hasToken': token != null,
          'hasUser': user != null,
          'hasStore': store != null,
          'storeId': store?['id'],
        }
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> initializeStoreData() async {
    try {
      final initialized = await _storeServices.initializeStore();
      if (initialized) {
        final store = await Store.getStore();
        return {
          'success': true,
          'message': 'Store data initialized successfully',
          'data': store,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to initialize store data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error initializing store: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> testCategoryAPI() async {
    try {
      // First check store info
      final storeInfo = await debugStoreInfo();
      if (!storeInfo['success']) {
        return {
          'success': false,
          'message': 'Failed to get store info: ${storeInfo['error']}',
        };
      }

      final store = storeInfo['data']['store'];
      if (store == null || store['id'] == null) {
        // Try to initialize store data
        final initResult = await initializeStoreData();
        if (!initResult['success']) {
          return {
            'success': false,
            'message':
                'Store information not found. Init failed: ${initResult['message']}',
          };
        }
      }

      // Try to call API
      final result = await _productServices.listCategory();
      return {
        'success': result['success'],
        'message': result['message'],
        'data': result['data'],
        'storeInfo': storeInfo['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'API Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> testCreateCategory(String name) async {
    try {
      // First check store info
      final storeInfo = await debugStoreInfo();
      if (!storeInfo['success']) {
        return {
          'success': false,
          'message': 'Failed to get store info: ${storeInfo['error']}',
        };
      }

      final store = storeInfo['data']['store'];
      if (store == null || store['id'] == null) {
        // Try to initialize store data
        final initResult = await initializeStoreData();
        if (!initResult['success']) {
          return {
            'success': false,
            'message':
                'Store information not found. Init failed: ${initResult['message']}',
          };
        }
      }

      // Try to create category
      final result = await _productServices.storeCategory(name);
      return {
        'success': result['success'],
        'message': result['message'],
        'data': result['data'],
        'storeInfo': storeInfo['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'API Error: $e',
      };
    }
  }
}
