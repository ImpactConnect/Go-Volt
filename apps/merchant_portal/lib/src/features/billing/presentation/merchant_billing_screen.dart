import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:design_system/design_system.dart';
import '../../../core/widgets/merchant_kpi_card.dart';
import '../../../core/widgets/merchant_modal_dialog.dart';
import '../application/merchant_billing_notifier.dart';
import '../domain/billing_models.dart';

class MerchantBillingScreen extends ConsumerStatefulWidget {
  const MerchantBillingScreen({super.key});

  @override
  ConsumerState<MerchantBillingScreen> createState() =>
      _MerchantBillingScreenState();
}

class _MerchantBillingScreenState extends ConsumerState<MerchantBillingScreen> {
  final _searchController = TextEditingController();
  CorporateTransactionType? _typeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTopUpModal(BuildContext context) {
    final amounts = [
      {'label': '₦250,000', 'kobo': BigInt.from(25000000)},
      {'label': '₦500,000', 'kobo': BigInt.from(50000000)},
      {'label': '₦1,000,000', 'kobo': BigInt.from(100000000)},
      {'label': '₦2,500,000', 'kobo': BigInt.from(250000000)},
    ];
    BigInt selectedAmount = amounts[1]['kobo'] as BigInt;
    CorporatePaymentMethod selectedMethod =
        CorporatePaymentMethod.corporateWallet;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return MerchantModalDialog(
              title: 'Top-Up Corporate Wallet',
              maxWidth: 520,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select pre-funded top-up amount to ensure uninterrupted dispatch operations across all branches.',
                    style: TextStyle(
                      color: GVColors.neutral400,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SELECT AMOUNT',
                    style: TextStyle(
                      color: GVColors.neutral400,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: amounts.map((item) {
                      final isSelected = selectedAmount == item['kobo'];
                      return ChoiceChip(
                        label: Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? GVColors.neutral900
                                : GVColors.neutral100,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: GVColors.voltGreen,
                        backgroundColor: GVColors.neutral800,
                        onSelected: (val) {
                          if (val) {
                            setDialogState(() {
                              selectedAmount = item['kobo'] as BigInt;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'PAYMENT CHANNEL',
                    style: TextStyle(
                      color: GVColors.neutral400,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: GVColors.neutral800,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GVColors.neutral700),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CorporatePaymentMethod>(
                        value: selectedMethod,
                        isExpanded: true,
                        dropdownColor: GVColors.neutral800,
                        style: const TextStyle(color: GVColors.neutral100),
                        items: CorporatePaymentMethod.values.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedMethod = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GVColors.neutral800.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: GVColors.voltGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: GVColors.voltGreen,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Corporate funds are safeguarded in CBN-licensed escrow with auto-settlement reconciliation.',
                            style: TextStyle(
                              color: GVColors.neutral300,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: GVColors.neutral400),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ref
                        .read(merchantBillingNotifierProvider.notifier)
                        .topUpWallet(selectedAmount, selectedMethod);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GVColors.voltGreen,
                    foregroundColor: GVColors.neutral900,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Top-Up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSettleInvoiceDialog(BuildContext context, MerchantInvoice invoice) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return MerchantModalDialog(
          title: 'Settle Invoice ${invoice.invoiceNumber}',
          maxWidth: 480,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to settle this invoice using your corporate wallet?',
                style: TextStyle(
                  color: GVColors.neutral300,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GVColors.neutral800,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GVColors.neutral700),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Billing Period:', invoice.billingPeriod),
                    const SizedBox(height: 6),
                    _buildSummaryRow(
                      'Total Dispatches:',
                      '${invoice.totalDeliveries} orders',
                    ),
                    const SizedBox(height: 6),
                    _buildSummaryRow(
                      'Total Amount:',
                      invoice.formattedAmount,
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: GVColors.neutral400),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref
                    .read(merchantBillingNotifierProvider.notifier)
                    .settleInvoice(invoice.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GVColors.voltGreen,
                foregroundColor: GVColors.neutral900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pay with Wallet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: GVColors.neutral400, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? GVColors.voltGreen : GVColors.neutral100,
            fontSize: 12,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(merchantBillingNotifierProvider);
    final wallet = billingState.wallet;
    final invoices = billingState.invoices;

    // Filter transactions
    var filteredTx = billingState.transactions;
    if (_typeFilter != null) {
      filteredTx = filteredTx.where((tx) => tx.type == _typeFilter).toList();
    }
    if (_searchController.text.trim().isNotEmpty) {
      final q = _searchController.text.trim().toLowerCase();
      filteredTx = filteredTx
          .where((tx) =>
              tx.reference.toLowerCase().contains(q) ||
              tx.description.toLowerCase().contains(q) ||
              (tx.bookingTrackingNumber?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    final pendingInvoices =
        invoices.where((i) => i.status == InvoiceStatus.pending).toList();
    final pendingTotalKobo = pendingInvoices.fold<BigInt>(
      BigInt.zero,
      (prev, element) => prev + element.amountKobo,
    );
    final pendingFormatted = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 2,
    ).format(pendingTotalKobo.toInt() / 100.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner for alerts/success
          if (billingState.successMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: GVColors.voltGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GVColors.voltGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: GVColors.voltGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      billingState.successMessage!,
                      style: const TextStyle(
                        color: GVColors.voltGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: GVColors.voltGreen, size: 16),
                    onPressed: () => ref
                        .read(merchantBillingNotifierProvider.notifier)
                        .clearMessages(),
                  ),
                ],
              ),
            ),
          ],
          if (billingState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: GVColors.errorRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GVColors.errorRed),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: GVColors.errorRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      billingState.errorMessage!,
                      style: const TextStyle(
                        color: GVColors.errorRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: GVColors.errorRed, size: 16),
                    onPressed: () => ref
                        .read(merchantBillingNotifierProvider.notifier)
                        .clearMessages(),
                  ),
                ],
              ),
            ),
          ],

          // Title & Action Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final headerContent = [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corporate Billing & Invoices',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: GVColors.neutral100,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Corporate credit facility, automated bi-weekly invoices & transaction ledger',
                      style: TextStyle(
                        color: GVColors.neutral400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showTopUpModal(context),
                  icon: const Icon(Icons.add_card_rounded, size: 16),
                  label: const Text('Top-Up Corporate Wallet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GVColors.voltGreen,
                    foregroundColor: GVColors.neutral900,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ];

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerContent[0],
                        const SizedBox(height: 12),
                        headerContent[1],
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        headerContent[0],
                        headerContent[1],
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),

          // KPI Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width > 1000
                  ? 4
                  : width > 650
                      ? 2
                      : 1;

              final kpiCards = [
                MerchantKpiCard(
                  title: 'Corporate Wallet Balance',
                  value: wallet.formattedBalance,
                  subtitle: 'Available for immediate dispatch',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: GVColors.voltGreen,
                ),
                MerchantKpiCard(
                  title: 'Approved Credit Line',
                  value: wallet.formattedCreditLimit,
                  subtitle: 'Overdraft limit via Partner API',
                  icon: Icons.credit_score_rounded,
                  iconColor: GVColors.electricBlue,
                ),
                MerchantKpiCard(
                  title: 'Pending Invoices',
                  value: pendingFormatted,
                  subtitle: '${pendingInvoices.length} awaiting settlement',
                  icon: Icons.receipt_long_rounded,
                  iconColor: GVColors.warningOrange,
                ),
                MerchantKpiCard(
                  title: 'Auto-Debit Status',
                  value: wallet.autoDebitEnabled ? 'Active' : 'Disabled',
                  subtitle: 'Cycles on 1st & 15th monthly',
                  icon: Icons.autorenew_rounded,
                  iconColor: GVColors.deepPurple,
                ),
              ];

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: crossAxisCount == 4
                    ? 1.8
                    : crossAxisCount == 2
                        ? 2.2
                        : 2.8,
                children: kpiCards,
              );
            },
          ),
          const SizedBox(height: 28),

          // Invoices Table Card
          Container(
            decoration: BoxDecoration(
              color: GVColors.neutral900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GVColors.neutral800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Corporate Invoices',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GVColors.neutral100,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Automated bi-weekly billing statements with branch disaggregation',
                            style: TextStyle(
                              fontSize: 12,
                              color: GVColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GVColors.neutral800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${invoices.length} Statements',
                          style: const TextStyle(
                            fontSize: 11,
                            color: GVColors.neutral300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: GVColors.neutral800),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      GVColors.neutral800.withValues(alpha: 0.5),
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith(
                      (states) => GVColors.neutral900,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'INVOICE #',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'BILLING PERIOD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'DISPATCHES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'AMOUNT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'DUE DATE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'STATUS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'ACTION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                    ],
                    rows: invoices.map((inv) {
                      final isPending = inv.status == InvoiceStatus.pending;
                      final isPaid = inv.status == InvoiceStatus.paid;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              inv.invoiceNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: GVColors.voltGreen,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              inv.billingPeriod,
                              style: const TextStyle(
                                color: GVColors.neutral200,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${inv.totalDeliveries} orders',
                              style: const TextStyle(
                                color: GVColors.neutral300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              inv.formattedAmount,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: GVColors.neutral100,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              DateFormat('MMM dd, yyyy').format(inv.dueDate),
                              style: const TextStyle(
                                color: GVColors.neutral300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? GVColors.voltGreen.withValues(alpha: 0.15)
                                    : GVColors.warningOrange
                                        .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                inv.status.displayName,
                                style: TextStyle(
                                  color: isPaid
                                      ? GVColors.voltGreen
                                      : GVColors.warningOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            isPending
                                ? ElevatedButton(
                                    onPressed: () =>
                                        _showSettleInvoiceDialog(context, inv),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: GVColors.voltGreen,
                                      foregroundColor: GVColors.neutral900,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text(
                                      'Settle Now',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Downloading ${inv.invoiceNumber}.pdf...',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.download_rounded,
                                        size: 14),
                                    label: const Text('PDF'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: GVColors.neutral300,
                                      side: const BorderSide(
                                        color: GVColors.neutral700,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      textStyle: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Corporate Ledger / Transactions Card
          Container(
            decoration: BoxDecoration(
              color: GVColors.neutral900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GVColors.neutral800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 650;
                      final filterWidgets = [
                        // Search bar
                        SizedBox(
                          width: isNarrow ? double.infinity : 240,
                          height: 38,
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: GVColors.neutral100,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search reference or order...',
                              hintStyle: const TextStyle(
                                color: GVColors.neutral500,
                                fontSize: 12,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: GVColors.neutral400,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: GVColors.neutral800,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (isNarrow) const SizedBox(height: 8),
                        // Type Filter Dropdown
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: GVColors.neutral800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CorporateTransactionType?>(
                              value: _typeFilter,
                              dropdownColor: GVColors.neutral800,
                              style: const TextStyle(
                                color: GVColors.neutral200,
                                fontSize: 12,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Types'),
                                ),
                                ...CorporateTransactionType.values.map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.displayName),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() => _typeFilter = val);
                              },
                            ),
                          ),
                        ),
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Corporate Transaction Ledger',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: GVColors.neutral100,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isNarrow)
                            Column(children: filterWidgets)
                          else
                            Row(
                              children: [
                                filterWidgets[0],
                                const SizedBox(width: 12),
                                filterWidgets[2],
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(height: 1, color: GVColors.neutral800),
                if (filteredTx.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 40,
                            color: GVColors.neutral500,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No transactions match your search filter',
                            style: TextStyle(
                              color: GVColors.neutral400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        GVColors.neutral800.withValues(alpha: 0.5),
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith(
                        (states) => GVColors.neutral900,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'REFERENCE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: GVColors.neutral400,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'TIMESTAMP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: GVColors.neutral400,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'TYPE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: GVColors.neutral400,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'DESCRIPTION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: GVColors.neutral400,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'AMOUNT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: GVColors.neutral400,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'BALANCE AFTER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: GVColors.neutral400,
                            ),
                          ),
                        ),
                      ],
                      rows: filteredTx.map((tx) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                tx.reference,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: GVColors.neutral200,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat('MMM dd, HH:mm')
                                    .format(tx.timestamp),
                                style: const TextStyle(
                                  color: GVColors.neutral400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tx.isCredit
                                      ? GVColors.voltGreen
                                          .withValues(alpha: 0.1)
                                      : GVColors.neutral800,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tx.type.displayName,
                                  style: TextStyle(
                                    color: tx.isCredit
                                        ? GVColors.voltGreen
                                        : GVColors.neutral300,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                tx.description,
                                style: const TextStyle(
                                  color: GVColors.neutral300,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                tx.formattedAmount,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tx.isCredit
                                      ? GVColors.voltGreen
                                      : GVColors.neutral200,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                tx.formattedBalanceAfter,
                                style: const TextStyle(
                                  color: GVColors.neutral400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
