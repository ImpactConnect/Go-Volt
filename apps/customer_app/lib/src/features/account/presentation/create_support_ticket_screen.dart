import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_notifier.dart';
import '../application/support_notifier.dart';

/// Screen D4: Create and Submit Support Ticket (§D4 & Master Spec).
class CreateSupportTicketScreen extends ConsumerStatefulWidget {
  const CreateSupportTicketScreen({super.key});

  @override
  ConsumerState<CreateSupportTicketScreen> createState() => _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState extends ConsumerState<CreateSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bookingIdController = TextEditingController();

  String _selectedService = 'ride';
  String _selectedIssueCategory = 'Billing or Payment Dispute';
  String? _attachedFileName;

  final Map<String, String> _serviceOptions = {
    'ride': 'Electric Ride Booking',
    'parcel': 'Parcel Delivery',
    'errand': 'Market Errand Shopping',
    'scheduled': 'School Run Commute Plan',
    'wallet': 'Wallet & Payments',
    'account': 'Account & Security',
  };

  final List<String> _issueCategories = [
    'Billing or Payment Dispute',
    'Driver / Rider Conduct Dispute',
    'Wrong / Damaged / Missing Item',
    'Trip Cancellation / Delay Issue',
    'Commute Schedule Modification',
    'App Technical Bug or Error',
    'General Inquiry',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _bookingIdController.dispose();
    super.dispose();
  }

  void _pickAttachment() {
    setState(() {
      _attachedFileName = 'receipt_screenshot_${DateTime.now().millisecondsSinceEpoch % 10000}.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attached: $_attachedFileName'),
        backgroundColor: const Color(0xFF00D065),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = ref.read(authNotifierProvider).profile;
    final ticket = await ref.read(supportNotifierProvider.notifier).createTicket(
      userId: profile?.id,
      serviceCategory: _selectedService,
      issueType: _selectedIssueCategory,
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      relatedEntityId: _bookingIdController.text.trim().isNotEmpty
          ? _bookingIdController.text.trim()
          : null,
    );

    if (ticket != null && mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF141916),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D065).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: Color(0xFF00D065), size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ticket Submitted!',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ticket reference ${ticket.ticketNumber} has been logged in our support queue. A representative will review and respond shortly.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop(); // Back to help centre
              },
              child: const Text('Back to Help Centre', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pushReplacement('/support/tickets/${ticket.id}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D065),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'View Ticket',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportState = ref.watch(supportNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B100D),
      appBar: const GVTopBar(title: 'Submit Support Ticket'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141D17),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00D065).withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.support_agent, color: Color(0xFF00D065), size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Provide clear context about your order or account inquiry for accelerated resolution.',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Service category selector
              const Text(
                'Related Service',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141916),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedService,
                    dropdownColor: const Color(0xFF1E2822),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: _serviceOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedService = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Issue Category
              const Text(
                'Issue Category',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141916),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedIssueCategory,
                    dropdownColor: const Color(0xFF1E2822),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: _issueCategories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedIssueCategory = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Optional Related Order / Trip ID
              const Text(
                'Booking / Order / Transaction Reference (Optional)',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bookingIdController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. TRP-10492 or ORD-7821',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF141916),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Subject
              const Text(
                'Subject',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _subjectController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a subject line';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Brief summary of the issue...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF141916),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                'Detailed Description',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (val) {
                  if (val == null || val.trim().length < 10) {
                    return 'Please provide at least 10 characters describing the issue';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Include relevant details, timestamps, rider interaction, or unexpected charges...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF141916),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Attachment action
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickAttachment,
                    icon: const Icon(Icons.attach_file, color: Color(0xFF00D065), size: 18),
                    label: const Text(
                      'Attach Screenshot / Receipt',
                      style: TextStyle(color: Color(0xFF00D065), fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00D065)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),

              if (_attachedFileName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141916),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image, color: Color(0xFF00D065), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _attachedFileName!,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38, size: 16),
                        onPressed: () => setState(() => _attachedFileName = null),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: supportState.isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D065),
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: supportState.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text(
                          'Submit Support Ticket',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

