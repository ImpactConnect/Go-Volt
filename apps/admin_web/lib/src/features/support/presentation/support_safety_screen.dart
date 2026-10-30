import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/admin_auth_notifier.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../../../core/widgets/admin_modal_dialog.dart';
import '../application/support_safety_notifier.dart';
import '../domain/support_safety_models.dart';

class SupportSafetyScreen extends ConsumerStatefulWidget {
  const SupportSafetyScreen({super.key});

  @override
  ConsumerState<SupportSafetyScreen> createState() =>
      _SupportSafetyScreenState();
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

    return SingleChildScrollView(
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
                'SLA support queue and restricted safeguarding incident files (§5.1)',
                style: GVTypography.bodySmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

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
                  title: 'Active Safety Investigations',
                  value: canAccessSafety ? '${supportState.activeIncidentsCount}' : 'Restricted',
                  subtitle: 'Safeguarding & crash response',
                  icon: Icons.shield_outlined,
                  accentColor: Colors.redAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              const Expanded(
                child: AdminKpiCard(
                  title: 'Average Resolution Time',
                  value: '22 mins',
                  subtitle: 'Within Tier-1 SLA parameters',
                  icon: Icons.timer_outlined,
                  accentColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              const Expanded(
                child: AdminKpiCard(
                  title: 'Active Safety Personnel',
                  value: '4 Officers On-Duty',
                  subtitle: 'Monitoring geofences 24/7',
                  icon: Icons.security_outlined,
                  accentColor: Colors.purpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Tab Switcher
          Row(
            children: [
              ChoiceChip(
                label: const Text('Customer Support Queue (SLA)'),
                selected: supportState.selectedTab == 0,
                selectedColor: GVColors.brandGreen.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: supportState.selectedTab == 0 ? GVColors.brandGreen : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: const Color(0xFF14241B),
                onSelected: (val) {
                  if (val) ref.read(supportSafetyNotifierProvider.notifier).setTab(0);
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
                  if (val) ref.read(supportSafetyNotifierProvider.notifier).setTab(1);
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
                      Text('Customer & Rider Inquiries Queue', style: GVTypography.h3.copyWith(color: Colors.white)),
                      Text('${supportState.tickets.length} tickets recorded', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.md),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.6),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(1.0),
                      4: FlexColumnWidth(2.0),
                      5: FlexColumnWidth(1.2),
                      6: FlexColumnWidth(1.2),
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
                      ...supportState.tickets.map((ticket) {
                        Color priorityColor = Colors.white70;
                        if (ticket.priority == TicketPriority.urgent) priorityColor = Colors.redAccent;
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
                                  Text(ticket.ticketRef, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(_dateFormat.format(ticket.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                            ),
                            _dataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('C: ${ticket.customerName}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                  Text('R: ${ticket.riderName}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ),
                            _dataCell(Text(ticket.category, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                            _dataCell(
                              Text(
                                ticket.priority.name.toUpperCase(),
                                style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                            _dataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ticket.subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                  Text(ticket.description, style: const TextStyle(color: Colors.white60, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                              !isResolved
                                  ? ElevatedButton(
                                      key: Key('resolve_ticket_${ticket.id}'),
                                      onPressed: () {
                                        ref.read(supportSafetyNotifierProvider.notifier).resolveTicket(ticket.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Ticket ${ticket.ticketRef} resolved.')),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: GVColors.brandGreen,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: const Size(60, 26),
                                      ),
                                      child: const Text('Resolve', style: TextStyle(fontSize: 10)),
                                    )
                                  : const Text('—', style: TextStyle(color: Colors.white38)),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
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
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
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
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  incident.incidentRef,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
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
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                        const Divider(color: Color(0xFF1F2B25), height: 24),
                        Text(
                          'Investigation Log Audit Trail:',
                          style: GVTypography.caption.copyWith(color: Colors.white38, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ...incident.investigationNotes.map((note) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: GVColors.brandGreen)),
                                Expanded(child: Text(note, style: const TextStyle(color: Colors.white70, fontSize: 12))),
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
                                  ref.read(supportSafetyNotifierProvider.notifier).resolveSafetyIncident(incident.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Safety case ${incident.incidentRef} marked resolved.')),
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
          ],
        ],
      ),
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
