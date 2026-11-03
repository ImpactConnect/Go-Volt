import 'package:admin_web/src/features/audit/application/audit_notifier.dart';
import 'package:admin_web/src/features/audit/domain/audit_models.dart';
import 'package:admin_web/src/features/bookings/application/booking_management_notifier.dart';
import 'package:admin_web/src/features/bookings/domain/booking_management_state.dart';
import 'package:admin_web/src/features/customers/application/customer_verification_notifier.dart';
import 'package:admin_web/src/features/customers/domain/customer_models.dart';
import 'package:admin_web/src/features/errands/application/errand_operations_notifier.dart';
import 'package:admin_web/src/features/errands/domain/errand_operations_models.dart';
import 'package:admin_web/src/features/finance/application/finance_notifier.dart';
import 'package:admin_web/src/features/finance/domain/finance_models.dart';
import 'package:admin_web/src/features/fleet/application/battery_swap_notifier.dart';
import 'package:admin_web/src/features/fleet/domain/battery_swap_models.dart';
import 'package:admin_web/src/features/integrations/application/integrations_notifier.dart';
import 'package:admin_web/src/features/integrations/domain/integration_models.dart';
import 'package:admin_web/src/features/operations/application/operations_notifier.dart';
import 'package:admin_web/src/features/operations/domain/operations_state.dart';
import 'package:admin_web/src/features/pricing/application/pricing_notifier.dart';
import 'package:admin_web/src/features/pricing/domain/pricing_models.dart';
import 'package:admin_web/src/features/promotions/application/promotions_notifier.dart';
import 'package:admin_web/src/features/promotions/domain/promotion_models.dart';
import 'package:admin_web/src/features/riders/application/rider_management_notifier.dart';
import 'package:admin_web/src/features/riders/domain/rider_management_state.dart';
import 'package:admin_web/src/features/safety/application/safety_sos_notifier.dart';
import 'package:admin_web/src/features/safety/domain/safety_sos_models.dart';
import 'package:admin_web/src/features/scheduled/application/scheduled_operations_notifier.dart';
import 'package:admin_web/src/features/scheduled/domain/scheduled_operations_models.dart';
import 'package:admin_web/src/features/support/application/support_safety_notifier.dart';
import 'package:admin_web/src/features/support/domain/support_safety_models.dart';
import 'package:app_models/app_models.dart' hide TicketStatus;
// --- Static Seed Data for Tests Only ---
final List<SupportTicketModel> _seedTickets = [
    SupportTicketModel(
      id: 'tick_801',
      ticketRef: 'TICK-2026-801',
      customerName: 'Fatima Dangote',
      riderName: 'Tunde Lawal',
      category: 'Lost Item',
      priority: TicketPriority.high,
      status: TicketStatus.inProgress,
      subject: 'Left leather pouch on moped rear carrier',
      description:
          'Customer reports left pouch containing ID cards on moped after dropoff at Victoria Island.',
      createdAt: DateTime(2026, 10, 24, 14, 10),
      assignedAgentId: 'staff_ops_kemi',
      serviceCategory: 'rides',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_01',
          ticketId: 'tick_801',
          senderId: 'cust_dangote',
          senderName: 'Fatima Dangote',
          senderRole: 'customer',
          message:
              'Hello, I completed a ride from Admiralty Way to Victoria Island around 1:30 PM. I believe I left my brown leather pouch in the moped carrier box.',
          createdAt: DateTime(2026, 10, 24, 14, 10),
        ),
        SupportTicketMessageDto(
          id: 'msg_02',
          ticketId: 'tick_801',
          senderId: 'staff_ops_kemi',
          senderName: 'Agent Kemi (Go-Volts Support)',
          senderRole: 'agent',
          message:
              'Hello Fatima, we have contacted rider Tunde Lawal. He has inspected the carrier and confirmed the pouch is secure. He will deliver it to our VI Swap Hub for pickup.',
          createdAt: DateTime(2026, 10, 24, 14, 35),
        ),
      ],
    ),
    SupportTicketModel(
      id: 'tick_802',
      ticketRef: 'TICK-2026-802',
      customerName: 'Emeka Nwosu',
      riderName: 'Ibrahim Danladi',
      category: 'Fare Dispute',
      priority: TicketPriority.normal,
      status: TicketStatus.open,
      subject: 'Billed ₦300 extra during off-peak commute',
      description:
          'Trip was billed with surge multiplier although booked 10 minutes prior to surge window.',
      createdAt: DateTime(2026, 10, 24, 15, 30),
      serviceCategory: 'wallet',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_03',
          ticketId: 'tick_802',
          senderId: 'cust_nwosu',
          senderName: 'Emeka Nwosu',
          senderRole: 'customer',
          message:
              'I was charged ₦2,800 instead of the quoted ₦2,500. The invoice showed a 1.2x surge, but my booking was initiated before the peak surge window.',
          createdAt: DateTime(2026, 10, 24, 15, 30),
        ),
      ],
    ),
    SupportTicketModel(
      id: 'tick_803',
      ticketRef: 'TICK-2026-803',
      customerName: 'Kalu Uche',
      riderName: 'Emeka Obi',
      category: 'App Bug',
      priority: TicketPriority.normal,
      status: TicketStatus.resolved,
      subject: 'In-app OTP notification delayed by SMS gateway',
      description:
          'Resolved by triggering fallback push notification token for rider verification.',
      createdAt: DateTime(2026, 10, 23, 11, 0),
      assignedAgentId: 'staff_ops_ade',
      serviceCategory: 'general',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_04',
          ticketId: 'tick_803',
          senderId: 'cust_uche',
          senderName: 'Kalu Uche',
          senderRole: 'customer',
          message: 'The OTP took over 5 minutes to arrive on my MTN line.',
          createdAt: DateTime(2026, 10, 23, 11, 0),
        ),
        SupportTicketMessageDto(
          id: 'msg_05',
          ticketId: 'tick_803',
          senderId: 'staff_ops_ade',
          senderName: 'Agent Adeola',
          senderRole: 'agent',
          message:
              'We have recalibrated our telecom routing to use primary WhatsApp & in-app push verification fallback for your account. Issue resolved.',
          createdAt: DateTime(2026, 10, 23, 11, 20),
        ),
      ],
    ),
    SupportTicketModel(
      id: 'tick_804',
      ticketRef: 'TICK-2026-804',
      customerName: 'Alexander Cole',
      riderName: 'Aminu Dantata',
      category: 'Item Substitution',
      priority: TicketPriority.high,
      status: TicketStatus.open,
      subject: 'Market Errand: Replacement pepper brand pricing discrepancy',
      description:
          'Customer requested Tatase pepper but store substituted with Rodo without price confirmation.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      serviceCategory: 'market_errand',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_06',
          ticketId: 'tick_804',
          senderId: 'cust_cole',
          senderName: 'Alexander Cole',
          senderRole: 'customer',
          message:
              'The shopping rider purchased a more expensive pepper pack without contacting me first, contrary to my errand preference setting.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    SupportTicketModel(
      id: 'tick_805',
      ticketRef: 'TICK-2026-805',
      customerName: 'Dr. Aisha Adeleke',
      riderName: 'Tunde Adeleke',
      category: 'School Run Safeguarding',
      priority: TicketPriority.urgent,
      status: TicketStatus.inProgress,
      subject: 'Scheduled Commute: Morning pickup time alignment',
      description:
          'Parent requests morning pickup window shifted 10 minutes earlier for Corona VI morning assembly.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      serviceCategory: 'scheduled',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_07',
          ticketId: 'cust_adeleke',
          senderId: 'cust_adeleke',
          senderName: 'Dr. Aisha Adeleke',
          senderRole: 'customer',
          message:
              'Please adjust our morning pickup at Block 4 Admiralty Way to 7:05 AM instead of 7:15 AM so Tari arrives before assembly begins.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        SupportTicketMessageDto(
          id: 'msg_08',
          ticketId: 'cust_adeleke',
          senderId: 'staff_ops_kemi',
          senderName: 'Agent Kemi (School-Run Ops)',
          senderRole: 'agent',
          message:
              'Noted Dr. Adeleke. We have updated your recurring scheduled manifest and informed chaperone rider Tunde Adeleke.',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
    ),
  ];

  final List<SafetyIncidentModel> _seedIncidents = [
    SafetyIncidentModel(
      id: 'safe_inc_001',
      incidentRef: 'INC-SAFE-2026-001',
      bookingRef: 'GV-SCH-7719',
      incidentType: 'Child Safeguarding Escort Deviation',
      severity: SafetyIncidentSeverity.critical,
      status: SafetyIncidentStatus.investigating,
      partiesInvolved: 'Student: Tari Adeleke (Age 11) · Rider: Emeka Obi · School: Corona VI',
      locationNarrative: 'Ahmadu Bello Way, VI (GPS deviation of 450m detected)',
      description:
          'Automated geofence telemetry triggered alert: Rider stopped outside school designated dropoff bay for 7 minutes. Safety team contacted guardian immediately.',
      reportedAt: DateTime(2026, 10, 24, 8, 15),
      investigationNotes: const [
        '08:16 - Geofence breach automated alert triggered',
        '08:18 - Safety officer called rider; rider reported minor road closure and pedestrian escort',
        '08:22 - School gatekeeper and parent verified safe arrival via secondary OTP',
      ],
      lawEnforcementReportRef: null,
    ),
    SafetyIncidentModel(
      id: 'safe_inc_002',
      incidentRef: 'INC-SAFE-2026-002',
      bookingRef: 'GV-LKG-3091',
      incidentType: 'Severe Collision / Vehicle Impact',
      severity: SafetyIncidentSeverity.critical,
      status: SafetyIncidentStatus.escalatedAuthorities,
      partiesInvolved: 'Rider: Musa Aliyu · Third Party: Commercial Minibus (Danfo)',
      locationNarrative: 'Third Mainland Bridge, Ebute Metta descent',
      description:
          'Electric motorcycle rear-ended by minibus during heavy congestion. Automatic crash detection triggered emergency beacon.',
      reportedAt: DateTime(2026, 10, 22, 18, 40),
      investigationNotes: const [
        '18:41 - Accelerometer impact sensor detected 6.5G deceleration',
        '18:44 - Emergency dispatch directed LASAMBUS ambulance team to coordinates',
        '19:10 - Rider hospitalized with stable vitals; helmet saved from head trauma',
        '20:00 - Police incident FIR filed at Ebute Metta Division',
      ],
      lawEnforcementReportRef: 'NPF-LAG-2026-4491-FIR',
      resolvedAt: null,
    ),
  ];

  final List<SupportFaqDto> _seedFaqs = [
    const SupportFaqDto(
      id: 'faq_01',
      category: 'Rides',
      question: 'How do I schedule a zero-emission electric bike ride?',
      answer:
          'Select "Book a Ride" from the home dashboard, enter pickup and destination points, choose an electric bike category (Eco Commute or Roam Air EV), and confirm payment.',
      helpfulCount: 42,
    ),
    const SupportFaqDto(
      id: 'faq_02',
      category: 'Delivery',
      question: 'What items are prohibited on Go-Volts parcel delivery?',
      answer:
          'Flammable liquids, firearms, unpackaged fragile glassware, and packages weighing over 30kg are strictly prohibited under Lagos State logistics guidelines.',
      helpfulCount: 29,
    ),
    const SupportFaqDto(
      id: 'faq_03',
      category: 'Market Errand',
      question: 'How does item substitution work during market errands?',
      answer:
          'If an item is out of stock, your assigned shopper will call or chat with you in-app based on your substitution preference before purchasing an alternative.',
      helpfulCount: 35,
    ),
    const SupportFaqDto(
      id: 'faq_04',
      category: 'School Run',
      question: 'How does the single-use handover OTP protect my child?',
      answer:
          'Every pickup and delivery requires a 6-digit OTP sent exclusively to the authorized parent. The chaperone rider cannot complete the trip without entering this code.',
      helpfulCount: 58,
    ),
    const SupportFaqDto(
      id: 'faq_05',
      category: 'Wallet',
      question: 'How do I top up my Go-Volts wallet using Paystack?',
      answer:
          'Navigate to Wallet > Top Up, enter the desired amount, and select Debit Card (Paystack 3DS) or Bank Transfer to your dedicated virtual NUBAN account.',
      helpfulCount: 64,
    ),
    const SupportFaqDto(
      id: 'faq_06',
      category: 'Safety',
      question: 'What emergency numbers can I dial in Lagos State?',
      answer:
          'You can dial Lagos State Emergency Response directly at 112 or 767, or call our 24/7 Go-Volts Operations Rapid Hotline at 0700-GOVOLTS.',
      helpfulCount: 71,
    ),
  ];

  

final List<RefundRequestModel> _seedRefunds = [
    RefundRequestModel(
      id: 'ref_req_101',
      bookingRef: 'GV-LKG-9021',
      customerName: 'Chiamaka Okonjo',
      amountKobo: BigInt.from(1500000), // ₦15,000 (>= ₦10,000 => requires dual approval)
      reason: 'School-Run trip cancelled due to sudden route flooding; parent pre-paid weekly bundle',
      makerId: 'staff_ops_ade',
      makerName: 'Adeola Sowande (Ops Agent)',
      makerTimestamp: DateTime(2026, 10, 24, 8, 30),
      status: RefundStatus.pendingCheckerSignoff,
    ),
    RefundRequestModel(
      id: 'ref_req_102',
      bookingRef: 'GV-B2B-4412',
      customerName: 'Emeka Eze',
      amountKobo: BigInt.from(450000), // ₦4,500 (< ₦10,000 => single review)
      reason: 'Delivery package delayed by 45 mins due to tire puncture',
      makerId: 'staff_ops_kemi',
      makerName: 'Kemi Balogun (Ops Agent)',
      makerTimestamp: DateTime(2026, 10, 24, 11, 15),
      status: RefundStatus.pendingReview,
    ),
    RefundRequestModel(
      id: 'ref_req_103',
      bookingRef: 'GV-TRIP-3310',
      customerName: 'Babatunde Fashola',
      amountKobo: BigInt.from(2500000), // ₦25,000 (Approved via dual signoff)
      reason: 'VIP hourly dispatch cancelled 24h prior in accordance with refund policy',
      makerId: 'staff_ops_ade',
      makerName: 'Adeola Sowande (Ops Agent)',
      makerTimestamp: DateTime(2026, 10, 23, 14, 0),
      status: RefundStatus.approved,
      checkerId: 'staff_fin_olumide',
      checkerName: 'Olumide Bakare (Finance Officer)',
      checkerTimestamp: DateTime(2026, 10, 23, 16, 20),
    ),
  ];

  final List<PayoutBatchModel> _seedBatches = [
    PayoutBatchModel(
      batchId: 'BATCH-2026-W42',
      period: '17 Oct - 23 Oct 2026',
      totalRiders: 142,
      totalAmountKobo: BigInt.from(894500000), // ₦8,945,000
      status: 'settled',
      generatedAt: DateTime(2026, 10, 24, 6, 0),
      settledAt: DateTime(2026, 10, 24, 7, 30),
    ),
    PayoutBatchModel(
      batchId: 'BATCH-2026-W43-MID',
      period: '24 Oct 2026 (Daily Instant)',
      totalRiders: 36,
      totalAmountKobo: BigInt.from(245500000), // ₦2,455,000
      status: 'pending_payout',
      generatedAt: DateTime(2026, 10, 24, 17, 0),
    ),
  ];

  final List<PricingRuleModel> _seedRules = [
    PricingRuleModel(
      id: 'pr_commute_v2_1',
      version: 'v2.1',
      tier: ServiceTier.commute,
      baseFareKobo: BigInt.from(60000), // ₦600
      perKmKobo: BigInt.from(12000), // ₦120/km
      perMinuteKobo: BigInt.from(2500), // ₦25/min
      minimumFareKobo: BigInt.from(80000), // ₦800
      surgeMultiplierCap: 2.0,
      status: PricingRuleStatus.active,
      effectiveDate: DateTime(2026, 9, 1),
      createdBy: 'admin_sys',
      notes: 'Harmonized fuel subsidy price baseline for Lagos metropolis',
    ),
    PricingRuleModel(
      id: 'pr_parcel_v1_8',
      version: 'v1.8',
      tier: ServiceTier.expressParcel,
      baseFareKobo: BigInt.from(50000), // ₦500
      perKmKobo: BigInt.from(10000), // ₦100/km
      perMinuteKobo: BigInt.from(1500), // ₦15/min
      minimumFareKobo: BigInt.from(70000), // ₦700
      surgeMultiplierCap: 1.8,
      status: PricingRuleStatus.active,
      effectiveDate: DateTime(2026, 8, 15),
      createdBy: 'admin_sys',
      notes: 'B2B e-commerce parcel matrix baseline',
    ),
    PricingRuleModel(
      id: 'pr_school_v1_2',
      version: 'v1.2',
      tier: ServiceTier.schoolRun,
      baseFareKobo: BigInt.from(120000), // ₦1,200
      perKmKobo: BigInt.from(15000), // ₦150/km
      perMinuteKobo: BigInt.from(3000), // ₦30/min
      minimumFareKobo: BigInt.from(150000), // ₦1,500
      surgeMultiplierCap: 1.5,
      status: PricingRuleStatus.active,
      effectiveDate: DateTime(2026, 9, 10),
      createdBy: 'safety_officer_ade',
      notes: 'Child safeguard chaperone surcharge included',
    ),
    PricingRuleModel(
      id: 'pr_commute_v2_0_archived',
      version: 'v2.0',
      tier: ServiceTier.commute,
      baseFareKobo: BigInt.from(50000),
      perKmKobo: BigInt.from(10000),
      perMinuteKobo: BigInt.from(2000),
      minimumFareKobo: BigInt.from(70000),
      surgeMultiplierCap: 2.5,
      status: PricingRuleStatus.archived,
      effectiveDate: DateTime(2026, 5, 1),
      createdBy: 'admin_sys',
      notes: 'Superseded by v2.1 fuel adjustment',
    ),
  ];

  final List<ServiceAreaZoneModel> _seedZones = [
    const ServiceAreaZoneModel(
      zoneId: 'lagos_island',
      zoneName: 'Lagos Island / VI / Lekki',
      city: 'Lagos',
      isActive: true,
      enabledTiers: {
        ServiceTier.commute,
        ServiceTier.expressParcel,
        ServiceTier.scheduled,
        ServiceTier.schoolRun,
      },
      currentSurgeMultiplier: 1.25,
      maxSurgeCap: 2.0,
      activeRidersCount: 42,
    ),
    const ServiceAreaZoneModel(
      zoneId: 'lagos_mainland',
      zoneName: 'Ikeja / Maryland / Surulere',
      city: 'Lagos',
      isActive: true,
      enabledTiers: {
        ServiceTier.commute,
        ServiceTier.expressParcel,
        ServiceTier.scheduled,
      },
      currentSurgeMultiplier: 1.0,
      maxSurgeCap: 1.8,
      activeRidersCount: 38,
    ),
    const ServiceAreaZoneModel(
      zoneId: 'abuja_central',
      zoneName: 'Abuja Central / Maitama / Wuse',
      city: 'Abuja',
      isActive: true,
      enabledTiers: {
        ServiceTier.commute,
        ServiceTier.expressParcel,
      },
      currentSurgeMultiplier: 1.0,
      maxSurgeCap: 1.5,
      activeRidersCount: 16,
    ),
  ];

  

final List<PartnerIntegrationModel> _seedPartners = [
    PartnerIntegrationModel(
      id: 'int_retail_ai',
      partnerName: 'Retail Ai Smart Logistics',
      apiKeyPrefix: 'gv_live_rt_ai_8891...xK8',
      webhookUrl: 'https://api.retail-ai.africa/v1/logistics/go-volt-webhook',
      isActive: true,
      isHmacVerified: true,
      totalDispatchesToday: 134,
      lastWebhookPing: DateTime(2026, 10, 24, 15, 45),
      pingSuccess: true,
    ),
    PartnerIntegrationModel(
      id: 'int_shoprite_lekki',
      partnerName: 'Shoprite Express On-Demand',
      apiKeyPrefix: 'gv_live_sp_lek_3021...p9L',
      webhookUrl: 'https://delivery.shoprite.ng/integrations/go-volt/status',
      isActive: true,
      isHmacVerified: true,
      totalDispatchesToday: 48,
      lastWebhookPing: DateTime(2026, 10, 24, 15, 30),
      pingSuccess: true,
    ),
    PartnerIntegrationModel(
      id: 'int_jumia_food',
      partnerName: 'Jumia Quick Commerce Hub',
      apiKeyPrefix: 'gv_test_jm_qck_7190...m1Z',
      webhookUrl: 'https://staging.jumia.com.ng/b2b-fulfillment/callback',
      isActive: false,
      isHmacVerified: false,
      totalDispatchesToday: 0,
      lastWebhookPing: DateTime(2026, 10, 23, 12, 0),
      pingSuccess: false,
    ),
  ];

  

final List<AuditLogEntry> _seedLogs = [
    AuditLogEntry(
      id: 'aud_001',
      timestamp: DateTime(2026, 10, 24, 15, 20),
      actorId: 'staff_ops_ade',
      actorName: 'Adeola Sowande',
      actorRole: 'Operations Agent',
      category: AuditCategory.dispatchOverride,
      action: 'Manual Rider Reassignment Override',
      entityType: 'Booking',
      entityId: 'GV-TRIP-1092',
      previousStateJson: '{"assignedRiderId": "rd_musa_02", "reason": null}',
      newStateJson: '{"assignedRiderId": "rd_tunde_01", "overrideReason": "Tire puncture on rd_musa_02"}',
      ipAddress: '102.89.23.44',
      cryptographicHash: 'SHA256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    ),
    AuditLogEntry(
      id: 'aud_002',
      timestamp: DateTime(2026, 10, 24, 14, 10),
      actorId: 'staff_fin_olumide',
      actorName: 'Olumide Bakare',
      actorRole: 'Finance Officer',
      category: AuditCategory.makerCheckerRefund,
      action: 'Dual Sign-Off Approved for ₦15,000 Refund',
      entityType: 'RefundRequest',
      entityId: 'ref_req_101',
      previousStateJson: '{"status": "pendingCheckerSignoff", "makerId": "staff_ops_ade"}',
      newStateJson: '{"status": "approved", "checkerId": "staff_fin_olumide", "payoutMode": "wallet_credit"}',
      ipAddress: '102.89.23.49',
      cryptographicHash: 'SHA256:8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4',
    ),
    AuditLogEntry(
      id: 'aud_003',
      timestamp: DateTime(2026, 10, 24, 11, 45),
      actorId: 'admin_sys',
      actorName: 'System Administrator',
      actorRole: 'Operations Admin',
      category: AuditCategory.pricingTariff,
      action: 'Published Versioned Tariff v2.1 (Commute)',
      entityType: 'PricingRule',
      entityId: 'pr_commute_v2_1',
      previousStateJson: '{"activeVersion": "v2.0", "baseFareKobo": 50000}',
      newStateJson: '{"activeVersion": "v2.1", "baseFareKobo": 60000, "pastQuotes": "immutable"}',
      ipAddress: '197.210.8.12',
      cryptographicHash: 'SHA256:5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8',
    ),
    AuditLogEntry(
      id: 'aud_004',
      timestamp: DateTime(2026, 10, 24, 9, 30),
      actorId: 'safety_officer_ade',
      actorName: 'Dr. Adeola Balogun',
      actorRole: 'Safety Officer',
      category: AuditCategory.riderCompliance,
      action: 'Approved School-Run Chaperone Vetting Certification',
      entityType: 'RiderCompliance',
      entityId: 'rd_emeka_01',
      previousStateJson: '{"schoolRunCertified": false, "ninVerified": true}',
      newStateJson: '{"schoolRunCertified": true, "policeClearanceId": "NPF-CLR-8812"}',
      ipAddress: '102.89.23.10',
      cryptographicHash: 'SHA256:4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a',
    ),
  ];

  

final List<CouponModel> _seedCoupons = [
    CouponModel(
      id: 'cp_eco_20',
      code: 'ECO20',
      discountType: DiscountType.percentage,
      discountValue: 20.0,
      minOrderKobo: BigInt.from(100000), // ₦1,000
      maxDiscountKobo: BigInt.from(150000), // ₦1,500
      usageLimit: 1000,
      usageCount: 423,
      expiresAt: DateTime(2026, 12, 31),
      isActive: true,
      description: '20% off all electric motorcycle commute trips up to ₦1,500',
    ),
    CouponModel(
      id: 'cp_parcel_flat',
      code: 'VOLTPARCEL',
      discountType: DiscountType.fixedAmount,
      discountValue: 50000.0, // ₦500
      minOrderKobo: BigInt.from(120000), // ₦1,200
      maxDiscountKobo: null,
      usageLimit: 500,
      usageCount: 198,
      expiresAt: DateTime(2026, 11, 30),
      isActive: true,
      description: 'Flat ₦500 discount on first B2B express delivery parcel',
    ),
    CouponModel(
      id: 'cp_school_term',
      code: 'SAFESCHOOL',
      discountType: DiscountType.percentage,
      discountValue: 15.0,
      minOrderKobo: BigInt.from(250000), // ₦2,500
      maxDiscountKobo: BigInt.from(500000), // ₦5,000
      usageLimit: 200,
      usageCount: 77,
      expiresAt: DateTime(2026, 10, 31),
      isActive: true,
      description: '15% discount for verified School-Run chaperone subscriptions',
    ),
  ];

  

extension OperationsNotifierTestSeed on OperationsNotifier {
  void seedForTest() {

    updateStateForTesting(
      state.copyWith(
        activeTripsCount: 42,
        onlineRidersCount: 58,
        unassignedJobsCount: 7,
        overduePickupsCount: 2,
        avgResponseTimeMins: 3.4,
        grossRevenueTodayKobo: 142080000,
        surgeMultiplier: 1.3,
        activeZone: 'Lekki / Victoria Island',

      onlineRiders: const [
        OnlineRiderTelemetry(
          id: 'RDR-001',
          fullName: 'Babajide Ogundipe',
          vehiclePlate: 'LAG-428-EV',
          vehicleModel: 'Roam Air EV Bike',
          batteryPercent: 92,
          currentZone: 'Lekki Phase 1',
          lastHeartbeatSecondsAgo: 3,
          status: 'idle',
          rating: 4.96,
        ),
        OnlineRiderTelemetry(
          id: 'RDR-002',
          fullName: 'Emeka Nwosu',
          vehiclePlate: 'LAG-889-ET',
          vehicleModel: 'Spiro EV Trike',
          batteryPercent: 78,
          currentZone: 'Victoria Island',
          lastHeartbeatSecondsAgo: 5,
          status: 'in_transit',
          rating: 4.88,
        ),
        OnlineRiderTelemetry(
          id: 'RDR-003',
          fullName: 'Aminu Dantata',
          vehiclePlate: 'LAG-310-EV',
          vehicleModel: 'Roam Air EV Bike',
          batteryPercent: 14,
          currentZone: 'Oniru / Lekki Toll',
          lastHeartbeatSecondsAgo: 2,
          status: 'low_battery',
          rating: 4.91,
        ),
        OnlineRiderTelemetry(
          id: 'RDR-004',
          fullName: 'Tunde Adeleke',
          vehiclePlate: 'LAG-992-ET',
          vehicleModel: 'Spiro EV Trike (School Chaperone)',
          batteryPercent: 86,
          currentZone: 'Ikoyi / Parkview',
          lastHeartbeatSecondsAgo: 8,
          status: 'idle',
          rating: 5.0,
        ),
      ],
      urgentJobs: const [
        UnassignedJobAlert(
          bookingId: 'BK-GV-9021',
          reference: 'GV-BK-89021',
          serviceType: ServiceTierEligibility.schoolRunCommute,
          customerName: 'Dr. Aisha Adeleke',
          pickupAddress: 'Block 4 Admiralty Way, Lekki',
          dropoffAddress: 'Corona School, Victoria Island',
          fareKobo: 400000,
          minutesWaiting: 8,
          isOverdue: true,
        ),
        UnassignedJobAlert(
          bookingId: 'BK-GV-9022',
          reference: 'GV-BK-89022',
          serviceType: ServiceTierEligibility.parcelDelivery,
          customerName: 'Chidinma Okafor',
          pickupAddress: 'Plot 14 Admiralty Way, Lekki',
          dropoffAddress: 'Ahmadu Bello Way, VI',
          fareKobo: 300000,
          minutesWaiting: 12,
          isOverdue: true,
        ),
        UnassignedJobAlert(
          bookingId: 'BK-GV-9023',
          reference: 'GV-BK-89023',
          serviceType: ServiceTierEligibility.passengerRide,
          customerName: 'Kehinde Balogun',
          pickupAddress: 'Ozumba Mbadiwe Ave, VI',
          dropoffAddress: 'Marina Bus Stop, Lagos Island',
          fareKobo: 250000,
          minutesWaiting: 4,
          isOverdue: false,
        ),
      ],
    ));
  }
}

extension BookingManagementNotifierTestSeed on BookingManagementNotifier {
  void seedForTest() {

    updateStateForTesting(state.copyWith(
      bookings: [
        const AdminBookingItem(
          id: 'BK-001',
          reference: 'GV-BK-2026-001',
          source: 'Customer Mobile App',
          customerName: 'Chidinma Okafor',
          customerPhone: '+2348039988776',
          riderName: 'Babajide Ogundipe',
          riderPhone: '+2348031122334',
          riderPlate: 'LAG-428-EV',
          serviceType: ServiceTierEligibility.parcelDelivery,
          status: BookingStatus.inProgress,
          pickupAddress: 'Plot 14 Admiralty Way, Lekki',
          dropoffAddress: 'Ahmadu Bello Way, Victoria Island',
          grossFareKobo: 300000,
          platformCommissionKobo: 60000,
          createdAt: '2026-10-24 14:15',
          timeline: [
            AdminBookingTimelineEvent(
              status: 'QUOTED',
              timestamp: '14:10:02',
              note: 'Upfront quote locked at ₦3,000 (1.0x baseline)',
            ),
            AdminBookingTimelineEvent(
              status: 'RIDER_ASSIGNED',
              timestamp: '14:11:45',
              note: 'Assigned to Babajide Ogundipe (LAG-428-EV)',
            ),
            AdminBookingTimelineEvent(
              status: 'PICKED_UP',
              timestamp: '14:22:10',
              note: 'Package collected with sender digital signature',
            ),
          ],
        ),
        const AdminBookingItem(
          id: 'BK-002',
          reference: 'GV-BK-2026-002',
          source: 'Retail Ai Partner',
          customerName: 'Mrs. Folake Adeleke',
          customerPhone: '+2348021122334',
          riderName: 'Tunde Adeleke',
          riderPhone: '+2348029988776',
          riderPlate: 'LAG-992-ET',
          serviceType: ServiceTierEligibility.schoolRunCommute,
          status: BookingStatus.assigned,
          pickupAddress: 'Corona School, VI',
          dropoffAddress: 'Parkview Estate, Ikoyi',
          grossFareKobo: 400000,
          platformCommissionKobo: 80000,
          createdAt: '2026-10-24 14:00',
          timeline: [
            AdminBookingTimelineEvent(
              status: 'QUOTED',
              timestamp: '13:58:00',
              note: 'Plan subscription quote verified',
            ),
            AdminBookingTimelineEvent(
              status: 'RIDER_ASSIGNED',
              timestamp: '14:02:15',
              note: 'Dedicated chaperone Tunde Adeleke confirmed',
            ),
          ],
        ),
        const AdminBookingItem(
          id: 'BK-003',
          reference: 'GV-BK-2026-003',
          source: 'Merchant Portal',
          customerName: 'Ereke E-Commerce Store',
          customerPhone: '+2348099988877',
          serviceType: ServiceTierEligibility.parcelDelivery,
          status: BookingStatus.searchingRider,
          pickupAddress: '18 Allen Avenue, Ikeja',
          dropoffAddress: 'Gbagada Expressway, Lagos',
          grossFareKobo: 350000,
          platformCommissionKobo: 70000,
          createdAt: '2026-10-24 14:28',
          timeline: [
            AdminBookingTimelineEvent(
              status: 'QUOTED',
              timestamp: '14:28:10',
              note: 'Merchant API bulk dispatch created',
            ),
            AdminBookingTimelineEvent(
              status: 'DISPATCHING',
              timestamp: '14:28:15',
              note: 'Searching for nearby EV trikes',
            ),
          ],
        ),
        const AdminBookingItem(
          id: 'BK-004',
          reference: 'GV-BK-2026-004',
          source: 'Customer Mobile App',
          customerName: 'Dr. Kehinde Balogun',
          customerPhone: '+2348055544433',
          riderName: 'Emeka Nwosu',
          riderPhone: '+2348038877665',
          riderPlate: 'LAG-889-ET',
          serviceType: ServiceTierEligibility.passengerRide,
          status: BookingStatus.completed,
          pickupAddress: 'Ozumba Mbadiwe Ave, VI',
          dropoffAddress: 'Broad Street, Lagos Island',
          grossFareKobo: 280000,
          platformCommissionKobo: 56000,
          createdAt: '2026-10-24 12:30',
          timeline: [
            AdminBookingTimelineEvent(
              status: 'COMPLETED',
              timestamp: '13:05:00',
              note: 'Trip ended. Fare settled to wallet ledger.',
            ),
          ],
        ),
      ],
    ));
  
  }
}

extension CustomerVerificationNotifierTestSeed on CustomerVerificationNotifier {
  void seedForTest() {

    updateStateForTesting(state.copyWith(
      customers: [
        CustomerVerificationItem(
          id: 'CUST-001',
          fullName: 'Alexander Cole',
          phone: '+234 801 234 5678',
          email: 'alexander.cole@example.com',
          registeredAt: DateTime.now().subtract(const Duration(days: 45)),
          status: VerificationStatus.pending,
          tier: 'Tier 2 (Identity Verified)',
          submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
          ninNumber: '28471928374',
          residentialAddress: '14 Admiralty Way, Lekki Phase 1, Lagos',
          activeCommutePlansCount: 1,
          walletBalanceKobo: 2500000,
          requiredDocuments: const ['National Identification Number (NIN)', 'Utility Bill (Proof of Address)'],
          documentUrls: const {
            'National Identification Number (NIN)': 'https://storage.govolts.ng/docs/cust001_nin.pdf',
            'Utility Bill (Proof of Address)': 'https://storage.govolts.ng/docs/cust001_utility.pdf',
          },
        ),
        CustomerVerificationItem(
          id: 'CUST-002',
          fullName: 'Dr. Aisha Adeleke',
          phone: '+234 802 987 6543',
          email: 'aisha.adeleke@medlagos.ng',
          registeredAt: DateTime.now().subtract(const Duration(days: 120)),
          status: VerificationStatus.verified,
          tier: 'Tier 3 (Safeguarded Guardian)',
          submittedAt: DateTime.now().subtract(const Duration(days: 60)),
          verifiedAt: DateTime.now().subtract(const Duration(days: 59)),
          ninNumber: '91827364510',
          residentialAddress: 'Block 4, Parkview Estate, Ikoyi, Lagos',
          activeCommutePlansCount: 2,
          walletBalanceKobo: 8400000,
          requiredDocuments: const ['National Identification Number (NIN)', 'LASRRA Resident ID', 'School Guardian Consent'],
          documentUrls: const {
            'National Identification Number (NIN)': 'https://storage.govolts.ng/docs/cust002_nin.pdf',
            'LASRRA Resident ID': 'https://storage.govolts.ng/docs/cust002_lasrra.jpg',
            'School Guardian Consent': 'https://storage.govolts.ng/docs/cust002_guardian.pdf',
          },
        ),
        CustomerVerificationItem(
          id: 'CUST-003',
          fullName: 'Kehinde Balogun',
          phone: '+234 803 555 1212',
          email: 'k.balogun@techhub.ng',
          registeredAt: DateTime.now().subtract(const Duration(days: 18)),
          status: VerificationStatus.actionRequired,
          tier: 'Tier 1 (Basic)',
          submittedAt: DateTime.now().subtract(const Duration(days: 2)),
          rejectionReason: 'The uploaded NIN slip is blurred and illegible. Please re-upload a clear scanned copy.',
          ninNumber: '67482910394',
          residentialAddress: 'Ozumba Mbadiwe Ave, Victoria Island, Lagos',
          activeCommutePlansCount: 0,
          walletBalanceKobo: 150000,
          requiredDocuments: const ['National Identification Number (NIN)', 'Proof of Address'],
          documentUrls: const {
            'National Identification Number (NIN)': 'https://storage.govolts.ng/docs/cust003_nin_blurry.jpg',
          },
        ),
        CustomerVerificationItem(
          id: 'CUST-004',
          fullName: 'Folashade Alakija',
          phone: '+234 809 111 2233',
          email: 'fola.alakija@trade.com.ng',
          registeredAt: DateTime.now().subtract(const Duration(days: 5)),
          status: VerificationStatus.pending,
          tier: 'Tier 2 (Identity Verified)',
          submittedAt: DateTime.now().subtract(const Duration(hours: 1)),
          ninNumber: '39485720193',
          residentialAddress: '22 Isaac John St, GRA Ikeja, Lagos',
          activeCommutePlansCount: 1,
          walletBalanceKobo: 5200000,
          requiredDocuments: const ['National Identification Number (NIN)', 'LASRRA Resident Card'],
          documentUrls: const {
            'National Identification Number (NIN)': 'https://storage.govolts.ng/docs/cust004_nin.pdf',
            'LASRRA Resident Card': 'https://storage.govolts.ng/docs/cust004_lasrra.jpg',
          },
        ),
        CustomerVerificationItem(
          id: 'CUST-005',
          fullName: 'Tunde Bakare',
          phone: '+234 805 777 8899',
          email: 'tunde.bakare@freightexpress.ng',
          registeredAt: DateTime.now().subtract(const Duration(days: 10)),
          status: VerificationStatus.rejected,
          tier: 'Tier 1 (Basic)',
          submittedAt: DateTime.now().subtract(const Duration(days: 4)),
          rejectionReason: 'ID submitted does not match the customer legal name registered on account.',
          ninNumber: '11223344556',
          residentialAddress: 'Plot 8 Commercial Ave, Yaba, Lagos',
          activeCommutePlansCount: 0,
          walletBalanceKobo: 0,
          requiredDocuments: const ['Government Issued ID'],
          documentUrls: const {
            'Government Issued ID': 'https://storage.govolts.ng/docs/cust005_mismatch_id.jpg',
          },
        ),
      ],
    ));
  
  }
}

extension RiderManagementNotifierTestSeed on RiderManagementNotifier {
  void seedForTest() {

    updateStateForTesting(state.copyWith(
      riders: [
        AdminRiderApplicant(
          id: 'RDR-APP-101',
          fullName: 'Babatunde Fashola',
          phone: '+2348021122334',
          email: 'tunde.fashola@govolts.ng',
          vehiclePlate: 'LA-999-IS',
          vehicleClass: 'Roam Air EV Bike',
          batteryCapacity: '3.2 kWh LFP',
          batteryHealthPercent: 96,
          status: RiderComplianceStatus.pendingReview,
          certifiedTiers: const [
            ServiceTierEligibility.parcelDelivery,
            ServiceTierEligibility.passengerRide,
          ],
          documents: [
            RiderDocumentDto(
              id: 'doc-1',
              type: DocumentType.nationalId,
              documentNumber: '10928374651',
              fileUrl: 'https://cdn.govolts.ng/docs/nin_fashola.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 800)),
              status: DocumentVerificationStatus.approved,
            ),
            RiderDocumentDto(
              id: 'doc-2',
              type: DocumentType.driversLicense,
              documentNumber: 'DL-LAG-2024-991',
              fileUrl: 'https://cdn.govolts.ng/docs/dl_fashola.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 360)),
              status: DocumentVerificationStatus.pending,
            ),
            RiderDocumentDto(
              id: 'doc-3',
              type: DocumentType.vehicleRegistration,
              documentNumber: 'VR-LAG-8821-EV',
              fileUrl: 'https://cdn.govolts.ng/docs/vr_fashola.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 300)),
              status: DocumentVerificationStatus.pending,
            ),
          ],
          ratingAverage: 0.0,
          completedTrips: 0,
          appliedDate: '2026-10-24 11:30',
        ),
        AdminRiderApplicant(
          id: 'RDR-APP-102',
          fullName: 'Babajide Ogundipe',
          phone: '+2348031122334',
          email: 'babajide.ogundipe@govolts.ng',
          vehiclePlate: 'LAG-428-EV',
          vehicleClass: 'Roam Air EV Bike',
          batteryCapacity: '3.2 kWh LFP',
          batteryHealthPercent: 92,
          status: RiderComplianceStatus.approved,
          certifiedTiers: const [
            ServiceTierEligibility.parcelDelivery,
            ServiceTierEligibility.passengerRide,
            ServiceTierEligibility.schoolRunCommute,
          ],
          documents: [
            RiderDocumentDto(
              id: 'doc-4',
              type: DocumentType.nationalId,
              documentNumber: '10928374651',
              fileUrl: 'https://cdn.govolts.ng/docs/nin.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 900)),
              status: DocumentVerificationStatus.approved,
            ),
            RiderDocumentDto(
              id: 'doc-5',
              type: DocumentType.driversLicense,
              documentNumber: 'DL-882-LAG',
              fileUrl: 'https://cdn.govolts.ng/docs/dl.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 420)),
              status: DocumentVerificationStatus.approved,
            ),
          ],
          ratingAverage: 4.96,
          completedTrips: 184,
          appliedDate: '2026-09-12 09:15',
        ),
        AdminRiderApplicant(
          id: 'RDR-APP-103',
          fullName: 'Aminu Dantata',
          phone: '+2348051234567',
          email: 'aminu.dantata@govolts.ng',
          vehiclePlate: 'LAG-310-EV',
          vehicleClass: 'Roam Air EV Bike',
          batteryCapacity: '3.2 kWh LFP',
          batteryHealthPercent: 84,
          status: RiderComplianceStatus.suspended,
          certifiedTiers: const [
            ServiceTierEligibility.parcelDelivery,
          ],
          documents: [
            RiderDocumentDto(
              id: 'doc-6',
              type: DocumentType.driversLicense,
              documentNumber: 'DL-EXPIRED-777',
              fileUrl: 'https://cdn.govolts.ng/docs/dl_expired.jpg',
              expiryDate: DateTime.now().subtract(const Duration(days: 15)),
              status: DocumentVerificationStatus.rejected,
            ),
          ],
          ratingAverage: 4.2,
          completedTrips: 45,
          appliedDate: '2026-08-01 14:00',
        ),
      ],
    ));
  
  }
}

extension SafetySosNotifierTestSeed on SafetySosNotifier {
  void seedForTest() {

    final now = DateTime.now();

    // Alert 1: Active In-Transit Distress (Passenger triggered SOS button)
    final alert1 = SosDistressAlert(
      id: 'SOS-001',
      incidentRef: 'SOS-2026-0041',
      bookingRef: 'BK-2026-9912',
      serviceType: 'Passenger Ride',
      triggeredBy: 'Passenger (In-App SOS Trigger)',
      victimName: 'Khadijah Cole',
      victimPhone: '+2348034567890',
      driverName: 'Ahmed Ibrahim',
      driverPhone: '+2348031234567',
      vehiclePlate: 'ABC-123XY',
      vehicleModel: 'Spiro Commuter EV',
      location: const LocationDto(
        latitude: 10.5180,
        longitude: 7.4380,
        address: 'Independence Way near Kaduna State Police Command HQ',
      ),
      speedKmH: 36.0,
      evBatteryPercent: 78,
      status: SosAlertStatus.activeDistress,
      triggeredAt: now.subtract(const Duration(minutes: 4)),
      audioRecordingUrl: 'https://cdn.govolts.ng/audio/sos-0041-live.aac',
      incidentNotes: [
        SosIncidentNote(
          id: 'NOTE-01',
          authorName: 'System Monitor',
          authorRole: 'Automated Telematics',
          note: 'Distress trigger detected from Passenger App. Audio recording stream initiated.',
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
      ],
    );

    // Alert 2: 112 / Police Dispatched (Crash sensor impact)
    final alert2 = SosDistressAlert(
      id: 'SOS-002',
      incidentRef: 'SOS-2026-0040',
      bookingRef: 'SCH-2026-0801',
      serviceType: 'School Run',
      triggeredBy: 'Impact Sensor (Crash Detection)',
      victimName: 'Zayd Cole (Minor Passenger)',
      victimPhone: '+2348034567890 (Mother)',
      driverName: 'Musa Bello',
      driverPhone: '+2348069876543',
      vehiclePlate: 'KD-456-EF',
      vehicleModel: 'Roam Air EV',
      location: const LocationDto(
        latitude: 10.4600,
        longitude: 7.4100,
        address: 'Nnamdi Azikiwe Expressway, Ungwan Rimi, Kaduna',
      ),
      speedKmH: 0.0,
      evBatteryPercent: 62,
      status: SosAlertStatus.dispatchedAuthorities,
      triggeredAt: now.subtract(const Duration(minutes: 25)),
      dispatchedAt: now.subtract(const Duration(minutes: 20)),
      safetyOfficerName: 'Safety Officer Amina',
      emergencyServicesContacted: const [
        'Lagos State 112 / 767 Emergency Center',
        'Kaduna State Emergency Management Agency (KADSEMA)',
        'Federal Road Safety Corps (FRSC Kaduna Command)',
      ],
      incidentNotes: [
        SosIncidentNote(
          id: 'NOTE-02',
          authorName: 'Safety Officer Amina',
          authorRole: 'Senior Safety Investigator',
          note: 'Escalated to FRSC Sector Command & KADSEMA. Ambulance and traffic patrol deployed.',
          createdAt: now.subtract(const Duration(minutes: 20)),
        ),
      ],
    );

    // Alert 3: Patrol En Route (Route deviation during Market Errand)
    final alert3 = SosDistressAlert(
      id: 'SOS-003',
      incidentRef: 'SOS-2026-0039',
      bookingRef: 'ERR-2026-0019',
      serviceType: 'Market Errand',
      triggeredBy: 'Route Deviation Geofence Alarm',
      victimName: 'Omotayo Kehinde',
      victimPhone: '+2348034567890',
      driverName: 'Fatima Abubakar',
      driverPhone: '+2348023456789',
      vehiclePlate: 'KN-789-GH',
      vehicleModel: 'Ampersand Cargo EV',
      location: const LocationDto(
        latitude: 10.4850,
        longitude: 7.4320,
        address: 'Barnawa Bypass, Kaduna',
      ),
      speedKmH: 15.0,
      evBatteryPercent: 84,
      status: SosAlertStatus.patrolEnRoute,
      triggeredAt: now.subtract(const Duration(minutes: 40)),
      dispatchedAt: now.subtract(const Duration(minutes: 32)),
      safetyOfficerName: 'Ops Agent Tunde',
      emergencyServicesContacted: const ['Go-Volts Rapid Patrol Unit 3 (EV Moped)'],
      incidentNotes: [
        SosIncidentNote(
          id: 'NOTE-03',
          authorName: 'Ops Agent Tunde',
          authorRole: 'Live Dispatcher',
          note: 'Go-Volts Mobile Patrol 3 en route. ETA 3 minutes to courier location.',
          createdAt: now.subtract(const Duration(minutes: 32)),
        ),
      ],
    );

    // Alert 4: Resolved Incident (Safe arrival confirmed)
    final alert4 = SosDistressAlert(
      id: 'SOS-004',
      incidentRef: 'SOS-2026-0038',
      bookingRef: 'BK-2026-9800',
      serviceType: 'Passenger Ride',
      triggeredBy: 'Passenger',
      victimName: 'Dr. Kabir Danladi',
      victimPhone: '+2348021112233',
      driverName: 'Zainab Danjuma',
      driverPhone: '+2348039871122',
      vehiclePlate: 'KD-882-AB',
      vehicleModel: 'Roam Commuter EV',
      location: const LocationDto(
        latitude: 10.5050,
        longitude: 7.4200,
        address: '14 Independence Way, Kaduna',
      ),
      speedKmH: 0.0,
      evBatteryPercent: 91,
      status: SosAlertStatus.resolvedSafe,
      triggeredAt: now.subtract(const Duration(hours: 3)),
      dispatchedAt: now.subtract(const Duration(hours: 2, minutes: 55)),
      resolvedAt: now.subtract(const Duration(hours: 2, minutes: 30)),
      safetyOfficerName: 'Safety Officer Amina',
      resolutionSummary: 'False alarm: Customer pocket-dialed SOS trigger. Verified safety over call.',
      incidentNotes: [
        SosIncidentNote(
          id: 'NOTE-04',
          authorName: 'Safety Officer Amina',
          authorRole: 'Senior Safety Investigator',
          note: 'Called customer; confirmed safe at destination with driver present.',
          createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        ),
      ],
    );

    updateStateForTesting(state.copyWith(
      alerts: [alert1, alert2, alert3, alert4],
    ));
  
  }
}

extension BatterySwapNotifierTestSeed on BatterySwapNotifier {
  void seedForTest() {

    List<BatteryBayModel> generateBays({
      required int chargedCount,
      required int chargingCount,
      int quarantinedCount = 0,
      String? quarantineReason,
    }) {
      final bays = <BatteryBayModel>[];
      var currentBay = 1;

      // Charged bays
      for (int i = 0; i < chargedCount; i++) {
        bays.add(BatteryBayModel(
          bayNumber: currentBay,
          batterySerial: 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
          socPercent: 92 + (i % 8),
          sohHealthPercent: 96,
          temperatureCelsius: 27.5,
          isCharging: false,
          isQuarantined: false,
          isLocked: true,
        ));
        currentBay++;
      }

      // Charging bays
      for (int i = 0; i < chargingCount; i++) {
        bays.add(BatteryBayModel(
          bayNumber: currentBay,
          batterySerial: 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
          socPercent: 35 + (i * 4),
          sohHealthPercent: 94,
          temperatureCelsius: 32.0,
          isCharging: true,
          isQuarantined: false,
          isLocked: true,
        ));
        currentBay++;
      }

      // Quarantined bays
      for (int i = 0; i < quarantinedCount; i++) {
        bays.add(BatteryBayModel(
          bayNumber: currentBay,
          batterySerial: 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
          socPercent: 48,
          sohHealthPercent: 68,
          temperatureCelsius: 44.5,
          isCharging: false,
          isQuarantined: true,
          quarantineReason: quarantineReason ?? 'Thermal Runaway Warning (>44°C cell temperature)',
          isLocked: true,
        ));
        currentBay++;
      }

      // Remaining empty or standby bays up to 24
      while (currentBay <= 24) {
        bays.add(BatteryBayModel(
          bayNumber: currentBay,
          batterySerial: 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
          socPercent: 90,
          sohHealthPercent: 95,
          temperatureCelsius: 28.0,
          isCharging: false,
          isQuarantined: false,
          isLocked: true,
        ));
        currentBay++;
      }

      return bays;
    }

    // Station 1: Victoria Island Central
    final stn1 = BatterySwapStationModel(
      id: 'STN-01',
      name: 'Victoria Island Central Swap Hub',
      address: 'Ahmadu Bello Way / Adeola Odeku, VI, Lagos',
      location: const LocationDto(
        latitude: 6.4281,
        longitude: 3.4219,
        address: 'Ahmadu Bello Way / Adeola Odeku, VI, Lagos',
      ),
      totalCabinetBays: 24,
      powerSource: 'Solar PV + Grid Active',
      temperatureCelsius: 28.2,
      dailySwapCount: 184,
      status: 'OPERATIONAL',
      bays: generateBays(
        chargedCount: 16,
        chargingCount: 7,
        quarantinedCount: 1,
        quarantineReason: 'Cell impedance mismatch flagged by BMS',
      ),
    );

    // Station 2: Lekki Phase 1
    final stn2 = BatterySwapStationModel(
      id: 'STN-02',
      name: 'Lekki Phase 1 Solar Swap Station',
      address: 'Admiralty Way, Lekki Phase 1, Lagos',
      location: const LocationDto(
        latitude: 6.4474,
        longitude: 3.4723,
        address: 'Admiralty Way, Lekki Phase 1, Lagos',
      ),
      totalCabinetBays: 24,
      powerSource: '100% Rooftop Solar + BESS',
      temperatureCelsius: 27.8,
      dailySwapCount: 122,
      status: 'OPERATIONAL',
      bays: generateBays(chargedCount: 18, chargingCount: 6),
    );

    // Station 3: Ikeja Commercial Hub
    final stn3 = BatterySwapStationModel(
      id: 'STN-03',
      name: 'Ikeja Commercial Fulfilment Hub',
      address: 'Allen Avenue, Ikeja, Lagos',
      location: const LocationDto(
        latitude: 6.6018,
        longitude: 3.3515,
        address: 'Allen Avenue, Ikeja, Lagos',
      ),
      totalCabinetBays: 24,
      powerSource: 'Grid Active + Diesel Standby',
      temperatureCelsius: 31.0,
      dailySwapCount: 210,
      status: 'OPERATIONAL',
      bays: generateBays(
        chargedCount: 14,
        chargingCount: 9,
        quarantinedCount: 1,
        quarantineReason: 'Thermal runaway threshold warning (>44°C cell temperature)',
      ),
    );

    // Station 4: Yaba Tech Corridor Hub
    final stn4 = BatterySwapStationModel(
      id: 'STN-04',
      name: 'Yaba Tech Corridor Hub',
      address: 'Herbert Macaulay Way, Yaba, Lagos',
      location: const LocationDto(
        latitude: 6.5095,
        longitude: 3.3711,
        address: 'Herbert Macaulay Way, Yaba, Lagos',
      ),
      totalCabinetBays: 24,
      powerSource: 'Solar PV + Grid Active',
      temperatureCelsius: 33.5,
      dailySwapCount: 95,
      status: 'HIGH_DEMAND',
      bays: generateBays(chargedCount: 6, chargingCount: 18),
    );

    updateStateForTesting(state.copyWith(
      stations: [stn1, stn2, stn3, stn4],
    ));
  
  }
}

extension ErrandOperationsNotifierTestSeed on ErrandOperationsNotifier {
  void seedForTest() {

    final now = DateTime.now();

    const riderAhmed = RiderDto(
      id: 'RIDER-001',
      profileId: 'PROF-001',
      fullName: 'Ahmed Ibrahim',
      phoneNumber: '+2348031234567',
      email: 'ahmed.ibrahim@govolts.ng',
      rating: 4.8,
      status: RiderStatus.assigned,
      vehiclePlate: 'ABC-123XY',
      vehicleModel: 'Spiro Commuter EV',
      batteryLevelPercent: 82,
    );

    const riderMusa = RiderDto(
      id: 'RIDER-002',
      profileId: 'PROF-002',
      fullName: 'Musa Bello',
      phoneNumber: '+2348069876543',
      email: 'musa.bello@govolts.ng',
      rating: 4.9,
      status: RiderStatus.assigned,
      vehiclePlate: 'KD-456-EF',
      vehicleModel: 'Roam Air EV',
      batteryLevelPercent: 64,
    );

    const riderFatima = RiderDto(
      id: 'RIDER-003',
      profileId: 'PROF-003',
      fullName: 'Fatima Abubakar',
      phoneNumber: '+2348023456789',
      email: 'fatima.abubakar@govolts.ng',
      rating: 4.95,
      status: RiderStatus.online,
      vehiclePlate: 'KN-789-GH',
      vehicleModel: 'Ampersand Cargo EV',
      batteryLevelPercent: 91,
    );

    // Errand 1: Flow A - Buy Items From a Shop (Shopping in progress, Kakuri Market)
    final errand1 = ErrandDto(
      id: 'ERRAND-001',
      referenceNumber: 'ERR-2026-0019',
      customerId: 'CUST-001',
      type: ErrandType.buyItems,
      status: ErrandStatus.shoppingInProgress,
      shop: const ShopDto(
        id: 'SHOP-01',
        name: 'Kakuri Main Market',
        address: 'Kakuri, Kaduna South, Kaduna',
        latitude: 10.4578,
        longitude: 7.4123,
      ),
      items: const [
        ShoppingItemDto(
          id: 'ITEM-01',
          name: 'Tomatoes',
          quantity: 2,
          unit: 'kg',
          estimatedPriceKobo: 400000,
          isPurchased: true,
          actualPriceKobo: 380000,
        ),
        ShoppingItemDto(
          id: 'ITEM-02',
          name: 'Onions',
          quantity: 1,
          unit: 'kg',
          estimatedPriceKobo: 150000,
          isPurchased: true,
          actualPriceKobo: 150000,
        ),
        ShoppingItemDto(
          id: 'ITEM-03',
          name: 'Rice (Mama\'s Pride)',
          quantity: 5,
          unit: 'kg',
          estimatedPriceKobo: 850000,
          isPurchased: false,
        ),
      ],
      preferences: const ShoppingPreferencesDto(
        substitutionPolicy: SubstitutionPolicy.contactFirst,
        additionalInstructions: 'Choose fresh items, check expiry date for packed goods.',
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.5105,
        longitude: 7.4165,
        address: '3, Ahmadu Bello Way, Bayero University, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Omotayo Kehinde',
        phoneNumber: '08034567890',
        deliveryAddress: '3, Ahmadu Bello Way, Bayero University, Kaduna',
        additionalAddressInfo: 'Call me when you are nearby.',
      ),
      deliveryTimeStr: 'As soon as possible',
      quote: const ErrandQuoteDto(
        id: 'Q-001',
        errandType: ErrandType.buyItems,
        estimatedItemsCostKobo: 1400000,
        serviceFeeKobo: 80000,
        deliveryFeeKobo: 120000,
        totalKobo: 1600000,
      ),
      assignedRider: riderAhmed,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(minutes: 42)),
    );

    // Errand 2: Flow B - Pick Up a Package (In Transit from Jumia Pickup Point)
    final errand2 = ErrandDto(
      id: 'ERRAND-002',
      referenceNumber: 'ERR-2026-0020',
      customerId: 'CUST-002',
      type: ErrandType.pickupPackage,
      status: ErrandStatus.outForDelivery,
      pickupDetails: const PackagePickupDetailsDto(
        pickupBusinessName: 'Jumia Pickup Point, Barnawa',
        address: 'Barnawa Shopping Mall, Kaduna',
        latitude: 10.4850,
        longitude: 7.4320,
        contactPerson: 'Mr. Sani Musa',
        phoneNumber: '0806 321 0987',
        referenceOrderNumber: 'JM-7788290',
      ),
      packageDetails: const ParcelDetailsDto(
        description: 'Electronics (Headset)',
        category: ParcelCategoryDto.electronics,
        sizeBand: ParcelSizeBandDto.medium,
        weightKg: 3.5,
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.5230,
        longitude: 7.4210,
        address: '3, De-West Plaza, Agwa, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Omotayo Kehinde',
        phoneNumber: '08034567890',
        deliveryAddress: '3, De-West Plaza, Agwa, Kaduna',
        additionalAddressInfo: 'Ring the bell and hand over to the reception.',
      ),
      quote: const ErrandQuoteDto(
        id: 'Q-002',
        errandType: ErrandType.pickupPackage,
        estimatedItemsCostKobo: 0,
        serviceFeeKobo: 70000,
        deliveryFeeKobo: 110000,
        totalKobo: 180000,
      ),
      assignedRider: riderAhmed,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(minutes: 65)),
    );

    // Errand 3: Flow C - Other Errand (Bayero University Certificate Collection, In Progress)
    final errand3 = ErrandDto(
      id: 'ERRAND-003',
      referenceNumber: 'ERR-2026-0021',
      customerId: 'CUST-003',
      type: ErrandType.otherErrand,
      status: ErrandStatus.inProgress,
      customErrandDetails: const CustomErrandDetailsDto(
        description: 'Please collect my documents from the university registrar\'s office and deliver them to my home.',
        category: 'Document Collection',
        urgency: ErrandUrgency.standard,
        taskLocation: LocationDto(
          latitude: 10.5105,
          longitude: 7.4165,
          address: 'Bayero University Registrar Office, Kaduna',
        ),
        contactPerson: 'Mrs. Amina Yusuf',
        phoneNumber: '0806 765 4321',
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.4600,
        longitude: 7.4100,
        address: 'My Home – Kakuri, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Mrs. Amina Yusuf',
        phoneNumber: '08067654321',
        deliveryAddress: 'My Home – Kakuri, Kaduna',
        additionalAddressInfo: 'Collect the sealed document and deliver to me.',
      ),
      quote: const ErrandQuoteDto(
        id: 'Q-003',
        errandType: ErrandType.otherErrand,
        estimatedItemsCostKobo: 0,
        serviceFeeKobo: 100000,
        deliveryFeeKobo: 120000,
        totalKobo: 220000,
      ),
      assignedRider: riderMusa,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(minutes: 90)),
    );

    // Errand 4: Flow A - Completed Errand with Receipt Reconciliation (Murtala Supermarket)
    final errand4 = ErrandDto(
      id: 'ERRAND-004',
      referenceNumber: 'ERR-2026-0018',
      customerId: 'CUST-004',
      type: ErrandType.buyItems,
      status: ErrandStatus.completed,
      shop: const ShopDto(
        id: 'SHOP-02',
        name: 'Murtala Supermarket',
        address: 'Murtala Square, Kaduna',
        latitude: 10.5180,
        longitude: 7.4380,
      ),
      items: const [
        ShoppingItemDto(
          id: 'ITEM-11',
          name: 'Golden Penny Sugar (500g)',
          quantity: 2,
          unit: 'packs',
          estimatedPriceKobo: 180000,
          isPurchased: true,
          actualPriceKobo: 170000,
        ),
        ShoppingItemDto(
          id: 'ITEM-12',
          name: 'Peak Evaporated Milk (158g)',
          quantity: 6,
          unit: 'tins',
          estimatedPriceKobo: 360000,
          isPurchased: true,
          actualPriceKobo: 340000,
        ),
      ],
      preferences: const ShoppingPreferencesDto(
        substitutionPolicy: SubstitutionPolicy.similarAlternative,
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.5050,
        longitude: 7.4200,
        address: '14 Independence Way, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Dr. Kabir Danladi',
        phoneNumber: '08021112233',
        deliveryAddress: '14 Independence Way, Kaduna',
      ),
      quote: const ErrandQuoteDto(
        id: 'Q-004',
        errandType: ErrandType.buyItems,
        estimatedItemsCostKobo: 540000,
        serviceFeeKobo: 80000,
        deliveryFeeKobo: 100000,
        totalKobo: 720000,
      ),
      assignedRider: riderFatima,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(hours: 3)),
      completedAt: now.subtract(const Duration(hours: 1)),
    );

    // Errand 5: Flow A - Disputed Errand (Items price difference exceedance)
    final errand5 = ErrandDto(
      id: 'ERRAND-005',
      referenceNumber: 'ERR-2026-0015',
      customerId: 'CUST-005',
      type: ErrandType.buyItems,
      status: ErrandStatus.issueReported,
      shop: const ShopDto(
        id: 'SHOP-03',
        name: 'De-West Stores',
        address: 'Agwa, Kaduna',
        latitude: 10.5210,
        longitude: 7.4230,
      ),
      items: const [
        ShoppingItemDto(
          id: 'ITEM-21',
          name: 'Cooking Oil (Kings 5L)',
          quantity: 1,
          unit: 'bottle',
          estimatedPriceKobo: 950000,
          isPurchased: true,
          actualPriceKobo: 1250000,
        ),
      ],
      preferences: const ShoppingPreferencesDto(
        substitutionPolicy: SubstitutionPolicy.doNotSubstitute,
        additionalInstructions: 'Only buy Kings brand, no other oil.',
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.5300,
        longitude: 7.4290,
        address: 'Plot 4, Constitution Road, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Grace Eze',
        phoneNumber: '08059998877',
        deliveryAddress: 'Plot 4, Constitution Road, Kaduna',
      ),
      quote: const ErrandQuoteDto(
        id: 'Q-005',
        errandType: ErrandType.buyItems,
        estimatedItemsCostKobo: 950000,
        serviceFeeKobo: 80000,
        deliveryFeeKobo: 110000,
        totalKobo: 1140000,
      ),
      assignedRider: riderAhmed,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(hours: 5)),
    );

    // Seed Reconciliations
    final reconciliations = [
      ErrandReconciliationModel(
        id: 'REC-001',
        errandId: 'ERRAND-004',
        referenceNumber: 'ERR-2026-0018',
        customerId: 'CUST-004',
        customerName: 'Dr. Kabir Danladi',
        shopperName: 'Fatima Abubakar',
        shopName: 'Murtala Supermarket',
        budgetedKobo: 540000,
        actualKobo: 510000,
        differenceKobo: -30000, // ₦300 refund to customer
        type: 'REFUND_CUSTOMER',
        status: 'PENDING',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      ErrandReconciliationModel(
        id: 'REC-002',
        errandId: 'ERRAND-005',
        referenceNumber: 'ERR-2026-0015',
        customerId: 'CUST-005',
        customerName: 'Grace Eze',
        shopperName: 'Ahmed Ibrahim',
        shopName: 'De-West Stores',
        budgetedKobo: 950000,
        actualKobo: 1250000,
        differenceKobo: 300000, // ₦3,000 extra charge disputed
        type: 'CHARGE_CUSTOMER',
        status: 'PENDING',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      // High value reconciliation (> ₦10,000 / 1,000,000 kobo) requiring Maker-Checker dual signoff
      ErrandReconciliationModel(
        id: 'REC-003',
        errandId: 'ERRAND-006',
        referenceNumber: 'ERR-2026-0010',
        customerId: 'CUST-006',
        customerName: 'Chief Emmanuel Okon',
        shopperName: 'Musa Bello',
        shopName: 'Kano Wholesale Grain Depot',
        budgetedKobo: 4500000,
        actualKobo: 3200000,
        differenceKobo: -1300000, // ₦13,000 refund -> requires Maker-Checker!
        type: 'REFUND_CUSTOMER',
        status: 'MAKER_APPROVED',
        makerStaffName: 'Ops Agent Tunde',
        makerNotes: 'Wholesale price discount verified with paper receipt photo.',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];

    // Seed Disputes
    final disputes = [
      const ErrandDisputeModel(
        id: 'DISP-001',
        errandId: 'ERRAND-005',
        referenceNumber: 'ERR-2026-0015',
        customerName: 'Grace Eze',
        customerPhone: '0805 999 8877',
        shopperName: 'Ahmed Ibrahim',
        shopperPhone: '+2348031234567',
        shopName: 'De-West Stores',
        disputeReason: 'Shopper purchased higher priced oil without contacting me first.',
        customerNote: 'My preference was strictly "Do not substitute". I budgeted ₦9,500 and the receipt is ₦12,500.',
        budgetedAmountKobo: 950000,
        actualReceiptKobo: 1250000,
        differenceKobo: 300000,
        status: 'PENDING_REVIEW',
      ),
    ];

    updateStateForTesting(state.copyWith(
      errands: [errand1, errand2, errand3, errand4, errand5],
      reconciliations: reconciliations,
      disputes: disputes,
    ));
  
  }
}

extension ScheduledOperationsNotifierTestSeed on ScheduledOperationsNotifier {
  void seedForTest() {

    final now = DateTime.now();

    const vettedDriverIbrahim = RiderDto(
      id: 'RIDER-001',
      profileId: 'PROF-001',
      fullName: 'Ahmed Ibrahim',
      phoneNumber: '+2348031234567',
      rating: 4.8,
      status: RiderStatus.assigned,
      vehiclePlate: 'ABC-123XY',
      vehicleModel: 'Spiro EV Sedan',
      batteryLevelPercent: 88,
    );

    const vettedDriverZainab = RiderDto(
      id: 'RIDER-004',
      profileId: 'PROF-004',
      fullName: 'Zainab Danjuma',
      phoneNumber: '+2348039871122',
      rating: 4.95,
      status: RiderStatus.online,
      vehiclePlate: 'KD-882-AB',
      vehicleModel: 'Roam Commuter EV',
      batteryLevelPercent: 92,
    );

    // Trips for Today's Manifest (Morning & Afternoon school runs)
    final trip1 = ScheduledTripDto(
      id: 'TRIP-SCH-001',
      tripReference: 'SCH-2026-0801',
      customerId: 'CUST-001',
      passengerProfileId: 'STU-001',
      passengerName: 'Zayd Cole',
      passengerPhone: '0803 456 7890 (Mother)',
      tripPurpose: TripPurpose.schoolRun,
      isSchoolRun: true,
      pickupLocation: const LocationDto(
        latitude: 10.4600,
        longitude: 7.4100,
        address: '12 Katuru Road, Ungwan Rimi, Kaduna',
      ),
      destinationLocation: const LocationDto(
        latitude: 10.5180,
        longitude: 7.4380,
        address: 'Kaduna Capital School, Malali, Kaduna',
      ),
      scheduledPickupAt: DateTime(now.year, now.month, now.day, 7, 30),
      scheduledDateStr: 'Today',
      scheduledTimeStr: '07:30 AM',
      status: ScheduledTripStatus.inProgress,
      assignedDriver: vettedDriverIbrahim,
      quoteId: 'Q-SCH-01',
      fareNgn: 1800.0,
      handoverCode: '482910',
      handoverStatus: HandoverStatus.codePending,
      specialInstructions: 'Hand child directly to Mrs. Bello (Grade 3 Class Teacher).',
    );

    final trip2 = ScheduledTripDto(
      id: 'TRIP-SCH-002',
      tripReference: 'SCH-2026-0802',
      customerId: 'CUST-002',
      passengerProfileId: 'STU-002',
      passengerName: 'Maryam Sani',
      passengerPhone: '0806 321 0987 (Father)',
      tripPurpose: TripPurpose.schoolRun,
      isSchoolRun: true,
      pickupLocation: const LocationDto(
        latitude: 10.5230,
        longitude: 7.4210,
        address: '4 Constitution Road, Kaduna',
      ),
      destinationLocation: const LocationDto(
        latitude: 10.5350,
        longitude: 7.4420,
        address: 'Essence International School, Kaduna',
      ),
      scheduledPickupAt: DateTime(now.year, now.month, now.day, 7, 45),
      scheduledDateStr: 'Today',
      scheduledTimeStr: '07:45 AM',
      status: ScheduledTripStatus.completed,
      assignedDriver: vettedDriverZainab,
      quoteId: 'Q-SCH-02',
      fareNgn: 2200.0,
      handoverCode: '591044',
      handoverStatus: HandoverStatus.verified,
      handoverConfirmedAt: now.subtract(const Duration(minutes: 30)),
      handoverRecipientName: 'Mr. John Adams (School Gate Marshal)',
    );

    final trip3 = ScheduledTripDto(
      id: 'TRIP-SCH-003',
      tripReference: 'SCH-2026-0803',
      customerId: 'CUST-001',
      passengerProfileId: 'STU-001',
      passengerName: 'Zayd Cole',
      passengerPhone: '0803 456 7890 (Mother)',
      tripPurpose: TripPurpose.schoolRun,
      isSchoolRun: true,
      pickupLocation: const LocationDto(
        latitude: 10.5180,
        longitude: 7.4380,
        address: 'Kaduna Capital School, Malali, Kaduna',
      ),
      destinationLocation: const LocationDto(
        latitude: 10.4600,
        longitude: 7.4100,
        address: '12 Katuru Road, Ungwan Rimi, Kaduna',
      ),
      scheduledPickupAt: DateTime(now.year, now.month, now.day, 14, 00),
      scheduledDateStr: 'Today',
      scheduledTimeStr: '02:00 PM',
      status: ScheduledTripStatus.scheduled,
      assignedDriver: vettedDriverIbrahim,
      quoteId: 'Q-SCH-03',
      fareNgn: 1800.0,
      handoverCode: '729184',
      handoverStatus: HandoverStatus.notStarted,
    );

    final trip4 = ScheduledTripDto(
      id: 'TRIP-SCH-004',
      tripReference: 'SCH-2026-0804',
      customerId: 'CUST-003',
      passengerProfileId: 'STU-003',
      passengerName: 'Aliyu Bello',
      passengerPhone: '0802 999 4433 (Guardian)',
      tripPurpose: TripPurpose.schoolRun,
      isSchoolRun: true,
      pickupLocation: const LocationDto(
        latitude: 10.5010,
        longitude: 7.4120,
        address: 'Barnawa GRA, Kaduna',
      ),
      destinationLocation: const LocationDto(
        latitude: 10.5180,
        longitude: 7.4380,
        address: 'Command Children School, Kaduna',
      ),
      scheduledPickupAt: DateTime(now.year, now.month, now.day, 14, 30),
      scheduledDateStr: 'Today',
      scheduledTimeStr: '02:30 PM',
      status: ScheduledTripStatus.driverAssigned,
      assignedDriver: vettedDriverZainab,
      quoteId: 'Q-SCH-04',
      fareNgn: 2000.0,
      handoverCode: '318902',
      handoverStatus: HandoverStatus.notStarted,
    );

    // Safekeeping Roster
    final safekeepingRoster = [
      const GuardianSafekeepingModel(
        passengerId: 'STU-001',
        passengerName: 'Zayd Cole',
        age: 8,
        schoolName: 'Kaduna Capital School',
        pickupAddress: '12 Katuru Road, Ungwan Rimi, Kaduna',
        dropoffAddress: 'Kaduna Capital School, Malali',
        morningTimeStr: '07:30 AM',
        afternoonTimeStr: '02:00 PM',
        singleUseOtp: '482910',
        otpStatus: HandoverStatus.codePending,
        specialCareNotes: 'Mild asthma; inhaler in front backpack pocket. Call mother on arrival.',
        authorizedContacts: [
          AuthorizedContactDto(
            id: 'CON-01',
            name: 'Khadijah Cole',
            relationship: 'Mother',
            phone: '0803 456 7890',
            isPrimary: true,
          ),
          AuthorizedContactDto(
            id: 'CON-02',
            name: 'Alexander Cole',
            relationship: 'Father',
            phone: '0802 333 4455',
          ),
          AuthorizedContactDto(
            id: 'CON-03',
            name: 'Mrs. Bello',
            relationship: 'Class Teacher',
            phone: '0805 111 9900',
          ),
        ],
      ),
      GuardianSafekeepingModel(
        passengerId: 'STU-002',
        passengerName: 'Maryam Sani',
        age: 6,
        schoolName: 'Essence International School',
        pickupAddress: '4 Constitution Road, Kaduna',
        dropoffAddress: 'Essence International School',
        morningTimeStr: '07:45 AM',
        afternoonTimeStr: '02:15 PM',
        singleUseOtp: '591044',
        otpStatus: HandoverStatus.verified,
        verifiedAt: now.subtract(const Duration(minutes: 30)),
        verifiedByStaffOrDriver: 'Zainab Danjuma (EV Chaperone)',
        authorizedContacts: const [
          AuthorizedContactDto(
            id: 'CON-04',
            name: 'Sani Musa',
            relationship: 'Father',
            phone: '0806 321 0987',
            isPrimary: true,
          ),
          AuthorizedContactDto(
            id: 'CON-05',
            name: 'Fatima Sani',
            relationship: 'Mother',
            phone: '0803 222 1199',
          ),
        ],
      ),
    ];

    // Calendar Exceptions
    final exceptions = [
      SchoolCalendarExceptionModel(
        id: 'EXC-001',
        title: 'Democracy Day Public Holiday',
        reason: 'Federal Government declared official public holiday across all schools.',
        startDate: now.add(const Duration(days: 4)),
        endDate: now.add(const Duration(days: 4)),
        affectedSchools: const ['All Kaduna Schools', 'All Kano Schools'],
        isFullDay: true,
        notifyParents: true,
        notifyDrivers: true,
        status: 'ACTIVE',
        createdBy: 'Admin Adeola (Ops Supervisor)',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      SchoolCalendarExceptionModel(
        id: 'EXC-002',
        title: 'Mid-Term Break (Term 1)',
        reason: 'Scheduled mid-term academic break.',
        startDate: now.add(const Duration(days: 12)),
        endDate: now.add(const Duration(days: 14)),
        affectedSchools: const ['Kaduna Capital School', 'Essence International School'],
        isFullDay: true,
        notifyParents: true,
        notifyDrivers: true,
        status: 'ACTIVE',
        createdBy: 'Admin Adeola (Ops Supervisor)',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    updateStateForTesting(state.copyWith(
      trips: [trip1, trip2, trip3, trip4],
      safekeepingRoster: safekeepingRoster,
      calendarExceptions: exceptions,
    ));
  
  }
}

extension SupportSafetyNotifierTestSeed on SupportSafetyNotifier {
  void seedForTest() {
    updateStateForTesting(
      state.copyWith(
        tickets: _seedTickets,
        incidents: _seedIncidents,
        faqs: _seedFaqs,
      ),
    );
  }
}

extension FinanceNotifierTestSeed on FinanceNotifier {
  void seedForTest() {
    updateStateForTesting(
      state.copyWith(
        summary: FinancialLedgerSummary(
          grossGmvKobo: BigInt.from(1425000000),
          netPlatformRevenueKobo: BigInt.from(285000000),
          totalRiderEarningsKobo: BigInt.from(1140000000),
          pendingRefundsKobo: BigInt.from(3850000),
          settlementDate: DateTime(2026, 10, 24),
        ),
        refunds: _seedRefunds,
        payoutBatches: _seedBatches,
      ),
    );
  }
}

extension PricingNotifierTestSeed on PricingNotifier {
  void seedForTest() {
    updateStateForTesting(
      state.copyWith(
        rules: _seedRules,
        zones: _seedZones,
      ),
    );
  }
}

extension IntegrationsNotifierTestSeed on IntegrationsNotifier {
  void seedForTest() {
    updateStateForTesting(
      state.copyWith(partners: _seedPartners),
    );
  }
}

extension AuditNotifierTestSeed on AuditNotifier {
  void seedForTest() {
    updateStateForTesting(
      state.copyWith(logs: _seedLogs),
    );
  }
}

extension PromotionsNotifierTestSeed on PromotionsNotifier {
  void seedForTest() {
    updateStateForTesting(
      state.copyWith(
        coupons: _seedCoupons,
        loyaltyConfig: LoyaltyConfigModel(
          pointsPerHundredNairaSpent: 5,
          koboPerPointRedeemed: BigInt.from(100),
          minRedemptionPoints: 200,
          totalCirculatingPoints: 148520,
        ),
        referralCampaign: ReferralCampaignModel(
          campaignId: 'lagos_launch_2026',
          campaignName: 'Lagos Clean Energy Referral Drive',
          referrerRewardKobo: BigInt.from(50000),
          refereeDiscountPercent: 15,
          totalConversions: 284,
          isActive: true,
        ),
      ),
    );
  }
}
