import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD07: Safety Training & EV Operational Assessment.
class RiderTrainingScreen extends ConsumerStatefulWidget {
  const RiderTrainingScreen({super.key});

  @override
  ConsumerState<RiderTrainingScreen> createState() =>
      _RiderTrainingScreenState();
}

class _RiderTrainingScreenState extends ConsumerState<RiderTrainingScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          'When approaching deceleration zones or traffic in Lagos, how does regenerative braking work?',
      'options': [
        'It burns the brake pads faster to stop instantly.',
        'It captures kinetic energy during braking and recharges the battery pack.',
        'It has zero effect on the battery state of charge.',
      ],
      'correct': 1,
    },
    {
      'question':
          'What is the mandatory procedure at a Go-Volts battery swap station?',
      'options': [
        'Turn off bike ignition, insert depleted pack, await locked chime, then insert fresh pack.',
        'Swap the battery while the electric motor is still powered on.',
        'Force open closed lockers if a slot is unavailable.',
      ],
      'correct': 0,
    },
    {
      'question':
          'What is required before releasing a student during a School-Run commute?',
      'options': [
        'Drop the child at the gate if other students are walking in.',
        'Require the authorised guardian to provide the single-use 6-digit OTP in the app; never self-bypass.',
        'Allow any adult nearby to take the child without verification.',
      ],
      'correct': 1,
    },
    {
      'question':
          'If a parcel recipient cannot or refuses to provide the delivery OTP, what must you do?',
      'options': [
        'Leave the item at the door and mark delivery complete.',
        'File an in-app Delivery Exception and await Go-Volts Operations instructions.',
        'Take the package home.',
      ],
      'correct': 1,
    },
  ];

  final Map<int, int> _selectedAnswers = {0: 1, 1: 0, 2: 1, 3: 1};

  bool get _allPassed {
    if (_selectedAnswers.length < _questions.length) return false;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] != _questions[i]['correct']) return false;
    }
    return true;
  }

  Future<void> _handleSubmit() async {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    notifier.completeTraining(100);
    final success = await notifier.submitApplication();
    if (mounted && success) {
      context.go('/onboarding/status');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Application'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      backgroundColor: GVColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            const LinearProgressIndicator(
              value: 1.00,
              backgroundColor: Color(0xFF232D28),
              valueColor: AlwaysStoppedAnimation(GVColors.brandGreen),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Step 5 of 5: Safety Assessment',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '100% completed',
                    style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF232D28), height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(GVSpacing.md),
                children: [
                  Text(
                    'EV Safety & Standard Protocols',
                    style: GVTypography.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'All Go-Volts riders must complete the EV safety, battery care, and secure handover training module with 100% score.',
                    style: GVTypography.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: GVSpacing.lg),

                  // Questions List
                  for (int qIdx = 0; qIdx < _questions.length; qIdx++) ...[
                    _buildQuestionCard(qIdx),
                    const SizedBox(height: GVSpacing.md),
                  ],

                  if (_allPassed)
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: GVColors.deepGreen,
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(color: GVColors.brandGreen),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: GVColors.brandGreen,
                            size: 28,
                          ),
                          const SizedBox(width: GVSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assessment Passed (4/4 100%)',
                                  style: GVTypography.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'You have mastered EV riding, battery swap protocols, and school-run security.',
                                  style: GVTypography.caption.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: GVSpacing.xl),
                ],
              ),
            ),

            // Submit CTA
            Padding(
              padding: const EdgeInsets.all(GVSpacing.md),
              child: GVPrimaryButton(
                label: state.isLoading
                    ? 'Submitting Application...'
                    : 'Submit Application for Certification',
                onPressed: (state.isLoading || !_allPassed)
                    ? null
                    : _handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = _questions[index];
    final questionText = q['question'] as String;
    final options = q['options'] as List<String>;
    final selected = _selectedAnswers[index];

    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: GVColors.deepGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: GVTypography.caption.copyWith(
                    color: GVColors.brandGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: GVSpacing.xs),
              Expanded(
                child: Text(
                  questionText,
                  style: GVTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.sm),
          for (int optIdx = 0; optIdx < options.length; optIdx++) ...[
            InkWell(
              onTap: () {
                setState(() => _selectedAnswers[index] = optIdx);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.sm,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected == optIdx
                      ? (optIdx == q['correct']
                          ? const Color(0xFF133B26)
                          : const Color(0xFF3D1C1C))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected == optIdx
                        ? (optIdx == q['correct']
                            ? GVColors.brandGreen
                            : Colors.redAccent)
                        : Colors.white24,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected == optIdx
                          ? (optIdx == q['correct']
                              ? Icons.check_circle
                              : Icons.cancel)
                          : Icons.radio_button_unchecked,
                      color: selected == optIdx
                          ? (optIdx == q['correct']
                              ? GVColors.brandGreen
                              : Colors.redAccent)
                          : Colors.white54,
                      size: 18,
                    ),
                    const SizedBox(width: GVSpacing.xs),
                    Expanded(
                      child: Text(
                        options[optIdx],
                        style: GVTypography.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
