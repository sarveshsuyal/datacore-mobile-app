import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';
import 'upi_pin_sheet.dart';
import 'success_receipt_screen.dart';

class ServicesHubView extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ServicesHubView({super.key, this.onBackToHome});

  @override
  State<ServicesHubView> createState() => _ServicesHubViewState();
}

class _ServicesHubViewState extends State<ServicesHubView> {
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openElectricityModal() {
    String selectedState = 'Uttarakhand';
    String selectedBoard = 'UPCL - Uttarakhand Power Corporation Ltd';
    final consumerController = TextEditingController(text: '015520938472');
    double fetchedAmount = 1450.00;
    bool isFetched = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('⚡', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text(
                          'Electricity Bill Payment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Select State', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedState,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Uttarakhand', child: Text('Uttarakhand (UPCL)')),
                        DropdownMenuItem(value: 'Maharashtra', child: Text('Maharashtra (MSEDCL, Tata Power)')),
                        DropdownMenuItem(value: 'Delhi', child: Text('Delhi (BSES Rajdhani, Tata Power)')),
                        DropdownMenuItem(value: 'Karnataka', child: Text('Karnataka (BESCOM Bangalore)')),
                        DropdownMenuItem(value: 'Uttar Pradesh', child: Text('Uttar Pradesh (UPPCL)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedState = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Consumer Number / CA Number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                TextField(
                  controller: consumerController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter CA number',
                    suffixText: 'Sample',
                    suffixStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isFetched)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setModalState(() => isFetched = true);
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: const Text('Fetch Bill Details'),
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bill Due Amount', style: TextStyle(color: Color(0xFF166534), fontSize: 12)),
                            Text(
                              '₹${fetchedAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Consumer Name: Rajesh Sharma • Due: 28th Nov', style: TextStyle(fontSize: 11, color: Color(0xFF166534))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _promptPinAndPay(
                          amount: fetchedAmount,
                          recipient: 'UPCL Power Discom',
                          description: 'Electricity Bill - CA $selectedBoard',
                        );
                      },
                      child: Text('Pay ₹${fetchedAmount.toStringAsFixed(2)} via UPI'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMobileRechargeModal() {
    final phoneController = TextEditingController(text: '9876543210');
    double selectedAmount = 299.00;
    String selectedOperator = 'Jio';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('📱', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text(
                          'Mobile Prepaid Recharge',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Mobile Number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixText: '+91 ',
                    prefixStyle: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    hintText: 'Enter 10-digit number',
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Popular Unlimited Plans', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPlanChip(299, '28D • 1.5GB/D', selectedAmount, (val) => setModalState(() => selectedAmount = val)),
                    const SizedBox(width: 8),
                    _buildPlanChip(666, '84D • 1.5GB/D', selectedAmount, (val) => setModalState(() => selectedAmount = val)),
                    const SizedBox(width: 8),
                    _buildPlanChip(749, '72D • 2GB/D', selectedAmount, (val) => setModalState(() => selectedAmount = val)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _promptPinAndPay(
                        amount: selectedAmount,
                        recipient: '$selectedOperator Prepaid (+91 ${phoneController.text})',
                        description: 'Mobile Recharge Plan',
                      );
                    },
                    child: Text('Recharge ₹${selectedAmount.toStringAsFixed(2)}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanChip(double amt, String desc, double selected, ValueChanged<double> onSelect) {
    final isSel = selected == amt;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(amt),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSel ? AppTheme.primary.withOpacity(0.08) : AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? AppTheme.primary : AppTheme.border,
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '₹${amt.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSel ? AppTheme.primary : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 9,
                  color: isSel ? AppTheme.primary : AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _promptPinAndPay({
    required double amount,
    required String recipient,
    required String description,
  }) {
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
          final accountProvider = context.read<AccountProvider>();
          final success = await accountProvider.executeTransfer(
            receiverIdentifier: 'bbps@datacore',
            amount: amount,
            description: description,
          );

          if (!mounted) return;
          if (success) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessScreen(
                  amount: amount,
                  recipientName: recipient,
                  recipientHandle: 'bbps.biller@datacore',
                  debitedAccount: accountProvider.primaryAccount?.accountNumber,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(accountProvider.errorMessage ?? 'Payment failed'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryPill(String id, String label) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      if (!title.toLowerCase().contains(q) && !subtitle.toLowerCase().contains(q)) {
        return const SizedBox.shrink();
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button & BBPS badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.onBackToHome != null) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                      onPressed: widget.onBackToHome,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                  ],
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recharge & Pay Bills',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      Text(
                        'Official Bharat BillPay (BBPS) Directory',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 12, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      'BBPS Assured',
                      style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Promotional Hero Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.purpleIndigoGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDark.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '0 CONVENIENCE FEES',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Instant Bill Settlement',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Assured double-entry ledger execution with zero duplicate deductions',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('🎁', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search billers (e.g. Jio, UPCL, Tata Play...)',
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          // Category Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryPill('ALL', 'All Services'),
                const SizedBox(width: 8),
                _buildCategoryPill('UTILITIES', '⚡ Utilities'),
                const SizedBox(width: 8),
                _buildCategoryPill('RECHARGE', '📱 Recharge'),
                const SizedBox(width: 8),
                _buildCategoryPill('FINANCE', '💳 Finance & EMI'),
                const SizedBox(width: 8),
                _buildCategoryPill('TRANSIT', '🚗 FASTag & Toll'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Due & Recent Bills Section
          if (_searchQuery.isEmpty && (_selectedCategory == 'ALL' || _selectedCategory == 'UTILITIES')) ...[
            const Text(
              'RECENT & DUE BILLS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(child: Text('⚡', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UPCL Electricity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        Text('CA: 015520938472 • Due Soon', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('₹1,450.00', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: _openElectricityModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Pay Bill', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Grid Sections
          if (_selectedCategory == 'ALL' || _selectedCategory == 'UTILITIES') ...[
            const Text(
              'ESSENTIAL UTILITIES',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                _buildServiceCard(
                  emoji: '⚡',
                  title: 'Electricity Bill',
                  subtitle: 'UPCL, MSEDCL, BSES',
                  bgColor: const Color(0xFFFEF3C7),
                  onTap: _openElectricityModal,
                ),
                _buildServiceCard(
                  emoji: '💧',
                  title: 'Water Bill',
                  subtitle: 'Jal Board & Municipal',
                  bgColor: const Color(0xFFE0F2FE),
                  onTap: () => _promptPinAndPay(amount: 450, recipient: 'Delhi Jal Board', description: 'Water Bill Payment'),
                ),
                _buildServiceCard(
                  emoji: '🔥',
                  title: 'Gas Cylinder',
                  subtitle: 'Indane, HP, Bharat Gas',
                  bgColor: const Color(0xFFFFEDD5),
                  onTap: () => _promptPinAndPay(amount: 899, recipient: 'Indane Gas LPG', description: 'LPG Refill Booking'),
                ),
                _buildServiceCard(
                  emoji: '🌐',
                  title: 'Broadband',
                  subtitle: 'JioFiber, Airtel, ACT',
                  bgColor: const Color(0xFFF3E8FF),
                  onTap: () => _promptPinAndPay(amount: 799, recipient: 'JioFiber Broadband', description: 'Broadband Monthly Plan'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          if (_selectedCategory == 'ALL' || _selectedCategory == 'RECHARGE') ...[
            const Text(
              'RECHARGE & ENTERTAINMENT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                _buildServiceCard(
                  emoji: '📱',
                  title: 'Mobile Recharge',
                  subtitle: 'Jio, Airtel, Vi, BSNL',
                  bgColor: const Color(0xFFDBEAFE),
                  onTap: _openMobileRechargeModal,
                ),
                _buildServiceCard(
                  emoji: '📺',
                  title: 'DTH Cable TV',
                  subtitle: 'Tata Play, Airtel DTH',
                  bgColor: const Color(0xFFE0E7FF),
                  onTap: () => _promptPinAndPay(amount: 350, recipient: 'Tata Play DTH', description: 'Monthly DTH Recharge'),
                ),
                _buildServiceCard(
                  emoji: '🚗',
                  title: 'FASTag Toll',
                  subtitle: 'NHAI, ICICI, SBI',
                  bgColor: const Color(0xFFCFFAFE),
                  onTap: () => _promptPinAndPay(amount: 500, recipient: 'ICICI FASTag', description: 'FASTag Wallet Topup'),
                ),
                _buildServiceCard(
                  emoji: '🎮',
                  title: 'Google Play',
                  subtitle: 'Recharge Codes',
                  bgColor: const Color(0xFFD1FAE5),
                  onTap: () => _promptPinAndPay(amount: 150, recipient: 'Google Play Recharge', description: 'Play Store Redeem Code'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          if (_selectedCategory == 'ALL' || _selectedCategory == 'FINANCE') ...[
            const Text(
              'FINANCIAL SERVICES & CREDIT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                _buildServiceCard(
                  emoji: '💳',
                  title: 'Credit Card Bill',
                  subtitle: 'HDFC, SBI, ICICI, Axis',
                  bgColor: const Color(0xFFFFE4E6),
                  onTap: () => _promptPinAndPay(amount: 3200, recipient: 'HDFC Credit Card', description: 'Card Outstanding Bill'),
                ),
                _buildServiceCard(
                  emoji: '🏦',
                  title: 'Loan EMI',
                  subtitle: 'Bajaj, Muthoot, Home Credit',
                  bgColor: const Color(0xFFEDE9FE),
                  onTap: () => _promptPinAndPay(amount: 2500, recipient: 'Bajaj Finance EMI', description: 'Personal Loan Installment'),
                ),
                _buildServiceCard(
                  emoji: '🛡️',
                  title: 'Insurance',
                  subtitle: 'LIC, HDFC Life, Star Health',
                  bgColor: const Color(0xFFCCFBF1),
                  onTap: () => _promptPinAndPay(amount: 1200, recipient: 'LIC Insurance', description: 'Policy Premium'),
                ),
                _buildServiceCard(
                  emoji: '🏛️',
                  title: 'Municipal Tax',
                  subtitle: 'Property & House Tax',
                  bgColor: const Color(0xFFECFCCB),
                  onTap: () => _promptPinAndPay(amount: 850, recipient: 'Municipal Tax Dept', description: 'Property Tax Payment'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
