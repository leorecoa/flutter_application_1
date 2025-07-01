class PixPayment {
  final String paymentId;
  final double amount;
  final String description;
  final String status;
  final String? pixCode;
  final String? pixQrCodeBase64;
  final DateTime createdAt;

  PixPayment({
    required this.paymentId,
    required this.amount,
    required this.description,
    required this.status,
    this.pixCode,
    this.pixQrCodeBase64,
    required this.createdAt,
  });

  factory PixPayment.fromJson(Map<String, dynamic> json) {
    return PixPayment(
      paymentId: json['paymentId'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      status: json['status'],
      pixCode: json['pixCode'],
      pixQrCodeBase64: json['pixQrCodeBase64'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isPaid => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
}