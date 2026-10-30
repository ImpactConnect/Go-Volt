import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Screen A13/A14: Go-Volts Help & Support Center, FAQs & Ticket Filing.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _selectedCategory = 'All';
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  String? _generatedCaseId;

  final List<String> _categories = [
    'All',
    'Rides',
    'Delivery',
    'School Run',
    'Wallet',
  ];

  final List<Map<String, String>> _faqs = [
    {
      'category': 'School Run',
      'question': 'How does school-run custody transfer work?',
      'answer':
          'Drivers require a single-use 6-digit OTP code before releasing a child at the destination. Drivers are strictly prohibited from leaving children unattended.',
    },
    {
      'category': 'School Run',
      'question': 'Can I skip a scheduled commute without losing my trip entitlement?',
      'answer':
          'Yes! You can skip any scheduled trip up to 6 hours before the scheduled pickup time. Within 6 hours, fleet allocation is already locked and the entitlement is consumed per policy.',
    },
    {
      'category': 'Wallet',
      'question': 'How long does a wallet top-up take to reflect?',
      'answer':
          'Paystack top-ups reflect instantly upon successful card debit or virtual account transfer confirmation from your bank.',
    },
    {
      'category': 'Rides',
      'question': 'How is Go-Volts carbon offset calculated?',
      'answer':
          'We measure exact kilometers traveled by our 100% electric bikes and compute avoidance compared to conventional petrol ICE two-wheelers in Lagos (~120g CO₂/km).',
    },
    {
      'category': 'Delivery',
      'question': 'What items are restricted from parcel delivery?',
      'answer':
          'Illegal substances, hazardous chemicals, fragile glass without packing, and items exceeding 25kg are restricted on Go-Volts courier bikes.',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmitTicket() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your inquiry or issue.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isSubmitting = false;
      _generatedCaseId = 'CASE-SUP-${DateTime.now().millisecondsSinceEpoch % 100000}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _selectedCategory == 'All'
        ? _faqs
        : _faqs.where((f) => f['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(title: 'Help & Support Center'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Direct Assistance Hotline Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.headset_mic,
                          color: GVColors.brandGreen, size: 28),
                      const SizedBox(width: GVSpacing.xs),
                      Flexible(
                        child: Text(
                          '24/7 Operations Support',
                          style: GVTypography.h3.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Need immediate help with an active trip, delivery, or school-run handover in Lagos?',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GVColors.brandGreen,
                      foregroundColor: GVColors.deepGreen,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connecting to Go-Volts Lagos Operations Support hotline...'),
                          backgroundColor: GVColors.brandGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call +234 1 800 4686'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // FAQs Header & Category Filter
            Text('Frequently Asked Questions', style: GVTypography.h3),
            const SizedBox(height: GVSpacing.sm),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: GVColors.deepGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : GVColors.nearBlack,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // FAQ Accordion
            ...filteredFaqs.map(
              (faq) => Container(
                margin: const EdgeInsets.only(bottom: GVSpacing.xs),
                decoration: BoxDecoration(
                  color: GVColors.softBackground,
                  borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ExpansionTile(
                    title: Text(faq['question']!,
                        style: GVTypography.bodySmallMedium),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        child: Text(
                          faq['answer']!,
                          style: GVTypography.bodySmall
                              .copyWith(color: GVColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: GVSpacing.xl),

            // Submit Support Inquiry Form (A14)
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: GVColors.border),
                boxShadow: GVShadows.card,
              ),
              child: _generatedCaseId != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: GVColors.brandGreen, size: 48),
                        const SizedBox(height: GVSpacing.sm),
                        Text('Inquiry Logged Successfully',
                            style: GVTypography.h3),
                        const SizedBox(height: 4),
                        Text('Case Reference: $_generatedCaseId',
                            style: GVTypography.bodySmallMedium
                                .copyWith(color: GVColors.deepGreen)),
                        const SizedBox(height: GVSpacing.xs),
                        Text(
                          'Our customer success team will respond via email or SMS within 2 hours.',
                          textAlign: TextAlign.center,
                          style: GVTypography.caption
                              .copyWith(color: GVColors.textSecondary),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Send a Message to Support',
                            style: GVTypography.h3),
                        const SizedBox(height: GVSpacing.xs),
                        Text(
                          'Have a question not answered in our FAQs? Tell us what you need help with.',
                          style: GVTypography.caption
                              .copyWith(color: GVColors.textSecondary),
                        ),
                        const SizedBox(height: GVSpacing.sm),
                        TextField(
                          controller: _messageController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Enter your message or question...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: GVSpacing.md),
                        GVPrimaryButton(
                          label: 'Submit Support Ticket',
                          isLoading: _isSubmitting,
                          onPressed: _handleSubmitTicket,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
