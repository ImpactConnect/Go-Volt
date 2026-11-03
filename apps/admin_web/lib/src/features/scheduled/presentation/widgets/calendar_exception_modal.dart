import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/admin_auth_notifier.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/scheduled_operations_notifier.dart';
import '../../domain/scheduled_operations_models.dart';

class CalendarExceptionModal extends ConsumerStatefulWidget {
  const CalendarExceptionModal({super.key});

  @override
  ConsumerState<CalendarExceptionModal> createState() =>
      _CalendarExceptionModalState();
}

class _CalendarExceptionModalState extends ConsumerState<CalendarExceptionModal> {
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();
  final _schoolController = TextEditingController(text: 'All Kaduna Schools');
  bool _notifyParents = true;
  bool _notifyDrivers = true;

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthNotifierProvider);
    final notifier = ref.read(scheduledOperationsNotifierProvider.notifier);

    return AdminModalDialog(
      title: 'Add School Calendar Exception',
      maxWidth: 620,
      cancelLabel: 'Cancel',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Declare a school holiday, weather emergency, or unscheduled closure. Active school-run manifests will be automatically paused without penalizing parent subscriptions.',
            style: GVTypography.bodySmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: GVSpacing.md),

          // Title
          Text(
            'Exception Title',
            style: GVTypography.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            key: const Key('exception_title_input'),
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Kaduna Flooding Safety Closure / Mid-Term Break',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF161F1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF263C2E)),
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Reason
          Text(
            'Official Reason / Memo Note',
            style: GVTypography.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            key: const Key('exception_reason_input'),
            controller: _reasonController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. State Ministry of Education directive or weather agency warning...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF161F1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF263C2E)),
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Schools
          Text(
            'Affected School(s)',
            style: GVTypography.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            key: const Key('exception_schools_input'),
            controller: _schoolController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. All Kaduna Schools or Kaduna Capital School, Essence',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF161F1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF263C2E)),
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Checkboxes
          CheckboxListTile(
            value: _notifyParents,
            onChanged: (v) => setState(() => _notifyParents = v ?? true),
            title: const Text('Send Instant SMS & Push Alerts to Registered Parents',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: GVColors.brandGreen,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _notifyDrivers,
            onChanged: (v) => setState(() => _notifyDrivers = v ?? true),
            title: const Text('Notify Assigned School Chaperones & Halt Dispatch',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: GVColors.brandGreen,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: GVSpacing.lg),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('submit_exception_btn'),
              onPressed: () async {
                final title = _titleController.text.trim();
                final reason = _reasonController.text.trim();
                final schoolsStr = _schoolController.text.trim();

                if (title.isEmpty || reason.isEmpty) return;

                final exception = SchoolCalendarExceptionModel(
                  id: 'EXC-${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  reason: reason,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 1)),
                  affectedSchools: schoolsStr.split(',').map((s) => s.trim()).toList(),
                  notifyParents: _notifyParents,
                  notifyDrivers: _notifyDrivers,
                  createdBy: authState.fullName,
                  createdAt: DateTime.now(),
                );

                await notifier.addCalendarException(exception);
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.add_alert, size: 18),
              label: const Text('Publish Calendar Exception'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GVColors.brandGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
