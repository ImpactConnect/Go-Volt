import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/admin_auth_notifier.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/support_safety_notifier.dart';
import '../../domain/support_safety_models.dart';

class SupportTicketChatModal extends ConsumerStatefulWidget {
  const SupportTicketChatModal({
    super.key,
    required this.ticket,
  });

  final SupportTicketModel ticket;

  @override
  ConsumerState<SupportTicketChatModal> createState() => _SupportTicketChatModalState();
}

class _SupportTicketChatModalState extends ConsumerState<SupportTicketChatModal> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  final _dateFormat = DateFormat('MMM dd, HH:mm');

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(adminAuthNotifierProvider);
    final state = ref.watch(supportSafetyNotifierProvider);
    final currentTicket = state.tickets.firstWhere(
      (t) => t.id == widget.ticket.id,
      orElse: () => widget.ticket,
    );
    final messages = currentTicket.messages;

    return AdminModalDialog(
      maxWidth: 760,
      title: 'Ticket: ${currentTicket.ticketRef}',
      icon: Icons.chat_outlined,
      primaryActionLabel: 'Close',
      onPrimaryAction: () => Navigator.pop(context),
      child: SizedBox(
        width: 720,
        height: 580,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ticket Header Information Bar
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF14241B),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentTicket.subject,
                          style: GVTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C120F),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButton<TicketStatus>(
                          value: currentTicket.status,
                          underline: const SizedBox(),
                          dropdownColor: const Color(0xFF14241B),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              ref
                                  .read(supportSafetyNotifierProvider.notifier)
                                  .updateTicketStatus(currentTicket.id, newStatus);
                            }
                          },
                          items: TicketStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status.name.toUpperCase(),
                                style: TextStyle(
                                  color: status == TicketStatus.resolved
                                      ? GVColors.brandGreen
                                      : (status == TicketStatus.inProgress
                                          ? Colors.amber
                                          : Colors.white),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Customer: ${currentTicket.customerName} • Rider: ${currentTicket.riderName}',
                        style: GVTypography.caption.copyWith(color: Colors.white70),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCategoryBadge(currentTicket.category),
                          const SizedBox(width: 6),
                          _buildPriorityBadge(currentTicket.priority),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Chat Messages List
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1410),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF1F2B25)),
                ),
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages logged on this ticket yet.',
                          style: GVTypography.bodyMedium.copyWith(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isAgent = !msg.isCustomer;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment:
                                  isAgent ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isAgent) ...[
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.white12,
                                    child: Icon(Icons.person, size: 14, color: Colors.white70),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 480),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isAgent ? const Color(0xFF1B3828) : const Color(0xFF18221D),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isAgent
                                            ? GVColors.brandGreen.withValues(alpha: 0.4)
                                            : Colors.white12,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isAgent
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 2,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              msg.senderName,
                                              style: TextStyle(
                                                color: isAgent ? GVColors.brandGreen : Colors.white70,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              _dateFormat.format(msg.createdAt),
                                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          msg.message,
                                          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isAgent) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: GVColors.brandGreen.withValues(alpha: 0.2),
                                    child: const Icon(Icons.support_agent, size: 14, color: GVColors.brandGreen),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // Agent Reply Input Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type official response to customer...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF14241B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF263C2E)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) async {
                      if (_replyController.text.trim().isEmpty) return;
                      final text = _replyController.text.trim();
                      _replyController.clear();
                      await ref.read(supportSafetyNotifierProvider.notifier).sendAgentReply(
                            ticketId: currentTicket.id,
                            message: text,
                            agentName: '${authState.userName} (Support)',
                            agentId: authState.userId,
                          );
                      _scrollToBottom();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_replyController.text.trim().isEmpty) return;
                    final text = _replyController.text.trim();
                    _replyController.clear();
                    await ref.read(supportSafetyNotifierProvider.notifier).sendAgentReply(
                          ticketId: currentTicket.id,
                          message: text,
                          agentName: '${authState.userName} (Support)',
                          agentId: authState.userId,
                        );
                    _scrollToBottom();
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Reply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GVColors.brandGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color color;
    switch (priority) {
      case TicketPriority.urgent:
        color = Colors.redAccent;
        break;
      case TicketPriority.high:
        color = Colors.orangeAccent;
        break;
      case TicketPriority.normal:
        color = Colors.blueAccent;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
