import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/admin_auth_notifier.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../../../core/widgets/admin_modal_dialog.dart';
import '../application/support_safety_notifier.dart';
import '../domain/support_safety_models.dart';
import 'widgets/faq_editor_modal.dart';
import 'widgets/support_ticket_chat_modal.dart';

class SupportSafetyScreen extends ConsumerStatefulWidget {
  const SupportSafetyScreen({super.key});

  @override
  ConsumerState<SupportSafetyScreen> createState() => _SupportSafetyScreenState();
}

class _SupportSafetyScreenState extends ConsumerState<SupportSafetyScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  void _showAddNoteModal(BuildContext context, SafetyIncidentModel incident) {
    final noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AdminModalDialog(
          title: 'Add Safety Investigation Log',
          icon: Icons.note_add_outlined,
          primaryActionLabel: 'Append Note',
          accentColor: Colors.redAccent,
          onPrimaryAction: () {
            if (noteController.text.trim().isEmpty) return;
            ref.read(supportSafetyNotifierProvider.notifier).addSafetyInvestigationNote(
                  incident.id,
                  noteController.text.trim(),
                );
            Navigator.pop(dialogCtx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Investigation note recorded.')),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Incident: ${incident.incidentRef} (${incident.incidentType})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Investigation Action / Authority Liaison Update',
                  filled: true,
                  fillColor: Color(0xFF14241B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthNotifierProvider);
    final canAccessSafety = authState.role.canAccessSafety;
    final supportState = ref.watch(supportSafetyNotifierProvider);
    final notifier = ref.read(supportSafetyNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support Helpdesk & Safety Operations',
                style: GVTypography.h2.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'SLA support queue, FAQ Knowledge Base CMS, and restricted safeguarding incident files (§5.1, §D1-D5)',
                style: GVTypography.bodySmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // Feedback Action Message Alert Banner
          if (supportState.actionMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              margin: const EdgeInsets.only(bottom: GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF143021),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GVColors.brandGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: GVColors.brandGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      supportState.actionMessage!,
                      style: GVTypography.bodySmall.copyWith(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                    onPressed: () => notifier.clearActionMessage(),
                  ),
                ],
              ),
            ),
          ],

          // KPIs
          Row(
            children: [
              Expanded(
                child: AdminKpiCard(
                  title: 'Open Support Tickets',
                  value: '${supportState.openTicketsCount}',
                  subtitle: 'SLA response target: <15 mins',
                  icon: Icons.support_agent_outlined,
                  accentColor: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Published FAQs',
                  value: '${supportState.totalFaqsCount} Articles',
                  subtitle: 'Synchronized with Customer App',
                  icon: Icons.menu_book_outlined,
                  accentColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Active Safety Investigations',
                  value: canAccessSafety ? '${supportState.activeIncidentsCount}' : 'Restricted',
                  subtitle: 'Safeguarding & crash response',
                  icon: Icons.shield_outlined,
                  accentColor: Colors.redAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Desk Status',
                  value: supportState.activeIncidentsCount > 0 ? 'Active Escalation' : 'Nominal',
                  subtitle: 'Monitoring telematics 24/7',
                  icon: Icons.security_outlined,
                  accentColor: supportState.activeIncidentsCount > 0 ? Colors.redAccent : Colors.purpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Tab Switcher (0 = Tickets, 1 = Safety Incidents, 2 = FAQ Knowledge Base)
          Row(
            children: [
              ChoiceChip(
                label: Text('Customer Support Queue (${supportState.tickets.length})'),
                selected: supportState.selectedTab == 0,
                selectedColor: GVColors.brandGreen.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: supportState.selectedTab == 0 ? GVColors.brandGreen : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: const Color(0xFF14241B),
                onSelected: (val) {
                  if (val) notifier.setTab(0);
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 14, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Text(
                      'Confidential Safety Incidents (${canAccessSafety ? supportState.incidents.length : 'Gated'})',
                    ),
                  ],
                ),
                selected: supportState.selectedTab == 1,
                selectedColor: Colors.redAccent.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: supportState.selectedTab == 1 ? Colors.redAccent : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: const Color(0xFF14241B),
                onSelected: (val) {
                  if (val) notifier.setTab(1);
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.library_books, size: 14, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Text('FAQ Knowledge Base CMS (${supportState.faqs.length})'),
                  ],
                ),
                selected: supportState.selectedTab == 2,
                selectedColor: Colors.blueAccent.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: supportState.selectedTab == 2 ? Colors.blueAccent : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: const Color(0xFF14241B),
                onSelected: (val) {
                  if (val) notifier.setTab(2);
                },
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.md),

          // Content Based on Selected Tab
          if (supportState.selectedTab == 0) ...[
            // Support Tickets Table
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF101713),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1F2B25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Customer & Rider Inquiries Queue',
                          style: GVTypography.h3.copyWith(color: Colors.white)),
                      Text('${supportState.tickets.length} tickets recorded',
                          style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Service Category & Status Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text('Category: ',
                            style: TextStyle(
                                color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                        _buildTicketFilterChip(
                          label: 'All',
                          isSelected: supportState.ticketCategoryFilter == null,
                          onSelected: () => notifier.filterTicketsByCategory(null),
                        ),
                        const SizedBox(width: 6),
                        _buildTicketFilterChip(
                          label: 'Rides',
                          isSelected: supportState.ticketCategoryFilter == 'rides',
                          onSelected: () => notifier.filterTicketsByCategory('rides'),
                        ),
                        const SizedBox(width: 6),
                        _buildTicketFilterChip(
                          label: 'Market Errand',
                          isSelected: supportState.ticketCategoryFilter == 'market_errand',
                          onSelected: () => notifier.filterTicketsByCategory('market_errand'),
                        ),
                        const SizedBox(width: 6),
                        _buildTicketFilterChip(
                          label: 'Scheduled Commute',
                          isSelected: supportState.ticketCategoryFilter == 'scheduled',
                          onSelected: () => notifier.filterTicketsByCategory('scheduled'),
                        ),
                        const SizedBox(width: 6),
                        _buildTicketFilterChip(
                          label: 'Wallet',
                          isSelected: supportState.ticketCategoryFilter == 'wallet',
                          onSelected: () => notifier.filterTicketsByCategory('wallet'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  if (supportState.filteredTickets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No customer or rider inquiries currently open.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.6),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(0.9),
                      4: FlexColumnWidth(2.0),
                      5: FlexColumnWidth(1.0),
                      6: FlexColumnWidth(1.8),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF1F2B25))),
                        ),
                        children: [
                          _headerCell('TICKET REF'),
                          _headerCell('PARTIES'),
                          _headerCell('CATEGORY'),
                          _headerCell('PRIORITY'),
                          _headerCell('SUBJECT & SUMMARY'),
                          _headerCell('STATUS'),
                          _headerCell('ACTION'),
                        ],
                      ),
                      ...supportState.filteredTickets.map((ticket) {
                        Color priorityColor = Colors.white70;
                        if (ticket.priority == TicketPriority.urgent) {
                          priorityColor = Colors.redAccent;
                        }
                        if (ticket.priority == TicketPriority.high) priorityColor = Colors.amber;

                        final isResolved = ticket.status == TicketStatus.resolved;

                        return TableRow(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF18221D))),
                          ),
                          children: [
                            _dataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ticket.ticketRef,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  Text(_dateFormat.format(ticket.createdAt),
                                      style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                            ),
                            _dataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('C: ${ticket.customerName}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                                  Text('R: ${ticket.riderName}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ),
                            _dataCell(Text(ticket.category,
                                style: const TextStyle(color: Colors.white70, fontSize: 11))),
                            _dataCell(
                              Text(
                                ticket.priority.name.toUpperCase(),
                                style: TextStyle(
                                    color: priorityColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ),
                            _dataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ticket.subject,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11)),
                                  Text(ticket.description,
                                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            _dataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isResolved
                                      ? GVColors.brandGreen.withValues(alpha: 0.15)
                                      : Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ticket.status.name.toUpperCase(),
                                  style: TextStyle(
                                    color: isResolved ? GVColors.brandGreen : Colors.amber,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            _dataCell(
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  // Open 2-Way Chat Modal Button
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (ctx) => SupportTicketChatModal(ticket: ticket),
                                      );
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline, size: 12),
                                    label: Text(
                                      'Chat (${ticket.messages.length})',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: GVColors.brandGreen,
                                      side: const BorderSide(color: Color(0xFF263C2E)),
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      minimumSize: const Size(60, 26),
                                    ),
                                  ),
                                  if (!isResolved)
                                    ElevatedButton(
                                      key: Key('resolve_ticket_${ticket.id}'),
                                      onPressed: () {
                                        ref
                                            .read(supportSafetyNotifierProvider.notifier)
                                            .resolveTicket(ticket.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text('Ticket ${ticket.ticketRef} resolved.')),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: GVColors.brandGreen,
                                        foregroundColor: Colors.black,
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: const Size(60, 26),
                                      ),
                                      child: const Text('Resolve', style: TextStyle(fontSize: 10)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (supportState.selectedTab == 1) ...[
            // Safety Incidents Tab (Confidential)
            if (!canAccessSafety) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.xl),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1215),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.gavel, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'RESTRICTED CONFIDENTIAL SAFETY ARCHIVE',
                      style: GVTypography.h3.copyWith(color: Colors.redAccent, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Access to safeguarding escalations, collision reports, and police liaison records is strictly restricted to Safety Officers and System Administrators in compliance with Nigerian Data Protection and child safeguarding regulations (§5.1).',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Your Current Role: ${authState.role.label} (Access Prohibited)',
                        style: const TextStyle(
                            color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Column(
                children: supportState.incidents.map((incident) {
                  final isResolved = incident.status == SafetyIncidentStatus.resolved;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A17),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: incident.severity == SafetyIncidentSeverity.critical
                            ? Colors.redAccent
                            : Colors.amber,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.redAccent),
                                  ),
                                  child: Text(
                                    incident.severity.name.toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  incident.incidentRef,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Booking: ${incident.bookingRef}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isResolved
                                    ? GVColors.brandGreen.withValues(alpha: 0.2)
                                    : Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                incident.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: isResolved ? GVColors.brandGreen : Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          incident.incidentType,
                          style: GVTypography.h3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Parties: ${incident.partiesInvolved}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location Narrative: ${incident.locationNarrative}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          incident.description,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        if (incident.lawEnforcementReportRef != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.local_police, color: Colors.blueAccent, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Police FIR Reference: ${incident.lawEnforcementReportRef}',
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                        const Divider(color: Color(0xFF1F2B25), height: 24),
                        Text(
                          'Investigation Log Audit Trail:',
                          style: GVTypography.caption
                              .copyWith(color: Colors.white38, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ...incident.investigationNotes.map((note) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: GVColors.brandGreen)),
                                Expanded(
                                    child: Text(note,
                                        style: const TextStyle(
                                            color: Colors.white70, fontSize: 12))),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              key: Key('add_note_btn_${incident.id}'),
                              onPressed: () => _showAddNoteModal(context, incident),
                              icon: const Icon(Icons.add_comment, size: 16),
                              label: const Text('Add Investigation Log'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF274332)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (!isResolved)
                              ElevatedButton.icon(
                                key: Key('resolve_incident_btn_${incident.id}'),
                                onPressed: () {
                                  ref
                                      .read(supportSafetyNotifierProvider.notifier)
                                      .resolveSafetyIncident(incident.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Safety case ${incident.incidentRef} marked resolved.')),
                                  );
                                },
                                icon: const Icon(Icons.verified, size: 16),
                                label: const Text('Mark Case Resolved'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GVColors.brandGreen,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ] else if (supportState.selectedTab == 2) ...[
            // Tab 2: FAQ Knowledge Base CMS
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF101713),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1F2B25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Help Centre Knowledge Base (CMS)',
                              style: GVTypography.h3.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          const Text(
                            'Manage customer FAQ accordions, resolutions, and service category guides (§D3)',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => const FaqEditorModal(),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 16),
                        label: const Text('Publish New FAQ Article'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GVColors.brandGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Filter Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      'All',
                      'Rides',
                      'Delivery',
                      'Market Errand',
                      'School Run',
                      'Wallet',
                      'Safety',
                    ].map((cat) {
                      final isSelected =
                          (supportState.faqCategoryFilter == null && cat == 'All') ||
                              supportState.faqCategoryFilter == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: Colors.blueAccent,
                        backgroundColor: const Color(0xFF14241B),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) notifier.filterFaqsByCategory(cat == 'All' ? null : cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // FAQ Cards List
                  if (supportState.filteredFaqs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: const Text('No FAQ articles in this category.',
                          style: TextStyle(color: Colors.white38)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: supportState.filteredFaqs.length,
                      itemBuilder: (context, index) {
                        final faq = supportState.filteredFaqs[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(GVSpacing.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFF142018),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF263C2E)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          faq.category.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${faq.helpfulCount} Customer Upvotes',
                                        style: const TextStyle(
                                            color: GVColors.brandGreen, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 16, color: Colors.white70),
                                        onPressed: () {
                                          showDialog<void>(
                                            context: context,
                                            builder: (ctx) =>
                                                FaqEditorModal(existingFaq: faq),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 16, color: Colors.redAccent),
                                        onPressed: () {
                                          notifier.deleteFaq(faq.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                faq.question,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                faq.answer,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildTicketFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: GVColors.brandGreen,
      backgroundColor: const Color(0xFF14241B),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (_) => onSelected(),
    );
  }

  Widget _headerCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        title,
        style: GVTypography.caption.copyWith(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: child,
    );
  }
}
