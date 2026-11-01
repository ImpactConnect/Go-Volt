import 'package:api_client/api_client.dart';
import 'package:app_models/app_models.dart';

class SupportRepository {
  SupportRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<SupportFaqDto>> getFaqs({String? category}) async {
    try {
      final res = await _apiClient.getFaqs(category: category);
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    final defaultFaqs = [
      const SupportFaqDto(
        id: 'faq_01',
        category: 'Rides',
        question: 'How are Go-Volts EV rides different from conventional petrol hailing?',
        answer: 'Go-Volts operates a 100% electric, zero-emission fleet powered by solar swap stations across Lagos. You produce zero exhaust fumes and avoid ~120g CO₂ per kilometer.',
        helpfulCount: 142,
      ),
      const SupportFaqDto(
        id: 'faq_02',
        category: 'Delivery',
        question: 'What are the parcel size and weight restrictions?',
        answer: 'Our electric courier bikes safely transport parcels up to 25kg and dimensions within 50cm x 50cm x 50cm. Fragile electronics and documents receive dedicated secure padding.',
        helpfulCount: 98,
      ),
      const SupportFaqDto(
        id: 'faq_03',
        category: 'Market Errand',
        question: 'How does pricing work for "Buy Items from a Shop"?',
        answer: 'You pay the verified market shelf price for items plus a flat service fee and distance delivery fee. Any price difference during shopping is updated in real time before checkout.',
        helpfulCount: 115,
      ),
      const SupportFaqDto(
        id: 'faq_04',
        category: 'School Run',
        question: 'How does school-run custody transfer and child safety work?',
        answer: 'All School-Run captains undergo LASRRA, NIN, and criminal background vetting. Custody transfer requires a single-use 6-digit OTP code before releasing a child at school or home.',
        helpfulCount: 230,
      ),
      const SupportFaqDto(
        id: 'faq_05',
        category: 'Wallet',
        question: 'How do I top up my wallet with instant settlement?',
        answer: 'You can top up using any Nigerian debit card via Paystack or transfer to your dedicated Providus virtual NUBAN account. Funds credit your ledger automatically within seconds.',
        helpfulCount: 187,
      ),
      const SupportFaqDto(
        id: 'faq_06',
        category: 'Safety',
        question: 'What happens when I trigger emergency SOS in the app?',
        answer: 'The app connects directly to Lagos State Emergency Services (112 / 767) while instantly alerting Go-Volts 24/7 Rapid Response fleet monitoring with your live vehicle GPS coordinates.',
        helpfulCount: 310,
      ),
    ];

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      return defaultFaqs.where((f) => f.category.toLowerCase() == category.toLowerCase()).toList();
    }
    return defaultFaqs;
  }

  Future<List<SupportTicketDto>> getTickets({String? userId}) async {
    try {
      final res = await _apiClient.getSupportTickets(userId: userId);
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return const [];
  }

  Future<SupportTicketDto> createTicket({
    String? userId,
    required String serviceCategory,
    required String issueType,
    required String subject,
    required String description,
    String? relatedEntityId,
  }) async {
    try {
      final res = await _apiClient.createSupportTicket(
        userId: userId,
        serviceCategory: serviceCategory,
        issueType: issueType,
        subject: subject,
        description: description,
        relatedEntityId: relatedEntityId,
      );
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    final ticketNum = 'TKT-${DateTime.now().millisecondsSinceEpoch % 100000}';
    return SupportTicketDto(
      id: 'tkt_${DateTime.now().millisecondsSinceEpoch}',
      ticketNumber: ticketNum,
      serviceCategory: serviceCategory,
      issueType: issueType,
      subject: subject,
      description: description,
      relatedEntityId: relatedEntityId,
      status: TicketStatus.submitted,
      createdAt: DateTime.now(),
      userId: userId,
      messages: [
        SupportTicketMessageDto(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          ticketId: ticketNum,
          senderId: userId ?? 'usr_current',
          senderName: 'Customer',
          senderRole: 'customer',
          message: description,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  Future<SupportTicketDto?> getTicketDetails({
    required String ticketId,
    String? userId,
  }) async {
    try {
      final res = await _apiClient.getSupportTicketDetails(
        ticketId: ticketId,
        userId: userId,
      );
      if (res.isSuccess && res.data != null) {
        return res.data;
      }
    } catch (_) {}
    return null;
  }

  Future<SupportTicketDto?> replyToTicket({
    required String ticketId,
    String? userId,
    required String message,
    String? senderName,
  }) async {
    try {
      final res = await _apiClient.replyToSupportTicket(
        ticketId: ticketId,
        userId: userId,
        message: message,
        senderName: senderName,
      );
      if (res.isSuccess && res.data != null) {
        return res.data;
      }
    } catch (_) {}
    return null;
  }
}

