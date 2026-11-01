import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/router/app_router.dart';
import '../application/support_notifier.dart';

/// Screen D3: Go-Volts Help Centre, Searchable FAQs & Support Shortcuts (§D3 & Master Spec).
class HelpCentreScreen extends ConsumerStatefulWidget {
  const HelpCentreScreen({super.key});

  @override
  ConsumerState<HelpCentreScreen> createState() => _HelpCentreScreenState();
}

class _HelpCentreScreenState extends ConsumerState<HelpCentreScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Rides',
    'Delivery',
    'Market Errand',
    'School Run',
    'Wallet',
    'Safety',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _dialSupport() async {
    final uri = Uri.parse('tel:07004686587');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Future<void> _emailSupport() async {
    final uri = Uri.parse('mailto:support@govolts.ng?subject=Inquiry%20via%20Customer%20App');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final supportState = ref.watch(supportNotifierProvider);
    final faqs = supportState.filteredFaqs;
    final openTicketsCount = supportState.tickets.where((t) => t.isOpen).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0B100D),
      appBar: const GVTopBar(title: 'Help & Support Centre'),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        ref.read(supportNotifierProvider.notifier).updateSearch(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search answers, topics, or services...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF00D065)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(supportNotifierProvider.notifier).updateSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFF141916),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF00D065)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Actions (Submit Ticket & My Tickets)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push(AppRoutes.createSupportTicket),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0F3820), Color(0xFF0B2415)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF00D065).withValues(alpha: 0.3)),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.add_circle_outline, color: Color(0xFF00D065), size: 24),
                                  SizedBox(height: 8),
                                  Text(
                                    'Create Ticket',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    'Get help with orders',
                                    style: TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push(AppRoutes.supportTicketsList),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141916),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.confirmation_number_outlined, color: Color(0xFF29B6F6), size: 24),
                                      if (openTicketsCount > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00D065),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$openTicketsCount Open',
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'My Tickets',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    '${supportState.tickets.length} submitted cases',
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Category Chips
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final cat = _categories[idx];
                          final isSelected = supportState.selectedCategory.toLowerCase() == cat.toLowerCase();
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) {
                              ref.read(supportNotifierProvider.notifier).filterCategory(cat);
                            },
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            selectedColor: const Color(0xFF00D065),
                            backgroundColor: const Color(0xFF141916),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF00D065) : Colors.white12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Frequently Asked Questions (${faqs.length})',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (faqs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, color: Colors.white38, size: 48),
                        SizedBox(height: 12),
                        Text('No matching questions found', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        SizedBox(height: 6),
                        Text(
                          'Try different keywords or submit a support ticket to our team.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final faq = faqs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: const Color(0xFF141916),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white10),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              key: ValueKey(faq.id),
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            iconColor: const Color(0xFF00D065),
                            collapsedIconColor: Colors.white54,
                            title: Text(
                              faq.question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                faq.category,
                                style: const TextStyle(color: Color(0xFF00D065), fontSize: 11),
                              ),
                            ),
                            children: [
                              Text(
                                faq.answer,
                                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${faq.helpfulCount} people found this helpful',
                                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.thumb_up_outlined, color: Colors.white54, size: 16),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Thank you for your feedback!')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    },
                    childCount: faqs.length,
                  ),
                ),
              ),

            // Contact Channels Footer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141D17),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF00D065).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Still Need Direct Assistance?',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Our customer care desk operates 24 hours a day, 7 days a week to support riders and senders across Lagos.',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _dialSupport,
                              icon: const Icon(Icons.phone, color: Color(0xFF00D065), size: 16),
                              label: const Text(
                                '0700-GOVOLTS',
                                style: TextStyle(color: Color(0xFF00D065), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF00D065)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _emailSupport,
                              icon: const Icon(Icons.email_outlined, color: Colors.white70, size: 16),
                              label: const Text(
                                'Email Us',
                                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          ],
        ),
      ),
    );
  }
}
