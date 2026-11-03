import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../application/scheduled_operations_notifier.dart';
import '../domain/scheduled_operations_models.dart';
import 'widgets/calendar_exception_modal.dart';
import 'widgets/chaperone_reassignment_modal.dart';
import 'widgets/handover_verification_modal.dart';

class ScheduledOperationsScreen extends ConsumerWidget {
  const ScheduledOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledOperationsNotifierProvider);
    final notifier = ref.read(scheduledOperationsNotifierProvider.notifier);
    final filteredTrips = state.filteredTrips;
    final filteredSafekeeping = state.filteredSafekeeping;

    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled Commute & School-Run Command Desk',
                        style: GVTypography.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supervise daily school manifests, authenticate single-use handover OTPs, and administer school calendar closures',
                        style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14241B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF263C2E)),
                  ),
                  child: Text(
                    '${state.todayManifestCount} Manifest Trips',
                    style: GVTypography.caption.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Action Feedback Banner
            if (state.actionMessage != null) ...[
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
                    const Icon(Icons.check_circle_outline,
                        color: GVColors.brandGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.actionMessage!,
                        style: GVTypography.bodySmall.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4 High-Contrast KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: GVSpacing.md,
                  runSpacing: GVSpacing.md,
                  children: [
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Today\'s Manifest',
                        value: state.todayManifestCount.toString(),
                        subtitle: 'Scheduled morning & afternoon runs',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Active School Runs',
                        value: state.activeSchoolRunsCount.toString(),
                        subtitle: 'Trips in progress or approaching',
                        icon: Icons.electric_rickshaw_outlined,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Handover OTP Pending',
                        value: state.pendingHandoverCount.toString(),
                        subtitle: 'Students awaiting school gate check',
                        icon: Icons.pin_outlined,
                        badgeLabel: state.pendingHandoverCount > 0 ? 'PENDING' : null,
                        accentColor: state.pendingHandoverCount > 0 ? Colors.amber : null,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Calendar Exceptions',
                        value: state.activeExceptionsCount.toString(),
                        subtitle: 'Active holidays or flood pauses',
                        icon: Icons.pause_circle_outline,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: GVSpacing.lg),

            // Tab Navigation Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF161F1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: Row(
                children: [
                  _tabButton(
                    title: 'Daily Run Manifests (${state.trips.length})',
                    isSelected: state.selectedTab == 'MANIFESTS',
                    onTap: () => notifier.setSelectedTab('MANIFESTS'),
                  ),
                  _tabButton(
                    title: 'Guardian Safekeeping & Handover OTP Desk (${state.safekeepingRoster.length})',
                    isSelected: state.selectedTab == 'SAFEKEEPING',
                    onTap: () => notifier.setSelectedTab('SAFEKEEPING'),
                  ),
                  _tabButton(
                    title: 'School Calendar Exceptions (${state.calendarExceptions.length})',
                    isSelected: state.selectedTab == 'EXCEPTIONS',
                    onTap: () => notifier.setSelectedTab('EXCEPTIONS'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Tab View Content
            if (state.selectedTab == 'MANIFESTS') ...[
              _buildManifestsTab(context, state, notifier, filteredTrips),
            ] else if (state.selectedTab == 'SAFEKEEPING') ...[
              _buildSafekeepingTab(context, state, notifier, filteredSafekeeping),
            ] else ...[
              _buildExceptionsTab(context, state, notifier),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF143021) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? GVColors.brandGreen : Colors.transparent,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GVTypography.caption.copyWith(
              color: isSelected ? GVColors.brandGreen : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManifestsTab(
    BuildContext context,
    ScheduledOperationsState state,
    ScheduledOperationsNotifier notifier,
    List<ScheduledTripDto> trips,
  ) {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(GVSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFF161F1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF263C2E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: notifier.search,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by trip ref (e.g. SCH-2026), student name, chaperone, or school...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF14241B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF263C2E)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Manifest Window:',
                    style: GVTypography.caption.copyWith(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('All Runs'),
                    selected: state.selectedManifestTime == 'ALL',
                    onSelected: (_) => notifier.setManifestFilter('ALL'),
                    selectedColor: const Color(0xFF143021),
                    backgroundColor: const Color(0xFF14241B),
                    labelStyle: TextStyle(
                      color: state.selectedManifestTime == 'ALL' ? GVColors.brandGreen : Colors.white70,
                      fontWeight: state.selectedManifestTime == 'ALL' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Morning Run (06:30 - 08:30)'),
                    selected: state.selectedManifestTime == 'MORNING',
                    onSelected: (_) => notifier.setManifestFilter('MORNING'),
                    selectedColor: const Color(0xFF143021),
                    backgroundColor: const Color(0xFF14241B),
                    labelStyle: TextStyle(
                      color: state.selectedManifestTime == 'MORNING' ? GVColors.brandGreen : Colors.white70,
                      fontWeight: state.selectedManifestTime == 'MORNING' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Afternoon Pickup (13:30 - 16:00)'),
                    selected: state.selectedManifestTime == 'AFTERNOON',
                    onSelected: (_) => notifier.setManifestFilter('AFTERNOON'),
                    selectedColor: const Color(0xFF143021),
                    backgroundColor: const Color(0xFF14241B),
                    labelStyle: TextStyle(
                      color: state.selectedManifestTime == 'AFTERNOON' ? GVColors.brandGreen : Colors.white70,
                      fontWeight: state.selectedManifestTime == 'AFTERNOON' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: GVSpacing.lg),

        // Trips Table
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161F1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF263C2E)),
          ),
          child: trips.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(GVSpacing.xxl),
                  child: Center(
                    child: Text(
                      'No manifest runs found matching current filter.',
                      style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
                    ),
                  ),
                )
              : Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.0), // Ref & Time
                    1: FlexColumnWidth(2.2), // Student & Parent
                    2: FlexColumnWidth(2.4), // School Destination
                    3: FlexColumnWidth(2.0), // Vetted Chaperone
                    4: FlexColumnWidth(1.4), // Fare
                    5: FlexColumnWidth(1.8), // Status
                    6: FlexColumnWidth(1.6), // Action
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF263C2E))),
                        color: Color(0xFF14241B),
                      ),
                      children: [
                        _headerCell('TRIP REF & TIME'),
                        _headerCell('STUDENT PASSENGER'),
                        _headerCell('DESTINATION / SCHOOL'),
                        _headerCell('VETTED CHAPERONE'),
                        _headerCell('FARE'),
                        _headerCell('STATUS'),
                        _headerCell('ACTION'),
                      ],
                    ),
                    ...trips.map((trip) => TableRow(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF263C2E))),
                          ),
                          children: [
                            // Ref & Time
                            _dataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.tripReference,
                                    style: GVTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    trip.scheduledTimeStr,
                                    style: GVTypography.caption.copyWith(
                                      color: GVColors.brandGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Student
                            _dataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.passengerName,
                                    style: GVTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    trip.passengerPhone,
                                    style: GVTypography.caption.copyWith(
                                      color: Colors.white60,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Destination
                            _dataCell(
                              Text(
                                trip.destinationLocation.address,
                                style: GVTypography.caption.copyWith(color: Colors.white),
                              ),
                            ),
                            // Chaperone
                            _dataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.assignedDriver?.fullName ?? 'Unassigned',
                                    style: GVTypography.bodySmall.copyWith(
                                      color: trip.assignedDriver != null
                                          ? Colors.white
                                          : Colors.amber,
                                    ),
                                  ),
                                    if (trip.assignedDriver != null)
                                      Text(
                                        '${trip.assignedDriver!.vehiclePlate} (${trip.assignedDriver!.batteryLevelPercent}% SoC)',
                                        style: GVTypography.caption.copyWith(
                                          color: GVColors.brandGreen,
                                          fontSize: 10,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            // Fare
                            _dataCell(
                              Text(
                                '₦${trip.fareNgn.toStringAsFixed(0)}',
                                style: GVTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Status
                            _dataCell(
                              _tripStatusBadge(trip.status),
                            ),
                            // Action
                            _dataCell(
                              OutlinedButton(
                                key: Key('reassign_trip_${trip.id}'),
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (_) => ChaperoneReassignmentModal(trip: trip),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: GVColors.brandGreen,
                                  side: const BorderSide(color: Color(0xFF263C2E)),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                child: const Text('Reassign', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSafekeepingTab(
    BuildContext context,
    ScheduledOperationsState state,
    ScheduledOperationsNotifier notifier,
    List<GuardianSafekeepingModel> roster,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(GVSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFF161F1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF263C2E)),
          ),
          child: TextField(
            onChanged: notifier.search,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by student name, school, or authorized guardian...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF14241B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF263C2E)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: GVSpacing.lg),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161F1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF263C2E)),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2.2), // Student Profile
              1: FlexColumnWidth(2.2), // School & Schedule
              2: FlexColumnWidth(2.6), // Authorized Contacts
              3: FlexColumnWidth(1.8), // Single-Use OTP Status
              4: FlexColumnWidth(1.8), // Action
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF263C2E))),
                  color: Color(0xFF14241B),
                ),
                children: [
                  _headerCell('STUDENT PASSENGER'),
                  _headerCell('SCHOOL & RUN TIMES'),
                  _headerCell('AUTHORIZED GUARDIANS'),
                  _headerCell('HANDOVER STATUS'),
                  _headerCell('GATE VERIFICATION'),
                ],
              ),
              ...roster.map((student) => TableRow(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF263C2E))),
                    ),
                    children: [
                      // Student Profile
                      _dataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.passengerName,
                              style: GVTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Age ${student.age} • ${student.pickupAddress}',
                              style: GVTypography.caption.copyWith(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // School & Times
                      _dataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.schoolName,
                              style: GVTypography.bodySmall.copyWith(
                                color: GVColors.brandGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'AM: ${student.morningTimeStr} • PM: ${student.afternoonTimeStr}',
                              style: GVTypography.caption.copyWith(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // Authorized Guardians
                      _dataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: student.authorizedContacts.map((c) {
                            return Text(
                              '${c.name} (${c.relationship})',
                              style: GVTypography.caption.copyWith(
                                color: c.isPrimary ? Colors.white : Colors.white60,
                                fontWeight: c.isPrimary ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 11,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // Handover Status
                      _dataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: student.isVerified
                                ? const Color(0xFF143021)
                                : const Color(0xFF2B1D0E),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: student.isVerified ? GVColors.brandGreen : Colors.amber,
                            ),
                          ),
                          child: Text(
                            student.isVerified ? 'VERIFIED' : 'OTP PENDING',
                            style: TextStyle(
                              color: student.isVerified ? GVColors.brandGreen : Colors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Action
                      _dataCell(
                        ElevatedButton.icon(
                          key: Key('verify_handover_${student.passengerId}'),
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (_) => HandoverVerificationModal(safekeeping: student),
                            );
                          },
                          icon: Icon(
                            student.isVerified ? Icons.visibility : Icons.check,
                            size: 14,
                          ),
                          label: Text(
                            student.isVerified ? 'Inspect' : 'Verify OTP',
                            style: const TextStyle(fontSize: 11),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: student.isVerified
                                ? const Color(0xFF263C2E)
                                : GVColors.brandGreen,
                            foregroundColor: student.isVerified ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExceptionsTab(
    BuildContext context,
    ScheduledOperationsState state,
    ScheduledOperationsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Button Card
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'School Holidays, State Directives & Weather Hazard Pauses',
              style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
            ),
            ElevatedButton.icon(
              key: const Key('add_calendar_exception_btn'),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const CalendarExceptionModal(),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Calendar Exception'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GVColors.brandGreen,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: GVSpacing.md),

        // Exceptions Cards
        ...state.calendarExceptions.map((exc) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF161F1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: exc.isActive ? GVColors.brandGreen : const Color(0xFF263C2E),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  exc.isActive ? Icons.event_available : Icons.event_busy,
                  color: exc.isActive ? GVColors.brandGreen : Colors.white38,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            exc.title,
                            style: GVTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: exc.isActive ? const Color(0xFF143021) : const Color(0xFF263C2E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              exc.status,
                              style: TextStyle(
                                color: exc.isActive ? GVColors.brandGreen : Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exc.reason,
                        style: GVTypography.caption.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Schools: ${exc.affectedSchools.join(', ')} • Created by: ${exc.createdBy}',
                        style: GVTypography.caption.copyWith(
                          color: GVColors.brandGreen,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  key: Key('toggle_exception_${exc.id}'),
                  onPressed: () => notifier.toggleCalendarExceptionStatus(exc.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: exc.isActive ? Colors.redAccent : GVColors.brandGreen,
                    side: BorderSide(
                      color: exc.isActive ? Colors.redAccent : GVColors.brandGreen,
                    ),
                  ),
                  child: Text(exc.isActive ? 'Cancel Pause' : 'Reactivate'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _tripStatusBadge(ScheduledTripStatus status) {
    Color color;
    switch (status) {
      case ScheduledTripStatus.completed:
        color = GVColors.brandGreen;
        break;
      case ScheduledTripStatus.inProgress:
      case ScheduledTripStatus.driverAssigned:
      case ScheduledTripStatus.driverApproaching:
        color = Colors.amber;
        break;
      case ScheduledTripStatus.failed:
      case ScheduledTripStatus.cancelled:
        color = Colors.redAccent;
        break;
      default:
        color = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _headerCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        title,
        style: GVTypography.caption.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: child,
    );
  }
}
