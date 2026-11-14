import 'package:flutter_test/flutter_test.dart';
import 'package:datacore_mobile/models/account_model.dart';
import 'package:datacore_mobile/models/transaction_model.dart';
import 'package:datacore_mobile/models/user_model.dart';

void main() {
  group('AccountModel Tests - Financial Balance Integrity', () {
    test('Zero balance "0.00" is strictly preserved and never defaults to 10,000', () {
      final json = {
        'id': 'acc-123',
        'account_number': 'DC-USER-001',
        'user_email': 'user@example.com',
        'user_name': 'Test User',
        'balance': '0.00',
        'currency': 'INR',
        'version': 1,
        'is_active': true,
        'created_at': '2026-01-01T00:00:00Z',
      };

      final account = AccountModel.fromJson(json);
      expect(account.balance, '0.00');
      expect(account.balance, isNot('10000.00'));
      expect(account.balance, isNot('10000'));
      expect(account.accountNumber, 'DC-USER-001');
      expect(account.version, 1);
      expect(account.isActive, true);
    });

    test('Numeric zero balance is safely converted to string', () {
      final json = {
        'id': 'acc-124',
        'account_number': 'DC-USER-002',
        'balance': 0,
        'version': '3',
        'is_active': false,
      };

      final account = AccountModel.fromJson(json);
      expect(account.balance, '0');
      expect(account.version, 3);
      expect(account.isActive, false);
    });

    test('Missing balance gracefully defaults to "0.00"', () {
      final json = {
        'id': 'acc-125',
      };

      final account = AccountModel.fromJson(json);
      expect(account.balance, '0.00');
    });
  });

  group('TransactionModel Tests', () {
    test('Parses complete transaction correctly', () {
      final json = {
        'id': 'tx-789',
        'sender_account': 'acc-1',
        'sender_account_number': 'DC-001',
        'sender_email': 'alice@example.com',
        'receiver_account': 'acc-2',
        'receiver_account_number': 'DC-002',
        'receiver_email': 'bob@example.com',
        'amount': '500.00',
        'currency': 'INR',
        'status': 'COMPLETED',
        'concurrency_strategy': 'PESSIMISTIC',
        'idempotency_key': 'idem-key-123',
        'description': 'Lunch money',
        'latency_ms': 12.5,
        'created_at': '2026-01-01T12:00:00Z',
        'completed_at': '2026-01-01T12:00:01Z',
      };

      final tx = TransactionModel.fromJson(json);
      expect(tx.id, 'tx-789');
      expect(tx.amount, '500.00');
      expect(tx.status, 'COMPLETED');
      expect(tx.latencyMs, 12.5);
      expect(tx.senderAccountNumber, 'DC-001');
      expect(tx.receiverAccountNumber, 'DC-002');
    });
  });

  group('UserModel Tests', () {
    test('Serializes and deserializes cleanly', () {
      final json = {
        'id': 'user-001',
        'email': 'admin@datacore.io',
        'full_name': 'Admin Lead',
        'role': 'ADMIN',
        'date_joined': '2026-01-01T00:00:00Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'user-001');
      expect(user.role, 'ADMIN');

      final serialized = user.toJson();
      expect(serialized['email'], 'admin@datacore.io');
      expect(serialized['role'], 'ADMIN');
    });
  });
}
