import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../models/subscription_model.dart';
import '../services/duitku_service.dart';

class PaymentNotifier extends StateNotifier<PaymentState> {
  final DuitkuService _duitkuService;

  PaymentNotifier(this._duitkuService) : super(PaymentState());

  // Load available payment methods
  Future<void> loadPaymentMethods(String amount) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _duitkuService.getPaymentMethods(amount);

      if (result['responseCode'] == '00') {
        final List<dynamic> methods = result['paymentFee'] ?? [];
        final paymentMethods =
            methods.map((method) => PaymentMethod.fromJson(method)).toList();

        state = state.copyWith(
          isLoading: false,
          paymentMethods: paymentMethods,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['responseMessage'] ?? 'Failed to load payment methods',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create payment for subscription package
  Future<PaymentResponse?> createSubscriptionPayment({
    required SubscriptionPackage package,
    required String email,
    required String phoneNumber,
    required String paymentMethod,
    String? customerName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final orderId = _duitkuService.generateOrderId();
      final amount = package.price.toString();

      final paymentRequest = PaymentRequest(
        merchantCode: 'DS17715', // Sandbox merchant code
        paymentAmount: amount,
        paymentMethod: paymentMethod,
        merchantOrderId: orderId,
        productDetails:
            '${package.name} - ${package.duration} Month Subscription',
        email: email,
        phoneNumber: phoneNumber,
        customerVaName: customerName ?? email.split('@').first,
        callbackUrl: _duitkuService.getCallbackUrl(),
        returnUrl: _duitkuService.getReturnUrl(),
      );

      final result = await _duitkuService.createPayment(paymentRequest);

      if (result['statusCode'] == '00') {
        final paymentResponse = PaymentResponse.fromJson(result);
        state = state.copyWith(
          isLoading: false,
          currentPayment: paymentResponse,
        );
        return paymentResponse;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['statusMessage'] ?? 'Payment creation failed',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Check payment status
  Future<void> checkPaymentStatus(String merchantOrderId) async {
    try {
      final result =
          await _duitkuService.checkTransactionStatus(merchantOrderId);

      if (result['statusCode'] == '00') {
        final paymentResponse = PaymentResponse.fromJson(result);
        state = state.copyWith(currentPayment: paymentResponse);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear current payment
  void clearPayment() {
    state = state.copyWith(currentPayment: null, error: null);
  }
}

// Providers
final duitkuServiceProvider = Provider<DuitkuService>((ref) => DuitkuService());

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final duitkuService = ref.watch(duitkuServiceProvider);
  return PaymentNotifier(duitkuService);
});
