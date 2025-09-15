import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';

class DuitkuService {
  static const String _sandboxUrl = 'https://sandbox.duitku.com/webapi/api';
  static const String _productionUrl = 'https://passport.duitku.com/webapi/api';

  // Sandbox credentials - ganti dengan credentials asli
  static const String _merchantCode = 'DS17715';
  static const String _apiKey = '6e6a3bd57b6ce4c71745291979496768';
  static const String _merchantKey =
      'b773007bc59c207cfb4d46bd8e6d9407dbb5e24ffbd8806c9e19d6749bfc526b';

  final bool isProduction;

  DuitkuService({this.isProduction = false});

  String get _baseUrl => isProduction ? _productionUrl : _sandboxUrl;

  // Generate signature for Duitku API
  String _generateSignature(String merchantCode, String merchantOrderId,
      String paymentAmount, String apiKey) {
    final data = '$merchantCode$merchantOrderId$paymentAmount$apiKey';
    final bytes = utf8.encode(data);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // Get available payment methods
  Future<Map<String, dynamic>> getPaymentMethods(String amount) async {
    try {
      final signature =
          _generateSignature(_merchantCode, 'INQUIRY', amount, _apiKey);

      final response = await http.post(
        Uri.parse('$_baseUrl/merchant/paymentmethod/getpaymentmethod'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'merchantcode': _merchantCode,
          'amount': amount,
          'datetime': DateTime.now().millisecondsSinceEpoch.toString(),
          'signature': signature,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to get payment methods: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting payment methods: $e');
    }
  }

  // Create payment transaction
  Future<Map<String, dynamic>> createPayment(PaymentRequest request) async {
    try {
      final signature = _generateSignature(
        request.merchantCode,
        request.merchantOrderId,
        request.paymentAmount,
        _apiKey,
      );

      final body = {
        ...request.toJson(),
        'signature': signature,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/merchant/createinvoice'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  // Check transaction status
  Future<Map<String, dynamic>> checkTransactionStatus(
      String merchantOrderId) async {
    try {
      final signature =
          _generateSignature(_merchantCode, merchantOrderId, '', _apiKey);

      final response = await http.post(
        Uri.parse('$_baseUrl/merchant/transactionStatus'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'merchantcode': _merchantCode,
          'merchantOrderId': merchantOrderId,
          'signature': signature,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking status: $e');
    }
  }

  // Generate unique order ID
  String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'SUB_$timestamp';
  }

  // Format callback and return URLs
  String getCallbackUrl() => 'https://radjakasir.com/payment-callback';
  String getReturnUrl() => 'https://radjakasir.com/payment-callback';
}
