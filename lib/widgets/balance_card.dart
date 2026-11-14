import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account_model.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatefulWidget {
  final AccountModel? account;
  final VoidCallback onRefresh;
  final bool isLoading;
  final String? errorMessage;

  const BalanceCard({
    super.key,
    required this.account,
    required this.onRefresh,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    // Strict financial rule: 0.00 is valid decimal and must not be defaulted to 10k
    final balanceText = widget.account != null
        ? '₹${widget.account!.balance}'
        : '₹0.00';

    final accountNumber = widget.account?.accountNumber ?? 'DC-XXXX-XXXX';
    final isOfflineOrError = widget.errorMessage != null || widget.account == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.32),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Label + Shield Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    child: Icon(
                      _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Strict Locks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Big Authoritative Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _isBalanceVisible ? balanceText : '₹ • • • • • •',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                )
              else
                IconButton(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Refresh Authoritative Balance',
                ),
            ],
          ),

          // Status Timestamp / Offline indicator
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOfflineOrError ? Colors.amberAccent : const Color(0xFF34D399),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.isLoading
                    ? 'Syncing with ledger...'
                    : (isOfflineOrError
                        ? (widget.errorMessage ?? 'Offline • Tap refresh')
                        : 'Authoritative Sync • Updated just now'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.15), height: 1),
          const SizedBox(height: 14),

          // Bottom Row: Account Number + Copy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    accountNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      if (widget.account != null) {
                        Clipboard.setData(ClipboardData(text: accountNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account number copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.copy_rounded, color: Colors.white70, size: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'INR • PERSISTENT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
