import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/active_trip_state.dart';

/// Screen RD18: Trip Completed & Itemized Financial Settlement Summary.
class TripCompletionScreen extends StatefulWidget {
  const TripCompletionScreen({
    super.key,
    required this.settlement,
  });

  final FareSettlementDto settlement;

  @override
  State<TripCompletionScreen> createState() => _TripCompletionScreenState();
}

class _TripCompletionScreenState extends State<TripCompletionScreen> {
  int _selectedRating = 5;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settlement;

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: GVSpacing.lg),
                    // Celebration Header
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: GVColors.deepGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: GVColors.brandGreen, width: 2),
                          boxShadow: GVShadows.glow,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: GVColors.brandGreen,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),
                    Text(
                      'Trip Completed & Settled!',
                      textAlign: TextAlign.center,
                      style: GVTypography.h1.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      'Payment verified and credited to your Go-Volts driver wallet ledger.',
                      textAlign: TextAlign.center,
                      style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: GVSpacing.xl),

                    // Total Earnings Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [GVColors.deepGreen, Color(0xFF133B26)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        boxShadow: GVShadows.elevated,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TOTAL EARNINGS CREDITED',
                            style: GVTypography.caption.copyWith(
                              color: GVColors.brandGreen,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₦${s.totalCreditNaira.toStringAsFixed(0)}',
                            style: GVTypography.h1.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Settled via ${s.paymentMethod}',
                            style: GVTypography.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Itemized Financial Ledger Breakdown
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2420),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(color: const Color(0xFF2A3630)),
                      ),
                      child: Column(
                        children: [
                          _buildLedgerRow(
                            label: 'Customer Gross Fare',
                            value: '₦${s.grossFareNaira.toStringAsFixed(0)}',
                            color: Colors.white,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Colors.white12, height: 1),
                          ),
                          _buildLedgerRow(
                            label: 'Platform Commission (20%)',
                            value: '- ₦${s.commissionNaira.toStringAsFixed(0)}',
                            color: Colors.redAccent,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Colors.white12, height: 1),
                          ),
                          _buildLedgerRow(
                            label: 'Rider Base Take-Home (80%)',
                            value: '₦${s.netEarningsNaira.toStringAsFixed(0)}',
                            color: GVColors.brandGreen,
                            isBold: true,
                          ),
                          if (s.tipKobo > 0) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: Colors.white12, height: 1),
                            ),
                            _buildLedgerRow(
                              label: 'Customer Tip (100% to you)',
                              value: '+ ₦${s.tipNaira.toStringAsFixed(0)}',
                              color: Colors.amber,
                              isBold: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Rate Customer Experience
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2420),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(color: const Color(0xFF2A3630)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Rate Customer Experience',
                            textAlign: TextAlign.center,
                            style: GVTypography.h3.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: GVSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: GVColors.deepGreen,
                                child: Icon(Icons.person, color: GVColors.brandGreen, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Amara Okafor',
                                style: GVTypography.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final star = index + 1;
                              return IconButton(
                                icon: Icon(
                                  star <= _selectedRating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                onPressed: () => setState(() => _selectedRating = star),
                              );
                            }),
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          TextField(
                            controller: _noteController,
                            maxLength: 200,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Leave a note for passenger (optional)',
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                              filled: true,
                              fillColor: const Color(0xFF141917),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF2A3630)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF2A3630)),
                              ),
                              counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Return CTA
              GVPrimaryButton(
                label: 'Return to Shift Dashboard',
                onPressed: () => context.go('/jobs'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerRow({
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GVTypography.bodyMedium.copyWith(
              color: Colors.white70,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GVTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
