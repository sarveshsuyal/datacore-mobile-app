import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class UpiPinSheet extends StatefulWidget {
  final double amount;
  final String recipient;
  final String bankName;
  final ValueChanged<String> onPinSubmitted;

  const UpiPinSheet({
    super.key,
    required this.amount,
    required this.recipient,
    required this.bankName,
    required this.onPinSubmitted,
  });

  @override
  State<UpiPinSheet> createState() => _UpiPinSheetState();
}

class _UpiPinSheetState extends State<UpiPinSheet> {
  String _pin = '';

  void _onKeyPress(String val) {
    HapticFeedback.lightImpact();
    if (_pin.length < 4) {
      setState(() {
        _pin += val;
      });
      if (_pin.length == 4) {
        widget.onPinSubmitted(_pin);
      }
    }
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Widget _buildKeypadButton(String label, {VoidCallback? onTap, Widget? customChild}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: InkWell(
          onTap: onTap ?? () => _onKeyPress(label),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: customChild ??
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline_rounded, color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ENTER 4-DIGIT UPI PIN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Payment Summary Strip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paying to ${widget.recipient}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.bankName,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Text(
                  '₹${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PIN Indicator Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppTheme.primary : Colors.white,
                  border: Border.all(
                    color: isFilled ? AppTheme.primary : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Keypad Rows
          Row(
            children: [
              _buildKeypadButton('1'),
              _buildKeypadButton('2'),
              _buildKeypadButton('3'),
            ],
          ),
          Row(
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
            ],
          ),
          Row(
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
            ],
          ),
          Row(
            children: [
              _buildKeypadButton(
                '',
                onTap: _onBackspace,
                customChild: const Icon(Icons.backspace_outlined, size: 20, color: AppTheme.textDark),
              ),
              _buildKeypadButton('0'),
              _buildKeypadButton(
                '',
                onTap: () {
                  if (_pin.length == 4) {
                    widget.onPinSubmitted(_pin);
                  }
                },
                customChild: Icon(
                  Icons.check_circle_rounded,
                  size: 26,
                  color: _pin.length == 4 ? AppTheme.accent : Colors.grey.shade400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Text(
            'Secured by DataCore Cryptographic Invariant Ledger',
            style: TextStyle(fontSize: 10, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }
}
