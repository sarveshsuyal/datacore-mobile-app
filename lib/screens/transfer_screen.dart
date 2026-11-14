import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/upi_pin_sheet.dart';
import '../widgets/success_receipt_screen.dart';

class TransferScreen extends StatefulWidget {
  final String? initialRecipient;

  const TransferScreen({super.key, this.initialRecipient});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late final TextEditingController _recipientController;
  final TextEditingController _amountController = TextEditingController(text: '250.00');
  final TextEditingController _descController = TextEditingController(text: 'Fund Transfer');
  String _concurrencyStrategy = 'PESSIMISTIC';

  @override
  void initState() {
    super.initState();
    _recipientController = TextEditingController(
      text: widget.initialRecipient?.isNotEmpty == true
          ? widget.initialRecipient!
          : 'bob@datacore.io',
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addAmount(double delta) {
    final cur = double.tryParse(_amountController.text) ?? 0.0;
    _amountController.text = (cur + delta).toStringAsFixed(2);
  }

  void _fillMaxAmount() {
    final bal = context.read<AccountProvider>().primaryAccount?.balance;
    if (bal != null) {
      _amountController.text = bal;
    }
  }

  void _onProceedToPay() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final recipient = _recipientController.text.trim();

    if (recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipient UPI ID or email.')),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    // Open UPI PIN verification bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UpiPinSheet(
        amount: amount,
        recipient: recipient,
        bankName: 'DataCore Primary Account',
        onPinSubmitted: (pin) async {
          Navigator.pop(ctx);
          _executeTransfer(amount, recipient);
        },
      ),
    );
  }

  Future<void> _executeTransfer(double amount, String recipient) async {
    final accountProvider = context.read<AccountProvider>();

    final success = await accountProvider.executeTransfer(
      receiverIdentifier: recipient,
      amount: amount,
      description: _descController.text,
      concurrencyStrategy: _concurrencyStrategy,
    );

    if (!mounted) return;

    if (success) {
      final tx = accountProvider.lastExecutedTransaction;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: amount,
            recipientName: recipient.contains('@') ? recipient.split('@').first.toUpperCase() : recipient,
            recipientHandle: recipient,
            utr: tx?.idempotencyKey?.replaceAll('-', '').substring(0, 12),
            transactionId: tx?.id,
            debitedAccount: accountProvider.primaryAccount?.accountNumber,
            latencyMs: tx?.latencyMs,
          ),
        ),
      );
    }
  }

  Widget _buildPayeeChip(String name, String email) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _recipientController.text = email;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppTheme.primary.withOpacity(0.12),
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Send Money', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (accountProvider.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          accountProvider.errorMessage!,
                          style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Quick Payees Carousel
              const Text('RECENT PAYEES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPayeeChip('Bob', 'bob@datacore.io'),
                    _buildPayeeChip('Alice', 'alice@datacore.io'),
                    _buildPayeeChip('Charlie', 'charlie@datacore.io'),
                    _buildPayeeChip('Merchant', 'merchant@datacore'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recipient Input Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RECIPIENT (UPI ID OR EMAIL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        hintText: 'Enter UPI ID / Email',
                        prefixIcon: Icon(Icons.person_pin_rounded, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Amount Input Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TRANSFER AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                        Text(
                          'Bal: ₹${accountProvider.primaryAccount?.balance ?? '0.00'}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        hintText: '0.00',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick Chips
                    Row(
                      children: [
                        _buildQuickAmountChip('+₹100', () => _addAmount(100)),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip('+₹500', () => _addAmount(500)),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip('+₹1,000', () => _addAmount(1000)),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip('Max', _fillMaxAmount),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Note & Concurrency Strategy
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TRANSFER NOTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Lunch split, Rent, Coffee',
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('CONCURRENCY STRATEGY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _concurrencyStrategy,
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(
                          value: 'PESSIMISTIC',
                          child: Text('Pessimistic Row-Lock (Default Safe)'),
                        ),
                        DropdownMenuItem(
                          value: 'OPTIMISTIC',
                          child: Text('Optimistic CAS (Version Check)'),
                        ),
                        DropdownMenuItem(
                          value: 'REDIS',
                          child: Text('Redis Distributed Lock'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _concurrencyStrategy = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Proceed to Pay Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: accountProvider.isLoading ? null : _onProceedToPay,
                  child: accountProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Authorize & Pay with UPI PIN'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
          ),
        ),
      ),
    );
  }
}
