import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/admin_modal_dialog.dart';
import '../application/audit_notifier.dart';
import '../domain/audit_models.dart';

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final _searchController = TextEditingController();

  void _showDiffModal(BuildContext context, AuditLogEntry log) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AdminModalDialog(
          title: 'Audit Record State Transition',
          icon: Icons.difference_outlined,
          primaryActionLabel: 'Close',
          onPrimaryAction: () => Navigator.pop(dialogCtx),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${log.action} · ${log.entityType} [${log.entityId}]',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Actor: ${log.actorName} (${log.actorRole}) · IP: ${log.ipAddress}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 6),
              SelectableText('Chained Hash: ${log.cryptographicHash}',
                  style: const TextStyle(color: GVColors.brandGreen, fontSize: 11, fontFamily: 'monospace')),
              const Divider(color: Color(0xFF1F2B25), height: 24),
              const Text('PREVIOUS STATE (Before Edit):',
                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF274332)),
                ),
                child: SelectableText(log.previousStateJson,
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace')),
              ),
              const SizedBox(height: 12),
              const Text('NEW COMMITTED STATE (After Edit):',
                  style: TextStyle(color: GVColors.brandGreen, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF274332)),
                ),
                child: SelectableText(log.newStateJson,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auditState = ref.watch(auditNotifierProvider);
    final logs = auditState.filteredLogs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Audit Logs & Governance Trail',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cryptographically hashed, append-only audit records of operational overrides and financial approvals (§5.1)',
                      style: GVTypography.bodySmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GVColors.brandGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: GVColors.brandGreen),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: GVColors.brandGreen),
                    SizedBox(width: 6),
                    Text('Tamper-Evident SHA-256 Ledger',
                        style: TextStyle(color: GVColors.brandGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // Filters & Search
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('audit_search_input'),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search logs by actor, entity ID, or action description...',
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF101713),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1F2B25)),
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(auditNotifierProvider.notifier).setSearchQuery(val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                children: AuditCategory.values.map((cat) {
                  final isSelected = auditState.selectedCategory == cat;
                  return FilterChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: GVColors.brandGreen.withValues(alpha: 0.3),
                    backgroundColor: const Color(0xFF14241B),
                    labelStyle: TextStyle(
                      color: isSelected ? GVColors.brandGreen : Colors.white70,
                      fontSize: 11,
                    ),
                    onSelected: (_) {
                      ref.read(auditNotifierProvider.notifier).setCategory(cat);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // Logs Table
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
                    Text('Audit Trail (${logs.length} entries)', style: GVTypography.h3.copyWith(color: Colors.white)),
                    const Text('Immutable Ledger Active', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),
                if (logs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No audit trail entries found matching current filter or search criteria.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.4),
                    1: FlexColumnWidth(1.8),
                    2: FlexColumnWidth(1.4),
                    3: FlexColumnWidth(2.2),
                    4: FlexColumnWidth(1.2),
                    5: FlexColumnWidth(1.2),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF1F2B25))),
                      ),
                      children: [
                        _headerCell('TIMESTAMP'),
                        _headerCell('ACTOR / ROLE'),
                        _headerCell('CATEGORY'),
                        _headerCell('ACTION / ENTITY'),
                        _headerCell('IP ADDRESS'),
                        _headerCell('AUDIT INSPECT'),
                      ],
                    ),
                    ...logs.map((log) {
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF18221D))),
                        ),
                        children: [
                          _dataCell(
                            Text(_dateFormat.format(log.timestamp),
                                style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ),
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.actorName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                Text(log.actorRole, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                              ],
                            ),
                          ),
                          _dataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2B25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.category.name,
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ),
                          ),
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.action,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                Text('${log.entityType} · ${log.entityId}',
                                    style: const TextStyle(color: GVColors.brandGreen, fontSize: 10)),
                              ],
                            ),
                          ),
                          _dataCell(
                            Text(log.ipAddress, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                          ),
                          _dataCell(
                            OutlinedButton(
                              key: Key('inspect_log_${log.id}'),
                              onPressed: () => _showDiffModal(context, log),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GVColors.brandGreen,
                                side: const BorderSide(color: Color(0xFF274332)),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: const Size(60, 26),
                              ),
                              child: const Text('Inspect', style: TextStyle(fontSize: 10)),
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
