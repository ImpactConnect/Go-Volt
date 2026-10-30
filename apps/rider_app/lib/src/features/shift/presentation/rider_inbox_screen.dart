import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageItem {
  const MessageItem({
    required this.sender,
    required this.snippet,
    required this.time,
    required this.unread,
    required this.isSystem,
  });

  final String sender;
  final String snippet;
  final String time;
  final bool unread;
  final bool isSystem;
}

/// Screen RD30: Driver Inbox and Passenger Messages (Tab 4 in 5-tab shell).
class RiderInboxScreen extends ConsumerStatefulWidget {
  const RiderInboxScreen({super.key});

  @override
  ConsumerState<RiderInboxScreen> createState() => _RiderInboxScreenState();
}

class _RiderInboxScreenState extends ConsumerState<RiderInboxScreen> {
  final List<MessageItem> _messages = const [
    MessageItem(
      sender: 'Amara Bello',
      snippet: 'I will be waiting at the main gate.',
      time: '10:14 AM',
      unread: true,
      isSystem: false,
    ),
    MessageItem(
      sender: 'Go-Volts Operations',
      snippet: 'Peak hour incentives are live in Victoria Island! +15% per trip.',
      time: '08:30 AM',
      unread: true,
      isSystem: true,
    ),
    MessageItem(
      sender: 'Kelechi Nnamdi',
      snippet: 'Thank you for the smooth ride!',
      time: 'Yesterday',
      unread: false,
      isSystem: false,
    ),
    MessageItem(
      sender: 'Go-Volts Safety Unit',
      snippet: 'Scheduled battery swap hub maintenance in Lekki Phase 1.',
      time: '23 Oct',
      unread: false,
      isSystem: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        title: const Text(
          'Inbox & Messages',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(GVSpacing.md),
          itemCount: _messages.length,
          separatorBuilder: (_, _) => const SizedBox(height: GVSpacing.sm),
          itemBuilder: (context, index) {
            final item = _messages[index];
            return Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: item.unread
                    ? const Color(0xFF1E2822)
                    : const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(
                  color: item.unread
                      ? GVColors.brandGreen.withValues(alpha: 0.4)
                      : const Color(0xFF2A3630),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: item.isSystem
                        ? GVColors.deepGreen
                        : const Color(0xFF23352A),
                    child: Icon(
                      item.isSystem ? Icons.campaign : Icons.person,
                      color: GVColors.brandGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.sender,
                              style: GVTypography.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: item.unread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                            Text(
                              item.time,
                              style: GVTypography.caption.copyWith(
                                color: item.unread
                                    ? GVColors.brandGreen
                                    : Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.snippet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GVTypography.caption.copyWith(
                            color: item.unread
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.unread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: GVColors.brandGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
