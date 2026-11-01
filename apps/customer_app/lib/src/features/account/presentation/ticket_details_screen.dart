import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_notifier.dart';
import '../application/support_notifier.dart';

/// Screen D5 (Detail): Support Ticket Live Updates, Timeline & Chat Thread (§D5 & Master Spec).
class TicketDetailsScreen extends ConsumerStatefulWidget {
  const TicketDetailsScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends ConsumerState<TicketDetailsScreen> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportNotifierProvider.notifier).loadTicketDetails(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendReply(SupportTicketDto ticket) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    _replyController.clear();
    final profile = ref.read(authNotifierProvider).profile;

    final ok = await ref.read(supportNotifierProvider.notifier).replyToTicket(
      ticketId: ticket.id,
      userId: profile?.id,
      message: text,
      senderName: profile?.fullName ?? 'Customer',
    );

    if (ok) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportState = ref.watch(supportNotifierProvider);
    final ticket = supportState.selectedTicket != null &&
            (supportState.selectedTicket!.id == widget.ticketId ||
                supportState.selectedTicket!.ticketNumber == widget.ticketId)
        ? supportState.selectedTicket!
        : supportState.tickets.firstWhere(
            (t) => t.id == widget.ticketId || t.ticketNumber == widget.ticketId,
            orElse: () => SupportTicketDto(
              id: widget.ticketId,
              ticketNumber: 'TKT-${widget.ticketId}',
              serviceCategory: 'general',
              issueType: 'Support Inquiry',
              subject: 'Support Ticket',
              description: 'Loading ticket information...',
              status: TicketStatus.submitted,
              createdAt: DateTime.now(),
            ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFF0B100D),
      appBar: GVTopBar(title: ticket.ticketNumber),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  _buildHeaderCard(ticket),
                  const SizedBox(height: 16),
                  _buildStatusTimeline(ticket.status),
                  const SizedBox(height: 20),
                  const Text(
                    'Conversation History',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  ...ticket.messages.map((m) => _buildMessageBubble(m)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _buildReplyInput(ticket),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(SupportTicketDto ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141916),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2822),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticket.serviceCategory.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF00D065), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.createdAt),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ticket.subject,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            ticket.issueType,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          if (ticket.relatedEntityId != null && ticket.relatedEntityId!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2822),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Related Ref: ${ticket.relatedEntityId}',
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          const Text(
            'Initial Problem Description:',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(TicketStatus currentStatus) {
    final stages = [
      {'status': TicketStatus.submitted, 'label': 'Submitted'},
      {'status': TicketStatus.underReview, 'label': 'Review'},
      {'status': TicketStatus.inProgress, 'label': 'In Progress'},
      {'status': TicketStatus.resolved, 'label': 'Resolved'},
    ];

    final currentIndex = currentStatus.index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141916),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Lifecycle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: stages.asMap().entries.map((entry) {
              final idx = entry.key;
              final stage = entry.value;
              final isPassed = currentIndex >= idx;
              final isCurrent = currentIndex == idx;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPassed ? const Color(0xFF00D065) : const Color(0xFF1E2822),
                              border: Border.all(
                                color: isCurrent ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isPassed
                                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                                  : Text(
                                      '${idx + 1}',
                                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stage['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isPassed ? Colors.white : Colors.white38,
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (idx < stages.length - 1)
                      Container(
                        width: 14,
                        height: 2,
                        color: currentIndex > idx ? const Color(0xFF00D065) : Colors.white12,
                        margin: const EdgeInsets.only(bottom: 18),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportTicketMessageDto message) {
    final isCustomer = message.isCustomer;
    final formattedTime = DateFormat('hh:mm a • MMM dd').format(message.createdAt);

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCustomer ? const Color(0xFF0F3820) : const Color(0xFF1E2822),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isCustomer ? 12 : 2),
            bottomRight: Radius.circular(isCustomer ? 2 : 12),
          ),
          border: Border.all(
            color: isCustomer
                ? const Color(0xFF00D065).withValues(alpha: 0.3)
                : Colors.white12,
          ),
        ),
        child: Column(
          crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCustomer) ...[
                  const Icon(Icons.support_agent, color: Color(0xFF00D065), size: 14),
                  const SizedBox(width: 4),
                ],
                Text(
                  message.senderName,
                  style: TextStyle(
                    color: isCustomer ? const Color(0xFF00D065) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message.message,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 6),
            Text(
              formattedTime,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(SupportTicketDto ticket) {
    if (ticket.status == TicketStatus.closed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF141916),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: const Center(
          child: Text(
            'This support ticket is closed. For new inquiries, please open a new ticket.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      );
    }

    final isSubmitting = ref.watch(supportNotifierProvider).isSubmitting;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF141916),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF1E2822),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF00D065)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: isSubmitting ? null : () => _sendReply(ticket),
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00D065)),
                  )
                : const Icon(Icons.send, color: Color(0xFF00D065)),
          ),
        ],
      ),
    );
  }
}
