import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_router.dart';
import '../application/support_notifier.dart';

/// Screen D5 (List): Support Ticket History & Status Hub (§D5 & Master Spec).
class SupportTicketsListScreen extends ConsumerStatefulWidget {
  const SupportTicketsListScreen({super.key});

  @override
  ConsumerState<SupportTicketsListScreen> createState() => _SupportTicketsListScreenState();
}

class _SupportTicketsListScreenState extends ConsumerState<SupportTicketsListScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Open', 'Resolved', 'Closed'];

  @override
  Widget build(BuildContext context) {
    final supportState = ref.watch(supportNotifierProvider);
    final allTickets = supportState.tickets;

    final filteredTickets = allTickets.where((t) {
      if (_selectedFilter == 'Open') {
        return t.status == TicketStatus.submitted ||
            t.status == TicketStatus.underReview ||
            t.status == TicketStatus.inProgress;
      }
      if (_selectedFilter == 'Resolved') {
        return t.status == TicketStatus.resolved;
      }
      if (_selectedFilter == 'Closed') {
        return t.status == TicketStatus.closed;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B100D),
      appBar: const GVTopBar(title: 'Support Tickets'),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedFilter = filter),
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
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: filteredTickets.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: const Color(0xFF00D065),
                      onRefresh: () async {
                        await ref.read(supportNotifierProvider.notifier).loadTickets();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = filteredTickets[index];
                          return _buildTicketCard(ticket);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createSupportTicket),
        backgroundColor: const Color(0xFF00D065),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'New Ticket',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF141916),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.confirmation_number_outlined, color: Colors.white38, size: 54),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedFilter == 'All' ? 'No Support Tickets Found' : 'No $_selectedFilter Tickets',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you need assistance regarding any of your rides, parcels, or commutes, our team is ready to help.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.createSupportTicket),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('Open New Ticket', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D065),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicketDto ticket) {
    Color statusColor;
    String statusText;
    switch (ticket.status) {
      case TicketStatus.submitted:
        statusColor = const Color(0xFF29B6F6);
        statusText = 'SUBMITTED';
        break;
      case TicketStatus.underReview:
        statusColor = const Color(0xFFFFB300);
        statusText = 'UNDER REVIEW';
        break;
      case TicketStatus.inProgress:
        statusColor = const Color(0xFFFF9800);
        statusText = 'IN PROGRESS';
        break;
      case TicketStatus.resolved:
        statusColor = const Color(0xFF00D065);
        statusText = 'RESOLVED';
        break;
      case TicketStatus.closed:
        statusColor = Colors.white38;
        statusText = 'CLOSED';
        break;
    }

    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141916),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: () => context.push('/support/tickets/${ticket.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        ticket.ticketNumber,
                        style: const TextStyle(
                          color: Color(0xFF00D065),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2822),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.serviceCategory.toUpperCase(),
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ticket.subject,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.forum_outlined, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${ticket.messages.length} message${ticket.messages.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
