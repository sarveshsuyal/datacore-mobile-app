import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ReceiveQrSheet extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String accountNumber;
  final String? avatarUrl;

  const ReceiveQrSheet({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.accountNumber,
    this.avatarUrl,
  });

  String get upiHandle {
    final cleanEmail = userEmail.isNotEmpty ? userEmail : 'customer@datacore';
    return cleanEmail.contains('@') ? cleanEmail : '$cleanEmail@datacore';
  }

  @override
  Widget build(BuildContext context) {
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Receive Money',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Scan & Pay via any UPI App (DataCore, BHIM, GPay)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // QR Card with Centered Profile Photo (PFP)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // QR Box with custom painter and center avatar
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: _QrMatrixPainter(seed: upiHandle.hashCode),
                      ),
                      // Center PFP Avatar
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: avatarUrl != null && avatarUrl!.startsWith('http')
                              ? Image.network(
                                  avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Name & Verified Badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userName.isNotEmpty ? userName : 'Customer',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'DataCore High-Concurrency Account',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary UPI Handle Card with Copy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRIMARY UPI ID',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        upiHandle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: upiHandle));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UPI ID copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Copy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Share QR & Done
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: 'upi://pay?pa=$upiHandle&pn=$userName&cu=INR'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UPI payment link copied!')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Share Link'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Dynamic QR Matrix painter that renders realistic QR code pattern with finder patterns and center cutout
class _QrMatrixPainter extends CustomPainter {
  final int seed;

  _QrMatrixPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    const int modules = 29;
    final double moduleSize = size.width / modules;

    final random = Random(seed);

    // Draw finder pattern helper
    void drawFinder(double x, double y) {
      // Outer 7x7 box
      canvas.drawRect(
        Rect.fromLTWH(x, y, 7 * moduleSize, 7 * moduleSize),
        paint,
      );
      // Inner 5x5 white space
      canvas.drawRect(
        Rect.fromLTWH(x + moduleSize, y + moduleSize, 5 * moduleSize, 5 * moduleSize),
        Paint()..color = Colors.white,
      );
      // Center 3x3 box
      canvas.drawRect(
        Rect.fromLTWH(x + 2 * moduleSize, y + 2 * moduleSize, 3 * moduleSize, 3 * moduleSize),
        paint,
      );
    }

    // Top-left finder
    drawFinder(0, 0);
    // Top-right finder
    drawFinder((modules - 7) * moduleSize, 0);
    // Bottom-left finder
    drawFinder(0, (modules - 7) * moduleSize);

    // Center cutout area for avatar (modules 11 to 17)
    final centerStart = 10;
    final centerEnd = 18;

    // Draw data matrix modules
    for (int r = 0; r < modules; r++) {
      for (int c = 0; c < modules; c++) {
        // Skip finder areas
        if (r < 8 && c < 8) continue;
        if (r < 8 && c >= modules - 8) continue;
        if (r >= modules - 8 && c < 8) continue;

        // Skip center cutout
        if (r >= centerStart && r <= centerEnd && c >= centerStart && c <= centerEnd) {
          continue;
        }

        // Timing patterns
        if (r == 6 || c == 6) {
          if ((r + c) % 2 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(c * moduleSize + 0.5, r * moduleSize + 0.5, moduleSize - 1, moduleSize - 1),
              paint,
            );
          }
          continue;
        }

        // Pseudo-random data module
        if (random.nextDouble() > 0.45) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * moduleSize + 0.5, r * moduleSize + 0.5, moduleSize - 1, moduleSize - 1),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) => oldDelegate.seed != seed;
}
