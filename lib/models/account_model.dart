class AccountModel {
  final String id;
  final String accountNumber;
  final String userEmail;
  final String userName;
  final String balance;
  final String currency;
  final int version;
  final bool isActive;
  final String createdAt;

  AccountModel({
    required this.id,
    required this.accountNumber,
    required this.userEmail,
    required this.userName,
    required this.balance,
    required this.currency,
    required this.version,
    required this.isActive,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      balance: json['balance']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'INR',
      version: json['version'] is int
          ? json['version']
          : int.tryParse(json['version']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active']?.toString().toLowerCase() != 'false'),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
