class PaymentRequest {
  final String merchantCode;
  final String paymentAmount;
  final String paymentMethod;
  final String merchantOrderId;
  final String productDetails;
  final String email;
  final String phoneNumber;
  final String additionalParam;
  final String merchantUserInfo;
  final String customerVaName;
  final String callbackUrl;
  final String returnUrl;
  final String expiryPeriod;

  PaymentRequest({
    required this.merchantCode,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.merchantOrderId,
    required this.productDetails,
    required this.email,
    required this.phoneNumber,
    this.additionalParam = '',
    this.merchantUserInfo = '',
    required this.customerVaName,
    required this.callbackUrl,
    required this.returnUrl,
    this.expiryPeriod = '1440', // 24 hours default
  });

  Map<String, dynamic> toJson() => {
        'merchantCode': merchantCode,
        'paymentAmount': paymentAmount,
        'paymentMethod': paymentMethod,
        'merchantOrderId': merchantOrderId,
        'productDetails': productDetails,
        'email': email,
        'phoneNumber': phoneNumber,
        'additionalParam': additionalParam,
        'merchantUserInfo': merchantUserInfo,
        'customerVaName': customerVaName,
        'callbackUrl': callbackUrl,
        'returnUrl': returnUrl,
        'expiryPeriod': expiryPeriod,
      };
}

class PaymentResponse {
  final String? merchantCode;
  final String? reference;
  final String? paymentUrl;
  final String? vaNumber;
  final String? amount;
  final String? statusCode;
  final String? statusMessage;

  PaymentResponse({
    this.merchantCode,
    this.reference,
    this.paymentUrl,
    this.vaNumber,
    this.amount,
    this.statusCode,
    this.statusMessage,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      PaymentResponse(
        merchantCode: json['merchantCode'],
        reference: json['reference'],
        paymentUrl: json['paymentUrl'],
        vaNumber: json['vaNumber'],
        amount: json['amount'],
        statusCode: json['statusCode'],
        statusMessage: json['statusMessage'],
      );
}

class PaymentMethod {
  final String code;
  final String name;
  final String type;
  final String image;
  final bool isActive;
  final String fee;

  PaymentMethod({
    required this.code,
    required this.name,
    required this.type,
    required this.image,
    this.isActive = true,
    this.fee = '0',
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        code: json['paymentMethod'] ?? '',
        name: json['paymentName'] ?? '',
        type: json['paymentType'] ?? '',
        image: json['paymentImage'] ?? '',
        isActive: json['isActive'] ?? true,
        fee: json['totalFee']?.toString() ?? '0',
      );
}

class PaymentState {
  final bool isLoading;
  final List<PaymentMethod> paymentMethods;
  final PaymentResponse? currentPayment;
  final String? error;

  PaymentState({
    this.isLoading = false,
    this.paymentMethods = const [],
    this.currentPayment,
    this.error,
  });

  PaymentState copyWith({
    bool? isLoading,
    List<PaymentMethod>? paymentMethods,
    PaymentResponse? currentPayment,
    String? error,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      currentPayment: currentPayment ?? this.currentPayment,
      error: error ?? this.error,
    );
  }
}
