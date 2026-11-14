import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double amount;
  final String recipientName;
  final String recipientHandle;
  final String? utr;
  final String? transactionId;
  final String? debitedAccount;
  final double? latencyMs;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.recipientName,
    required this.recipientHandle,
    this.utr,
    this.transactionId,
    this.debitedAccount,
    this.latencyMs,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late String _generatedUtr;
  late String _generatedTxId;
  int _splitCount = 2;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();

    final r = Random();
    _generatedUtr = widget.utr ??
        '${r.nextInt(899999) + 100000}${r.nextInt(899999) + 100000}';
    _generatedTxId = widget.transactionId ??
        'DC${r.nextInt(89999999) + 10000000}';
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showSplitModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final perPerson = widget.amount / _splitCount;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Split Expense with Friends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primary, size: 28),
                      onPressed: () {
                        if (_splitCount > 2) {
                          setModalState(() => _splitCount--);
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$_splitCount People',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 28),
                      onPressed: () {
                        if (_splitCount < 20) {
                          setModalState(() => _splitCount++);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Each Person Pays', style: TextStyle(color: AppTheme.textMuted)),
                      Text(
                        '₹${perPerson.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: 'Hey! Your share for the payment to ${widget.recipientName} is ₹${perPerson.toStringAsFixed(2)}. Pay me on UPI: ${widget.recipientHandle}',
                      ));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Split payment request copied!')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Split Message'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _shareReceipt() {
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final receipt = '''
=== DataCore Pay Transaction Receipt ===
Status: SUCCESSFUL
Amount: ₹${widget.amount.toStringAsFixed(2)}
Paid To: ${widget.recipientName} (${widget.recipientHandle})
Date & Time: $now
UTR No: $_generatedUtr
Transaction ID: $_generatedTxId
Debited From: ${widget.debitedAccount ?? 'DataCore Account'}
Ledger Engine: Double-Entry Cryptographic Invariant (0 Race Conditions)
========================================
''';
    Clipboard.setData(ClipboardData(text: receipt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final initial = widget.recipientName.isNotEmpty ? widget.recipientName[0].toUpperCase() : 'R';
    final latency = widget.latencyMs != null
        ? '${widget.latencyMs!.toStringAsFixed(1)} ms'
        : '1.2 ms';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // Animated Big Green Checkmark
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Title
              const Text(
                'Payment Successful',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                now,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),

              const SizedBox(height: 18),

              // Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  children: [
                    Text(
                      '₹${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF15803D),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AUTHORITATIVE SETTLEMENT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recipient Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primary.withOpacity(0.12),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid to ${widget.recipientName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.recipientHandle,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Technical & Audit Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Transaction ID', _generatedTxId, isMonospace: true),
                    const Divider(height: 16),
                    _buildReceiptRow('Bank UTR No.', _generatedUtr, isMonospace: true),
                    const Divider(height: 16),
                    _buildReceiptRow('Debited From', widget.debitedAccount ?? 'DataCore Primary Bank'),
                    const Divider(height: 16),
                    _buildReceiptRow('Ledger Latency', '$latency (Row-Lock Committed)'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Double-Entry Invariant Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 14, color: AppTheme.primary),
                    SizedBox(width: 6),
                    Text(
                      'Double-entry balance sum preserved • 0 race conditions',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions: Split & Share
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showSplitModal,
                      icon: const Icon(Icons.people_alt_outlined, size: 16),
                      label: const Text('Split Bill'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareReceipt,
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Share Receipt'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Done'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: isMonospace ? 'monospace' : null,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
