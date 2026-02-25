import 'package:flutter/material.dart';
import '../services/tournament_repository.dart';
import '../services/tournament_api_service.dart';
import '../services/auth_service.dart';
import 'tournaments_screen.dart';

class HostTournamentScreen extends StatefulWidget {
  const HostTournamentScreen({super.key});

  @override
  State<HostTournamentScreen> createState() => _HostTournamentScreenState();
}

class _HostTournamentScreenState extends State<HostTournamentScreen> {
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 1;
  String _selectedGame = 'Valorant';
  String _selectedMode = 'Solo';
  bool _nextHover = false;
  bool _isPublishing = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _entryFeeController = TextEditingController();
  final TextEditingController _prizePoolController = TextEditingController();
  final TextEditingController _slotsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _guidelinesController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _streamUrlController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _startDateTime;

  final _tournamentApi = TournamentApiService.instance;

  @override
  void dispose() {
    _titleController.dispose();
    _entryFeeController.dispose();
    _prizePoolController.dispose();
    _slotsController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _rulesController.dispose();
    _descriptionController.dispose();
    _guidelinesController.dispose();
    _youtubeController.dispose();
    _streamUrlController.dispose();
    super.dispose();
  }

  void _updateStartDateTime() {
    if (_selectedDate == null || _selectedTime == null) return;
    _startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  void _onNextPressed() {
    if (!_formKey.currentState!.validate()) return;

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      if (_isPublishing) return;
      _publishTournament();
    }
  }

  void _onBackPressed() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _publishTournament() async {
    if (_startDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final entry = int.tryParse(_entryFeeController.text.trim()) ?? 0;
    final prize = int.tryParse(_prizePoolController.text.trim()) ?? 0;
    final slots = int.tryParse(_slotsController.text.trim()) ?? 0;

    final dateText =
        '${_dateController.text.trim()} • ${_timeController.text.trim()} IST';

    setState(() {
      _isPublishing = true;
    });

    try {
      final savedUser = await AuthService.instance.getSavedUser();
      String createdBy = 'guest';

      if (savedUser != null &&
          (savedUser['username']?.toString().trim().isNotEmpty ?? false)) {
        createdBy = savedUser['username'].toString().trim();
      }

      await _tournamentApi.createTournamentRequest(
        name: _titleController.text.trim(),
        game: _selectedGame,
        createdBy: createdBy,
        date: dateText,
        slots: slots,
        prizePool: prize.toDouble(),
        streamUrl: _youtubeController.text.trim().isEmpty
            ? null
            : _youtubeController.text.trim(),
      );

      TournamentRepository.instance.addTournament(
        name: _titleController.text.trim(),
        game: _selectedGame,
        mode: _selectedMode,
        entryFee: entry,
        prizePool: prize,
        maxPlayers: slots,
        startTime: _startDateTime!,
        hostUserId: createdBy,
        streamUrl: _youtubeController.text.trim().isEmpty
            ? null
            : _youtubeController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournament submitted for admin review'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TournamentsScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0F18);
    const cardBg = Color(0xFF101624);
    const accent = Color(0xFF4DD0E1);

    final width = MediaQuery.of(context).size.width;
    final bool isWide = width > 900;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1724),
        elevation: 0,
        title: const Text(
          'Host Tournament',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 16),
              _buildStepBar(),
              const SizedBox(height: 18),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFormCard(cardBg)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildPreviewCard(cardBg, accent)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildFormCard(cardBg),
                    const SizedBox(height: 16),
                    _buildPreviewCard(cardBg, accent),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    const accent = Color(0xFF4DD0E1);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Image.asset(
              'assets/banners/host_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 170,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC020309),
                  Color(0xEE040712),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'CREATE YOUR ARENA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'HOST COMPETE, WIN',
                    style: TextStyle(
                      color: accent,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Define your tournament. Set the rules.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1523),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _stepPill(1, '1. Basics'),
          _stepPill(2, '2. Details'),
          _stepPill(3, '3. Publish'),
        ],
      ),
    );
  }

  Widget _stepPill(int index, String label) {
    final active = _currentStep >= index;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? const Color(0xFF1A2235) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(Color cardBg) {
    String stepTitle;
    if (_currentStep == 1) {
      stepTitle = 'STEP 1 BASICS';
    } else if (_currentStep == 2) {
      stepTitle = 'STEP 2 DETAILS';
    } else {
      stepTitle = 'STEP 3 PUBLISH';
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stepTitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            if (_currentStep == 1) ..._buildBasicsStep(),
            if (_currentStep == 2) ..._buildDetailsStep(),
            if (_currentStep == 3) ..._buildPublishStep(),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentStep == 1
                      ? () => Navigator.pop(context)
                      : _onBackPressed,
                  child: Text(
                    _currentStep == 1 ? 'Cancel' : 'Back',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
                MouseRegion(
                  onEnter: (_) => setState(() => _nextHover = true),
                  onExit: (_) => setState(() => _nextHover = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    width: 190,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: _nextHover
                            ? const [Color(0xFF4DD0E1), Color(0xFF00E5FF)]
                            : const [Color(0xFF4DD0E1), Color(0xFF7C4DFF)],
                      ),
                      boxShadow: _nextHover
                          ? [
                              BoxShadow(
                                color:
                                    const Color(0xFF4DD0E1).withOpacity(0.55),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color:
                                    const Color(0xFF4DD0E1).withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: _onNextPressed,
                        child: Center(
                          child: Text(
                            _currentStep == 1
                                ? 'Next step: Details'
                                : _currentStep == 2
                                    ? 'Next step: Publish'
                                    : (_isPublishing
                                        ? 'Publishing...'
                                        : 'Publish Tournament'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBasicsStep() {
    return [
      const Text(
        'Select Game',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _gameChip('Valorant', Icons.sports_esports_rounded),
          _gameChip('BGMI', Icons.smartphone),
          _gameChip('Free Fire', Icons.whatshot_rounded),
          _gameChip('CS:GO', Icons.center_focus_strong_rounded),
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        'Tournament Title',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      _buildTextField(
        controller: _titleController,
        hint: 'e.g. Midnight Clash – Tier 1 Lobby',
        validatorMsg: 'Please enter tournament title',
        step: 1,
      ),
      const SizedBox(height: 14),
      const Text(
        'Game Mode',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          _modeChip('Solo'),
          _modeChip('Team'),
          _modeChip('Squad'),
        ],
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entry Fee (₹)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _entryFeeController,
                  hint: 'e.g. 49 (0 for Free)',
                  keyboardType: TextInputType.number,
                  validatorMsg: 'Enter entry fee (0 allowed)',
                  step: 1,
                  numeric: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prize Pool (₹)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _prizePoolController,
                  hint: 'e.g. 5000',
                  keyboardType: TextInputType.number,
                  validatorMsg: 'Enter prize pool',
                  step: 1,
                  numeric: true,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      const Text(
        'Total Slots',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      _buildTextField(
        controller: _slotsController,
        hint: 'e.g. 64',
        keyboardType: TextInputType.number,
        validatorMsg: 'Enter total slots',
        step: 1,
        numeric: true,
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _dateController,
                      hint: 'Select date',
                      validatorMsg: 'Select date',
                      step: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Time',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickTime(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _timeController,
                      hint: 'Select time',
                      validatorMsg: 'Select time',
                      step: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDetailsStep() {
    return [
      const Text(
        'Tournament Description',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      _buildTextField(
        controller: _descriptionController,
        hint: 'Describe format, maps, lobbies, POV etc.',
        maxLines: 3,
        validatorMsg: 'Add tournament description',
        step: 2,
      ),
      const SizedBox(height: 14),
      const Text(
        'Prize Pool Breakdown',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      _buildTextField(
        controller: _guidelinesController,
        hint: 'e.g. 1st: 60%, 2nd: 30%, 3rd: 10%',
        validatorMsg: 'Add prize pool breakdown',
        step: 2,
      ),
      const SizedBox(height: 14),
      const Text(
        'Rules and Guidelines',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      _buildTextField(
        controller: _rulesController,
        hint: 'Fair play rules, disqualification, lobby info.',
        maxLines: 3,
        validatorMsg: 'Add rules and guidelines',
        step: 2,
      ),
      const SizedBox(height: 14),
      const Text(
        'YouTube / Stream Link',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      _buildTextField(
        controller: _youtubeController,
        hint: 'https://www.youtube.com/...',
        validatorMsg: '',
        step: 2,
        allowEmpty: true,
        url: true,
      ),
    ];
  }

  List<Widget> _buildPublishStep() {
    return [
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 100,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                _gameImagePath(),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleController.text.isEmpty
                        ? 'Your tournament title'
                        : _titleController.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedGame,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mode: $_selectedMode • Entry: ₹${_entryFeeController.text.isEmpty ? '-' : _entryFeeController.text}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Publish checklist',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        '• Final check details.\n'
        '• Promote on social.\n'
        '• Share link with players.',
        style: TextStyle(
          color: Colors.white60,
          fontSize: 11,
        ),
      ),
    ];
  }

  Widget _buildPreviewCard(Color cardBg, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview & Tips',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Image.asset(
                    _gameImagePath(),
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.isEmpty
                            ? 'Your tournament title'
                            : _titleController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedGame,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: accent.withOpacity(0.18),
                              border: Border.all(color: accent, width: 0.8),
                            ),
                            child: Text(
                              _selectedMode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Entry: ₹${_entryFeeController.text.isEmpty ? '—' : _entryFeeController.text}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Pro tips',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '• Keep rules clear.\n'
            '• Set realistic prize pools.\n'
            '• Share lobby info early.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String validatorMsg,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required int step,
    bool allowEmpty = false,
    bool numeric = false,
    bool url = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: const Color(0xFF4DD0E1),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (_currentStep != step) return null;
        final text = value?.trim() ?? '';

        if (allowEmpty && text.isEmpty) return null;
        if (text.isEmpty) return validatorMsg;

        if (numeric) {
          final n = int.tryParse(text);
          if (n == null) return 'Enter a valid number';
        }

        if (url) {
          if (text.isEmpty) return null;
          final regex = RegExp(
              r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-zA-Z]{2,6}.*$');
          if (!regex.hasMatch(text) || !text.contains('.com')) {
            return 'Enter a valid link (e.g. https://www.youtube.com/...)';
          }
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF151B2A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4DD0E1), width: 1.1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _gameChip(String game, IconData icon) {
    final selected = _selectedGame == game;
    return ChoiceChip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: selected ? Colors.black : Colors.white60,
          ),
          const SizedBox(width: 4),
          Text(
            game,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
      selected: selected,
      selectedColor: const Color(0xFF4DD0E1),
      backgroundColor: const Color(0xFF151B2A),
      onSelected: (_) => setState(() => _selectedGame = game),
    );
  }

  Widget _modeChip(String label) {
    final selected = _selectedMode == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: selected,
        selectedColor: const Color(0xFF4DD0E1),
        backgroundColor: const Color(0xFF151B2A),
        onSelected: (_) {
          setState(() => _selectedMode = label);
        },
      ),
    );
  }

  String _gameImagePath() {
    switch (_selectedGame) {
      case 'Valorant':
        return 'assets/games/valorant_bg.jpg';
      case 'BGMI':
        return 'assets/games/bgmi_bg.jpg';
      case 'Free Fire':
        return 'assets/games/freefire_bg.jpg';
      case 'CS:GO':
        return 'assets/games/csgo_bg.jpg';
      default:
        return 'assets/games/bgmi_bg.jpg';
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (result != null) {
      _selectedDate = result;
      _dateController.text =
          '${result.day.toString().padLeft(2, '0')}/${result.month.toString().padLeft(2, '0')}/${result.year}';
      _updateStartDateTime();
      setState(() {});
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final result = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 21, minute: 0),
    );
    if (result != null) {
      _selectedTime = result;
      final hour = result.hourOfPeriod.toString().padLeft(2, '0');
      final minute = result.minute.toString().padLeft(2, '0');
      final period = result.period == DayPeriod.am ? 'AM' : 'PM';
      _timeController.text = '$hour:$minute $period';
      _updateStartDateTime();
      setState(() {});
    }
  }
}
