import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/success_receipt_screen.dart';

class HistoryScreen extends StatefulWidget {
  final bool isEmbedded;

  const HistoryScreen({super.key, this.isEmbedded = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'ALL'; // ALL, DEBIT, CREDIT
  String _search = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AccountProvider>().fetchTransactions();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openTransactionDetails(TransactionModel tx, bool isDebit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          amount: double.tryParse(tx.amount) ?? 0.0,
          recipientName: isDebit
              ? (tx.receiverEmail.isNotEmpty ? tx.receiverEmail : tx.receiverAccountNumber)
              : (tx.senderEmail.isNotEmpty ? tx.senderEmail : tx.senderAccountNumber),
          recipientHandle: isDebit ? tx.receiverAccountNumber : tx.senderAccountNumber,
          utr: tx.idempotencyKey != null && tx.idempotencyKey!.length >= 12
              ? tx.idempotencyKey!.replaceAll('-', '').substring(0, 12)
              : (tx.id.length >= 12 ? tx.id.replaceAll('-', '').substring(0, 12) : 'DC${tx.id}'),
          transactionId: tx.id,
          debitedAccount: tx.senderAccountNumber,
          latencyMs: tx.latencyMs,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final account = accountProvider.primaryAccount;
    final allTransactions = accountProvider.recentTransactions;

    final filteredList = allTransactions.where((tx) {
      final isDebit = tx.senderAccountNumber == account?.accountNumber;
      if (_filter == 'DEBIT' && !isDebit) return false;
      if (_filter == 'CREDIT' && isDebit) return false;

      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matchDesc = tx.description.toLowerCase().contains(q);
        final matchAmt = tx.amount.contains(q);
        final matchRec = tx.receiverAccountNumber.toLowerCase().contains(q) || tx.receiverEmail.toLowerCase().contains(q);
        final matchSen = tx.senderAccountNumber.toLowerCase().contains(q) || tx.senderEmail.toLowerCase().contains(q);
        return matchDesc || matchAmt || matchRec || matchSen;
      }
      return true;
    }).toList();

    final content = RefreshIndicator(
      onRefresh: () => accountProvider.fetchTransactions(),
      color: AppTheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Embedded screen header title
          if (widget.isEmbedded)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),

          // Search and Filters Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _search = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by name, UPI ID or amount...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.textMuted),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'ALL'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Money Sent', 'DEBIT'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Money Received', 'CREDIT'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Transactions Header Count & Ledger Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredList.length} Transactions',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.shield_rounded, size: 12, color: AppTheme.primary),
                          SizedBox(width: 4),
                          Text(
                            'Double-Entry Verified',
                            style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Empty state or Transaction Items
          if (filteredList.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 44, color: AppTheme.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'No matching transactions found.',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = filteredList[index];
                    final isDebit = tx.senderAccountNumber == account?.accountNumber;
                    final displayAmount = '${isDebit ? '-' : '+'}₹${tx.amount}';

                    // Format created_at date nicely
                    String formattedDate = tx.createdAt;
                    try {
                      final dt = DateTime.parse(tx.createdAt);
                      formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
                    } catch (_) {}

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openTransactionDetails(tx, isDebit),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.015),
                                  blurRadius: 6,
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
                                    color: isDebit ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    isDebit ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
                                    color: isDebit ? AppTheme.error : AppTheme.success,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isDebit
                                            ? 'Paid to ${tx.receiverEmail.isNotEmpty ? tx.receiverEmail : tx.receiverAccountNumber}'
                                            : 'Received from ${tx.senderEmail.isNotEmpty ? tx.senderEmail : tx.senderAccountNumber}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        tx.description.isNotEmpty ? tx.description : 'DataCore Transfer',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      displayAmount,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDebit ? AppTheme.error : AppTheme.success,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: tx.status == 'COMPLETED' ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        tx.status,
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: tx.status == 'COMPLETED' ? AppTheme.success : AppTheme.warning,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: filteredList.length,
                ),
              ),
            ),

          // Generous bottom spacer so items are never obscured by BottomNavigationBar
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(child: content),
    );
  }
}
