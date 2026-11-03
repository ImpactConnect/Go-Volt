import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/support_safety_notifier.dart';

class FaqEditorModal extends ConsumerStatefulWidget {
  const FaqEditorModal({
    super.key,
    this.existingFaq,
  });

  final SupportFaqDto? existingFaq;

  @override
  ConsumerState<FaqEditorModal> createState() => _FaqEditorModalState();
}

class _FaqEditorModalState extends ConsumerState<FaqEditorModal> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  String _selectedCategory = 'Rides';

  static const List<String> _categories = [
    'Rides',
    'Delivery',
    'Market Errand',
    'School Run',
    'Wallet',
    'EV Charging',
    'Safety',
    'Account',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingFaq != null) {
      _questionController.text = widget.existingFaq!.question;
      _answerController.text = widget.existingFaq!.answer;
      _selectedCategory = widget.existingFaq!.category;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingFaq != null;

    return AdminModalDialog(
      title: isEditing ? 'Edit Knowledge Base Article' : 'Publish New FAQ Article',
      icon: Icons.menu_book_outlined,
      primaryActionLabel: isEditing ? 'Save Changes' : 'Publish to Customer App',
      onPrimaryAction: () {
        if (_questionController.text.trim().isEmpty || _answerController.text.trim().isEmpty) {
          return;
        }

        if (isEditing) {
          final updated = SupportFaqDto(
            id: widget.existingFaq!.id,
            category: _selectedCategory,
            question: _questionController.text.trim(),
            answer: _answerController.text.trim(),
            helpfulCount: widget.existingFaq!.helpfulCount,
          );
          ref.read(supportSafetyNotifierProvider.notifier).updateFaq(updated);
        } else {
          ref.read(supportSafetyNotifierProvider.notifier).addFaq(
                category: _selectedCategory,
                question: _questionController.text.trim(),
                answer: _answerController.text.trim(),
              );
        }

        Navigator.pop(context);
      },
      child: SizedBox(
        width: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Published FAQs are instantly synchronized to the Customer App Help Centre (§D3).',
              style: GVTypography.bodySmall.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Service Category',
                filled: true,
                fillColor: Color(0xFF14241B),
              ),
              dropdownColor: const Color(0xFF14241B),
              style: const TextStyle(color: Colors.white),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 14),

            // Question TextField
            TextField(
              controller: _questionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Frequently Asked Question',
                hintText: 'e.g. How do I top up my Go-Volts wallet using Paystack?',
                filled: true,
                fillColor: Color(0xFF14241B),
              ),
            ),
            const SizedBox(height: 14),

            // Answer TextField
            TextField(
              controller: _answerController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Official Guidance & Resolution',
                hintText: 'Provide clear, step-by-step instructions for the customer...',
                filled: true,
                fillColor: Color(0xFF14241B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
