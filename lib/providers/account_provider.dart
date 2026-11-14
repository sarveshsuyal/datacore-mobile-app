import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class AccountProvider with ChangeNotifier {
  final ApiService _apiService;
  AccountModel? _primaryAccount;
  List<TransactionModel> _recentTransactions = [];
  TransactionModel? _lastExecutedTransaction;
  bool _isLoading = false;
  String? _errorMessage;
  double _upiLiteBalance = 0.0;

  // Real-Time Event Tracking & Deduplication
  Timer? _eventPollTimer;
  final Set<String> _processedEventIds = {};
  String? _lastIncomingNotification;

  AccountProvider(this._apiService) {
    startEventSync();
  }

  AccountModel? get primaryAccount => _primaryAccount;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  TransactionModel? get lastExecutedTransaction => _lastExecutedTransaction;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get upiLiteBalance => _upiLiteBalance;
  String? get lastIncomingNotification => _lastIncomingNotification;

  void clearIncomingNotification() {
    _lastIncomingNotification = null;
    notifyListeners();
  }

  void startEventSync() {
    _eventPollTimer?.cancel();
    _eventPollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await pollIncomingEvents();
    });
  }

  void stopEventSync() {
    _eventPollTimer?.cancel();
    _eventPollTimer = null;
  }

  Future<void> pollIncomingEvents() async {
    try {
      final token = await _apiService.storage.read(key: 'access_token');
      if (token == null || token.isEmpty) return;

      final response = await _apiService.dio.get('/api/events/my/');
      final List list = response.data is List ? response.data : [];
      bool hasNewEvent = false;

      for (final ev in list) {
        final String eventId = ev['id']?.toString() ?? '';
        if (eventId.isEmpty || _processedEventIds.contains(eventId)) continue;
        _processedEventIds.add(eventId);

        final String eventType = ev['event_type'] ?? '';
        final details = ev['details'] is Map ? ev['details'] : {};

        if (eventType == 'TX_COMPLETED' ||
            eventType == 'account.balance_changed' ||
            eventType == 'LEDGER_COMMITTED') {
          hasNewEvent = true;
          final amt = details['amount'] ?? details['sender_new_balance'];
          if (amt != null) {
            _lastIncomingNotification = 'Transaction updated: ₹$amt';
          }
        }
      }

      if (hasNewEvent) {
        await fetchAccounts();
        await fetchTransactions();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    stopEventSync();
    super.dispose();
  }

  Future<void> fetchAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/api/accounts/');
      final List list = response.data is List ? response.data : response.data['results'] ?? [];
      if (list.isNotEmpty) {
        _primaryAccount = AccountModel.fromJson(list.first);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load account details.';
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await _apiService.dio.get('/api/transactions/');
      final List list = response.data is List ? response.data : response.data['results'] ?? [];
      _recentTransactions = list.map((json) => TransactionModel.fromJson(json)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> executeTransfer({
    required String receiverIdentifier,
    required double amount,
    String description = '',
    String concurrencyStrategy = 'PESSIMISTIC',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Generate unique UUID v4 idempotency key for client-side duplicate protection
    final String idempotencyKey = const Uuid().v4();

    try {
      final response = await _apiService.dio.post(
        '/api/transactions/',
        data: {
          'receiver_identifier': receiverIdentifier.trim(),
          'amount': amount.toStringAsFixed(2),
          'description': description.trim(),
          'concurrency_strategy': concurrencyStrategy,
        },
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : {'id': idempotencyKey, 'amount': amount.toStringAsFixed(2)};

      _lastExecutedTransaction = TransactionModel.fromJson(data);

      // Refresh accounts & transactions after successful transfer
      await fetchAccounts();
      await fetchTransactions();

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        final detail = data['detail'];
        if (detail is List && detail.isNotEmpty) {
          _errorMessage = detail.first.toString();
        } else if (detail is String) {
          _errorMessage = detail;
        } else if (data['non_field_errors'] is List && (data['non_field_errors'] as List).isNotEmpty) {
          _errorMessage = (data['non_field_errors'] as List).first.toString();
        } else if (data['error'] is String) {
          _errorMessage = data['error'];
        } else {
          _errorMessage = 'Transfer failed. Check balance or recipient.';
        }
      } else {
        _errorMessage = 'Transfer failed. Check balance or recipient.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unexpected transfer error.';
      notifyListeners();
      return false;
    }
  }

  void topUpUpiLite(double amount) {
    if (_primaryAccount != null) {
      final currentBal = double.tryParse(_primaryAccount!.balance) ?? 0.0;
      if (amount <= currentBal) {
        _upiLiteBalance += amount;
        notifyListeners();
      }
    }
  }

  bool executeUpiLiteTransfer({
    required String receiverIdentifier,
    required double amount,
  }) {
    if (amount <= _upiLiteBalance) {
      _upiLiteBalance -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }
}
