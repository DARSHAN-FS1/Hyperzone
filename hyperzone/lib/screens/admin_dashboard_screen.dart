import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/admin_api_service.dart';
import 'admin_tournament_participants_screen.dart';


const Color kBackgroundColor = Color(0xFF020617);
const Color kCardColor = Color(0xFF0F172A);
const Color kPrimaryBlue = Color(0xFF6366F1);
const Color kAccentGreen = Color(0xFF22C55E);
const Color kAlertRed = Color(0xFFFB7185);
const Color kBorderColor = Color(0xFF1F2933);
const Color kSubtextColor = Color(0xFF9CA3AF);

String cleanDateText(String raw) {
  if (raw.isEmpty) return '';
  final asciiOnly = raw.replaceAll(RegExp(r'[^\x00-\x7F]+'), ' ');
  return asciiOnly.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class AdminDashboardScreen extends StatefulWidget {
  final AdminApiService api;
  final String? authToken;

  const AdminDashboardScreen({
    super.key,
    required this.api,
    this.authToken,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  DashboardSummary? _summary;
  List<AdminTournament> _pendingTournaments = [];
  List<AdminTournament> _officialTournaments = [];
  List<Complaint> _pendingComplaints = [];

  bool _isLoading = true;
  bool _usingDemoData = false;
  String? _errorBanner;
  int _selectedSidebarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _applyDemoData() {
    _summary = DashboardSummary(
      totalUsers: 9500,
      activeUsers: 850,
      totalTournaments: 55,
      activeTournaments: 5,
      pendingTournaments: 2,
      totalPrizePool: 5377000,
      pendingComplaints: 7,
    );

    _pendingTournaments = [
      AdminTournament(
        id: '1',
        name: 'BGMI Clash',
        game: 'BGMI',
        status: 'PENDING',
        createdBy: 'HostUser1',
        date: '08 Dec 2025',
        slots: 64,
        prizePool: 5000,
        isOfficial: false,
        entryFee: 50,
      ),
      AdminTournament(
        id: '2',
        name: 'Valorant Open',
        game: 'Valorant',
        status: 'PENDING',
        createdBy: 'HostUser2',
        date: '09 Dec 2025',
        slots: 32,
        prizePool: 10000,
        isOfficial: false,
        entryFee: 100,
      ),
    ];

    _officialTournaments = [
      AdminTournament(
        id: '3',
        name: 'Hyperzone Elite Clash',
        game: 'BGMI',
        status: 'LIVE',
        createdBy: 'Admin',
        date: '08 Dec 2025',
        slots: 64,
        prizePool: 250000,
        isOfficial: true,
        entryFee: 0,
      ),
      AdminTournament(
        id: '4',
        name: 'Hyperzone Grand Masters',
        game: 'Valorant',
        status: 'SCHEDULED',
        createdBy: 'Admin',
        date: '15 Dec 2025',
        slots: 32,
        prizePool: 500000,
        isOfficial: true,
        entryFee: 0,
      ),
    ];

    _pendingComplaints = [
      Complaint(
        id: 'C1',
        user: 'CheaterHunter',
        type: 'Cheating Report',
        status: 'OPEN',
        date: '2025-12-05',
      ),
      Complaint(
        id: 'C2',
        user: 'WalletUser',
        type: 'Withdrawal Issue',
        status: 'OPEN',
        date: '2025-12-04',
      ),
    ];

    _usingDemoData = true;
    _errorBanner = null;
  }

  Future<void> _loadAll() async {
  setState(() {
    _isLoading = true;
    _errorBanner = null;
  });

  try {
    final token = widget.authToken;
    final summaryF = widget.api.fetchSummary(token: token);
    final pendingF = widget.api.fetchPendingTournaments(token: token);
    final officialF = widget.api.fetchOfficialTournaments(token: token);
    final complaintsF = widget.api.fetchPendingComplaints(token: token);

    final results = await Future.wait([
      summaryF,
      pendingF,
      officialF,
      complaintsF,
    ]);

    _summary = results[0] as DashboardSummary;
    _pendingTournaments = results[1] as List<AdminTournament>;
    _officialTournaments = results[2] as List<AdminTournament>;
    _pendingComplaints = results[3] as List<Complaint>;
  } catch (e) {
    debugPrint('Admin dashboard API error: $e');
    _errorBanner = 'Failed to load latest data from server.';
   
  }

  if (!mounted) return;
  setState(() {
    _isLoading = false;
  });
}


  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? kAlertRed : kPrimaryBlue,
      ),
    );
  }

  Future<void> _approveTournament(AdminTournament t) async {
    if (widget.api.isDemoMode) {
      _showSnack('Demo: approved "${t.name}"');
      return;
    }

    try {
      await widget.api.approveTournament(t.id, token: widget.authToken);
      _showSnack('Tournament approved');
      await _loadAll();
    } catch (e) {
      _showSnack('Failed to approve: $e', error: true);
    }
  }

  Future<void> _rejectTournament(AdminTournament t) async {
    if (widget.api.isDemoMode) {
      _showSnack('Demo: rejected "${t.name}"');
      return;
    }

    try {
      await widget.api.rejectTournament(t.id, token: widget.authToken);
      _showSnack('Tournament rejected');
      await _loadAll();
    } catch (e) {
      _showSnack('Failed to reject: $e', error: true);
    }
  }

  Future<void> _startOfficial(AdminTournament t) async {
    if (widget.api.isDemoMode) {
      _showSnack('Demo: started "${t.name}"');
      return;
    }

    try {
      await widget.api.startTournament(t.id, token: widget.authToken);
      _showSnack('Tournament started');
      await _loadAll();
    } catch (e) {
      _showSnack('Failed to start: $e', error: true);
    }
  }

  Future<void> _completeOfficial(AdminTournament t) async {
    if (widget.api.isDemoMode) {
      _showSnack('Demo: completed "${t.name}"');
      return;
    }

    try {
      await widget.api.completeTournament(t.id, token: widget.authToken);
      _showSnack('Tournament completed');
      await _loadAll();
    } catch (e) {
      _showSnack('Failed to complete: $e', error: true);
    }
  }

  Future<void> _resolveComplaint(Complaint c) async {
    if (widget.api.isDemoMode) {
      _showSnack('Demo: marked complaint ${c.id} resolved');
      return;
    }

    try {
      await widget.api.markComplaintResolved(c.id, token: widget.authToken);
      _showSnack('Complaint marked resolved');
      await _loadAll();
    } catch (e) {
      _showSnack('Failed to resolve complaint: $e', error: true);
    }
  }

  Widget _dialogInput({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: kSubtextColor, fontSize: 12),
          filled: true,
          fillColor: kBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryBlue),
          ),
          isDense: true,
        ),
      ),
    );
  }

  Future<void> _openCreateTournamentDialog() async {
    final nameController = TextEditingController();
    final gameController = TextEditingController(text: 'BGMI');
    final prizeController = TextEditingController(text: '50000');
    final slotsController = TextEditingController(text: '64');
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 3));

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: kCardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Host Official Tournament',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogInput(
                  label: 'Tournament name',
                  controller: nameController,
                ),
                _dialogInput(
                  label: 'Game',
                  controller: gameController,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogInput(
                        label: 'Slots',
                        controller: slotsController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogInput(
                        label: 'Prize pool (₹)',
                        controller: prizeController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? now,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: kPrimaryBlue),
                    label: Text(
                      selectedDate == null
                          ? 'Pick start date'
                          : DateFormat('dd/MM/yyyy \'at\' hh:mm a \'IST\'')
                              .format(
                              DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                21,
                                0,
                              ),
                            ),
                      style: const TextStyle(color: kSubtextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: kSubtextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    selectedDate == null) {
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (widget.api.isDemoMode) {
        _showSnack('Demo: official tournament "${nameController.text}" created');
        return;
      }

      try {
        final formattedDate =
            DateFormat('dd/MM/yyyy \'at\' hh:mm a \'IST\'').format(
          DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            21,
            0,
          ),
        );

        await widget.api.createOfficialTournament(
          name: nameController.text.trim(),
          game: gameController.text.trim(),
          slots: int.tryParse(slotsController.text.trim()) ?? 64,
          prizePool: double.tryParse(prizeController.text.trim()) ?? 50000.0,
          dateText: formattedDate,
        );

        _showSnack('Official tournament created');
        await _loadAll();
      } catch (e) {
        _showSnack('Failed to create: $e', error: true);
      }
    }
  }

  Widget _buildSidebar() {
    final menuItems = [
      ('Dashboard', Icons.dashboard_rounded),
      ('Host Requests', Icons.campaign_rounded),
      ('Official Tournaments', Icons.emoji_events_rounded),
      ('Complaints', Icons.help_center_rounded),
    ];

    return Container(
      width: 240,
      color: kCardColor,
      child: Column(
        children: [
          const SizedBox(height: 18),
          const Text(
            'Hyperzone Admin',
            style: TextStyle(
              color: kPrimaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.flash_on_rounded,
                    size: 14, color: kAccentGreen),
                SizedBox(width: 6),
                Text(
                  'ADMIN ONLINE',
                  style: TextStyle(
                    color: kAccentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: kBorderColor, height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _SidebarItem(
                  title: item.$1,
                  icon: item.$2,
                  selected: _selectedSidebarIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedSidebarIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: kCardColor,
        border: const Border(
          bottom: BorderSide(color: kBorderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Control Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'ADMIN PANEL',
                  style: TextStyle(
                    color: kSubtextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_usingDemoData) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'DEMO DATA',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Row(
            children: [
              if (_errorBanner != null) ...[
                Text(
                  _errorBanner!,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              IconButton(
                tooltip: 'Refresh',
                onPressed: _loadAll,
                icon: const Icon(Icons.refresh_rounded,
                    color: kSubtextColor),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_rounded,
                        size: 14, color: kAccentGreen),
                    SizedBox(width: 6),
                    Text(
                      'Super Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout_rounded, color: kAlertRed),
                label: const Text('Logout',
                    style: TextStyle(color: kAlertRed)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    final List<Complaint> dummyComplaints = [
      Complaint(
        id: 'C101',
        user: 'Drashan ',
        type:
            'Reported that prize money for yesterday’s finals is still not credited to his wallet.',
        status: 'OPEN',
        date: '2025-12-06',
      ),
      Complaint(
        id: 'C102',
        user: 'Vaibhav More',
        type:
            'Raised concern about opponent using possible cheats in semi-final lobby.',
        status: 'OPEN',
        date: '2025-12-07',
      ),
    ];

    final bool hasRealComplaints = _pendingComplaints.isNotEmpty;
    final List<Complaint> complaintsToShow =
        hasRealComplaints ? _pendingComplaints : dummyComplaints;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monitor players, tournaments and issues in real time.',
            style: TextStyle(
              color: kSubtextColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          _SummaryRow(summary: _summary),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 1200;

              final hostCard = _HostRequestsCard(
                pending: _pendingTournaments,
                onApprove: _approveTournament,
                onReject: _rejectTournament,
                showTitle: true,
              );

              final complaintsCard = _ComplaintsCard(
                complaints: complaintsToShow,
                onResolve: hasRealComplaints
                    ? _resolveComplaint
                    : (c) => _showSnack(
                        'Demo: complaint ${c.id} marked resolved (UI only).'),
                showTitle: true,
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: hostCard),
                    const SizedBox(width: 24),
                    Expanded(child: complaintsCard),
                  ],
                );
              } else {
                return Column(
                  children: [
                    hostCard,
                    const SizedBox(height: 24),
                    complaintsCard,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _OfficialTournamentsCard(
            tournaments: _officialTournaments,
            onStart: _startOfficial,
            onComplete: _completeOfficial,
            onCreate: _openCreateTournamentDialog,
            showTitle: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHostRequestsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _HostRequestsCard(
        pending: _pendingTournaments,
        onApprove: _approveTournament,
        onReject: _rejectTournament,
        showTitle: true,
      ),
    );
  }

  Widget _buildOfficialView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _OfficialTournamentsCard(
        tournaments: _officialTournaments,
        onStart: _startOfficial,
        onComplete: _completeOfficial,
        onCreate: _openCreateTournamentDialog,
        showTitle: true,
      ),
    );
  }

  Widget _buildComplaintsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _ComplaintsCard(
        complaints: _pendingComplaints,
        onResolve: _resolveComplaint,
        showTitle: true,
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
        ),
      );
    }

    switch (_selectedSidebarIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return _buildHostRequestsView();
      case 2:
        return _buildOfficialView();
      case 3:
        return _buildComplaintsView();
      default:
        return _buildDashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? kPrimaryBlue.withOpacity(0.2)
                : (_hover ? kCardColor.withOpacity(0.9) : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: active ? kPrimaryBlue : kSubtextColor,
              ),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: TextStyle(
                  color: active ? Colors.white : kSubtextColor,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final DashboardSummary? summary;

  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SummaryCard(
            label: 'Registered Players',
            value: '${s?.totalUsers ?? 0}',
            subtitle: 'Total users on platform',
            icon: Icons.people_alt_rounded,
            gradientColors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
          ),
          _SummaryCard(
            label: 'Active Now',
            value: '${s?.activeUsers ?? 0}',
            subtitle: 'Currently online',
            icon: Icons.bolt_rounded,
            gradientColors: const [Color(0xFFF97316), Color(0xFFEA580C)],
          ),
          _SummaryCard(
            label: 'Live Tournaments',
            value: '${s?.activeTournaments ?? 0}',
            subtitle: 'Running right now',
            icon: Icons.live_tv_rounded,
            gradientColors: const [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
          ),
          _SummaryCard(
            label: 'Pending Approvals',
            value: '${s?.pendingTournaments ?? 0}',
            subtitle: 'Host requests',
            icon: Icons.pending_actions_rounded,
            gradientColors: const [Color(0xFFEAB308), Color(0xFFCA8A04)],
          ),
          _SummaryCard(
            label: 'New Complaints',
            value: '${s?.pendingComplaints ?? 0}',
            subtitle: 'Needs attention',
            icon: Icons.warning_rounded,
            gradientColors: const [kAlertRed, Color(0xFF991B1B)],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatefulWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(right: 16),
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hover
                ? widget.gradientColors.last.withOpacity(0.7)
                : Colors.white.withOpacity(0.04),
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 22,
                    spreadRadius: -12,
                    offset: const Offset(0, 20),
                  )
                ]
              : [],
        ),
        transform:
            _hover ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label,
                      style: const TextStyle(
                          color: kSubtextColor, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    widget.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostRequestsCard extends StatelessWidget {
  final List<AdminTournament> pending;
  final ValueChanged<AdminTournament> onApprove;
  final ValueChanged<AdminTournament> onReject;
  final bool showTitle;

  const _HostRequestsCard({
    required this.pending,
    required this.onApprove,
    required this.onReject,
    this.showTitle = true,
  });

  BoxDecoration get _boxDecoration => BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 26,
            spreadRadius: -14,
            offset: const Offset(0, 22),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          if (showTitle)
            const _SectionHeader(
              title: 'Host Requests',
              subtitle: 'Tournaments submitted by community hosts.',
            ),
          const Divider(color: kBorderColor, height: 1),
          if (pending.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No pending requests.',
                style: TextStyle(color: kSubtextColor, fontSize: 13),
              ),
            )
          else
            ListView.builder(
              itemCount: pending.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final t = pending[index];
                return _PendingTournamentTile(
                  tournament: t,
                  onApprove: () => onApprove(t),
                  onReject: () => onReject(t),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _OfficialTournamentsCard extends StatelessWidget {
  final List<AdminTournament> tournaments;
  final ValueChanged<AdminTournament> onStart;
  final ValueChanged<AdminTournament> onComplete;
  final VoidCallback onCreate;
  final bool showTitle;

  const _OfficialTournamentsCard({
    required this.tournaments,
    required this.onStart,
    required this.onComplete,
    required this.onCreate,
    this.showTitle = false,
  });

  BoxDecoration get _boxDecoration => BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 26,
            spreadRadius: -14,
            offset: const Offset(0, 22),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          _SectionHeader(
            title: 'Hyperzone Official Tournaments',
            subtitle: showTitle ? 'Create and control official events.' : '',
            trailing: TextButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded,
                  size: 18, color: kPrimaryBlue),
              label: const Text(
                'Host New',
                style: TextStyle(
                  color: kPrimaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Divider(color: kBorderColor, height: 1),
          if (tournaments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No official tournaments yet.',
                style: TextStyle(color: kSubtextColor, fontSize: 13),
              ),
            )
          else
            ListView.builder(
              itemCount: tournaments.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final t = tournaments[index];
                return _AdminTournamentTile(
                  tournament: t,
                  onStart: t.status.toUpperCase() == 'SCHEDULED'
                      ? () => onStart(t)
                      : null,
                  onComplete: t.status.toUpperCase() == 'LIVE'
                      ? () => onComplete(t)
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ComplaintsCard extends StatelessWidget {
  final List<Complaint> complaints;
  final ValueChanged<Complaint> onResolve;
  final bool showTitle;

  const _ComplaintsCard({
    required this.complaints,
    required this.onResolve,
    this.showTitle = false,
  });

  BoxDecoration get _boxDecoration => BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 26,
            spreadRadius: -14,
            offset: const Offset(0, 22),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          if (showTitle)
            const _SectionHeader(
              title: 'User Complaint Center',
              subtitle: 'Review and resolve player reports.',
            ),
          const Divider(color: kBorderColor, height: 1),
          if (complaints.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No open complaints.',
                style: TextStyle(color: kSubtextColor, fontSize: 13),
              ),
            )
          else
            ListView.builder(
              itemCount: complaints.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final c = complaints[index];
                return _ComplaintTile(
                  complaint: c,
                  onResolve: () => onResolve(c),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: kSubtextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _PendingTournamentTile extends StatefulWidget {
  final AdminTournament tournament;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingTournamentTile({
    required this.tournament,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_PendingTournamentTile> createState() =>
      _PendingTournamentTileState();
}

class _PendingTournamentTileState extends State<_PendingTournamentTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _hover ? kCardColor.withOpacity(0.9) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [kPrimaryBlue, Color(0xFFEC4899)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.game} • Slots ${t.slots}',
                    style: const TextStyle(
                      color: kSubtextColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hosted by ${t.createdBy}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prize: ₹${t.prizePool.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Entry fee: ₹${t.entryFee}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cleanDateText(t.date),
                    style: const TextStyle(
                      color: kSubtextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Reject',
                  onPressed: widget.onReject,
                  icon: const Icon(Icons.close_rounded,
                      color: kAlertRed, size: 22),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Approve',
                  onPressed: widget.onApprove,
                  icon: const Icon(Icons.check_rounded,
                      color: kAccentGreen, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTournamentTile extends StatelessWidget {
  final AdminTournament tournament;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  const _AdminTournamentTile({
    required this.tournament,
    this.onStart,
    this.onComplete,
  });

  Color get _statusColor {
    switch (tournament.status.toUpperCase()) {
      case 'LIVE':
        return kAccentGreen;
      case 'SCHEDULED':
        return const Color(0xFFFACC15);
      case 'COMPLETED':
        return const Color(0xFF38BDF8);
      case 'CANCELLED':
        return kAlertRed;
      default:
        return kSubtextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final statusUpper = t.status.toUpperCase();

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                if (t.isOfficial)
                  Container(
                    width: 8,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [kPrimaryBlue, Color(0xFFEC4899)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${t.game} • Slots ${t.slots}',
                        style: const TextStyle(
                          color: kSubtextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prize: ₹${t.prizePool.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Entry fee: ₹${t.entryFee}',
                  style: const TextStyle(
                    color: kSubtextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanDateText(t.date),
                  style: const TextStyle(
                    color: kSubtextColor,
                    fontSize: 11,
                  ),
                ),
                if ((t.streamUrl ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    t.streamUrl!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
                    Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    final intId = int.tryParse(t.id) ?? 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminTournamentParticipantsScreen(
                          tournamentId: intId,
                          tournamentName: t.name,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Participants',
                    style: TextStyle(
                      color: kPrimaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusUpper,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (statusUpper == 'SCHEDULED' && onStart != null)
                  TextButton(
                    onPressed: onStart,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: kAccentGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'START',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (statusUpper == 'LIVE' && onComplete != null)
                  TextButton(
                    onPressed: onComplete,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'COMPLETE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class _ComplaintTile extends StatefulWidget {
  final Complaint complaint;
  final VoidCallback onResolve;

  const _ComplaintTile({
    required this.complaint,
    required this.onResolve,
  });

  @override
  State<_ComplaintTile> createState() => _ComplaintTileState();
}

class _ComplaintTileState extends State<_ComplaintTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding:
            const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: _hover ? kCardColor.withOpacity(0.9) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [kPrimaryBlue, Color(0xFFEC4899)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '#${c.id}',
                style: const TextStyle(
                  color: kAlertRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                c.user,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                c.type,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kSubtextColor,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Text(
                c.date,
                style: const TextStyle(
                  color: kSubtextColor,
                  fontSize: 11,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: widget.onResolve,
              icon: const Icon(
                Icons.check_circle_outline,
                color: kAccentGreen,
                size: 18,
              ),
              label: const Text(
                'Resolve',
                style: TextStyle(
                  color: kAccentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
