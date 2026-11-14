import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onToMobile;
  final VoidCallback onToBank;
  final VoidCallback onScanQr;
  final VoidCallback onReceiveMoney;

  const QuickActionsGrid({
    super.key,
    required this.onToMobile,
    required this.onToBank,
    required this.onScanQr,
    required this.onReceiveMoney,
  });

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: iconColor.withOpacity(0.15), width: 1),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            icon: Icons.phone_android_rounded,
            label: 'To Mobile',
            iconColor: AppTheme.primary,
            bgColor: const Color(0xFFF3E8FF),
            onTap: onToMobile,
          ),
          _buildActionItem(
            icon: Icons.account_balance_rounded,
            label: 'To Bank / UPI',
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            onTap: onToBank,
          ),
          _buildActionItem(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan QR',
            iconColor: const Color(0xFF0D9488),
            bgColor: const Color(0xFFF0FDFA),
            onTap: onScanQr,
          ),
          _buildActionItem(
            icon: Icons.qr_code_2_rounded,
            label: 'Receive',
            iconColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            onTap: onReceiveMoney,
          ),
        ],
      ),
    );
  }
}
