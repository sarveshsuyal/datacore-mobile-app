class TransactionModel {
  final String id;
  final String? senderAccount;
  final String senderAccountNumber;
  final String senderEmail;
  final String receiverAccount;
  final String receiverAccountNumber;
  final String receiverEmail;
  final String amount;
  final String currency;
  final String status;
  final String concurrencyStrategy;
  final String? idempotencyKey;
  final String description;
  final double latencyMs;
  final String createdAt;
  final String? completedAt;

  TransactionModel({
    required this.id,
    this.senderAccount,
    required this.senderAccountNumber,
    required this.senderEmail,
    required this.receiverAccount,
    required this.receiverAccountNumber,
    required this.receiverEmail,
    required this.amount,
    required this.currency,
    required this.status,
    required this.concurrencyStrategy,
    this.idempotencyKey,
    required this.description,
    required this.latencyMs,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      senderAccount: json['sender_account'],
      senderAccountNumber: json['sender_account_number'] ?? 'SYSTEM_DEPOSIT',
      senderEmail: json['sender_email'] ?? 'system@datacore.io',
      receiverAccount: json['receiver_account'] ?? '',
      receiverAccountNumber: json['receiver_account_number'] ?? '',
      receiverEmail: json['receiver_email'] ?? '',
      amount: json['amount'] ?? '0.00',
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? 'PENDING',
      concurrencyStrategy: json['concurrency_strategy'] ?? 'PESSIMISTIC',
      idempotencyKey: json['idempotency_key'],
      description: json['description'] ?? '',
      latencyMs: (json['latency_ms'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] ?? '',
      completedAt: json['completed_at'],
    );
  }
}
