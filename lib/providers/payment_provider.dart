import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../models/subscription_model.dart';
import '../services/payment_services.dart';

final paymentServiceProvider =
    Provider<PaymentServices>((ref) => PaymentServices());

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentServices _paymentServices;

  PaymentNotifier(this._paymentServices) : super(PaymentState());

  Future<String?> createSubscriptionPayment({
    required SubscriptionPackage package,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result =
          await _paymentServices.createSubscriptionPayment(package.id);

      if (result['success'] == true) {
        final paymentData = result['data'];
        final paymentUrl = paymentData['paymentUrl'] as String?;
        state = state.copyWith(isLoading: false);
        return paymentUrl;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] ?? 'Gagal membuat link pembayaran',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Terjadi kesalahan: ${e.toString()}",
      );
      return null;
    }
  }

  Future<void> checkPaymentStatus(String merchantOrderId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _paymentServices.checkPaymentStatus(merchantOrderId);

      if (result['success'] == true) {
      } else {
        state = state.copyWith(error: result['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearPayment() {
    state = state.copyWith(currentPayment: null, error: null);
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final paymentServices = ref.watch(paymentServiceProvider);
  return PaymentNotifier(paymentServices);
});
