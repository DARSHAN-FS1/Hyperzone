import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'tournament_winners_screen.dart';
import '../services/auth_service.dart';
import '../services/tournament_api_service.dart';



const String _publicTournamentsUrl =
    'http://localhost:8080/api/tournaments/public';
const String _resultsBaseUrl = 'http://localhost:8080/api/results';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  String _selectedFilter = 'All';
  String _selectedGame = 'All Games';
  String _searchQuery = '';

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _currentUser;


  // your original static tournaments (kept)
  final List<Map<String, dynamic>> _staticTournaments = [
    {
      'id': null,
      'fromRepo': false,
      'title': 'Valorant Midnight Clash',
      'game': 'Valorant',
      'entry': 49,
      'prize': 5000,
      'slots': '32/64',
      'status': 'Ongoing',
      'tag': 'Team',
      'time': 'Today • 9:00 PM',
      'isFull': false,
    },
    {
      'id': null,
      'fromRepo': false,
      'title': 'BGMI Solo Sniper Cup',
      'game': 'BGMI',
      'entry': 29,
      'prize': 3000,
      'slots': '16/32',
      'status': 'Registration Open',
      'tag': 'Solo',
      'time': 'Tomorrow • 7:30 PM',
      'isFull': false,
    },
    {
      'id': null,
      'fromRepo': false,
      'title': 'Free Fire Rush Arena',
      'game': 'Free Fire Max',
      'entry': 0,
      'prize': 2000,
      'slots': '50/100',
      'status': 'Free Entry',
      'tag': 'Squad',
      'time': 'Saturday • 8:00 PM',
      'isFull': false,
    },
    {
      'id': null,
      'fromRepo': false,
      'title': 'CS:GO Legacy League',
      'game': 'CS:GO',
      'entry': 79,
      'prize': 7000,
      'slots': '10/16',
      'status': 'Completed',
      'tag': 'Team',
      'time': 'Sunday • 5:00 PM',
      'isFull': false,
    },
  ];

  // merged list (backend + static)
  List<Map<String, dynamic>> _allTournaments = [];
 

  // demo winners – used for static completed tournaments
  final Map<String, List<Map<String, dynamic>>> _winnersByTournament = {
    'CS:GO Legacy League': [
      {
        'rank': 1,
        'name': 'ToxicRanger',
        'team': 'Neon Hunters',
        'kills': 18,
        'prize': 7000,
      },
      {
        'rank': 2,
        'name': 'ShadowNova',
        'team': 'Phantom Core',
        'kills': 14,
        'prize': 3000,
      },
      {
        'rank': 3,
        'name': 'PixelSniper',
        'team': 'Headshot Kings',
        'kills': 11,
        'prize': 1500,
      },
      {
        'rank': 4,
        'name': 'CrimsonWolf',
        'team': 'Clutch Moments',
        'kills': 9,
        'prize': 500,
      },
      {
        'rank': 5,
        'name': 'CyberGhost',
        'team': 'Ghost Line',
        'kills': 7,
        'prize': 0,
      },
      {
        'rank': 6,
        'name': 'MetalFury',
        'team': 'Steel Squad',
        'kills': 6,
        'prize': 0,
      },
    ],
    'BGMI Solo Sniper Cup': [
      {
        'rank': 1,
        'name': 'ClutchGod',
        'team': 'BGMI Legends',
        'kills': 16,
        'prize': 3000,
      },
      {
        'rank': 2,
        'name': 'NeoX',
        'team': 'Soul Squad',
        'kills': 12,
        'prize': 1500,
      },
      {
        'rank': 3,
        'name': 'RebelOP',
        'team': 'Tactical Rush',
        'kills': 9,
        'prize': 500,
      },
    ],
  };

    @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadTournaments();
  }


    Future<void> _loadCurrentUser() async {
    final auth = AuthService();
    final user = await auth.getSavedUser();
    if (!mounted) return;

    setState(() {
      _currentUser = user;
    });
  }


 // 🔹 LOAD tournaments from Spring Boot /api/tournaments/public
Future<void> _loadTournaments() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final res = await http.get(Uri.parse(_publicTournamentsUrl));

    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;

      final backendMaps = list.map<Map<String, dynamic>>((dynamic item) {
        final m = item as Map<String, dynamic>;

        final int joinedCount = (m['joinedCount'] ?? 0) as int;
        final int slots = (m['slots'] ?? 0) as int;
        final bool isFull = slots > 0 && joinedCount >= slots;

        final String rawStatus =
            (m['status'] ?? '').toString().toUpperCase();
        String uiStatus;
        switch (rawStatus) {
          case 'LIVE':
            uiStatus = 'Ongoing';
            break;
          case 'SCHEDULED':
            uiStatus = 'Registration Open';
            break;
          case 'COMPLETED':
            uiStatus = 'Completed';
            break;
          default:
            uiStatus = 'Registration Open';
        }

        double prizePool = 0;
        final pp = m['prizePool'];
        if (pp is int) {
          prizePool = pp.toDouble();
        } else if (pp is double) {
          prizePool = pp;
        }

        return {
          'id': m['id'],
          'fromRepo': true, // ✅ backend tournament
          'title': m['name'] ?? '',
          'game': m['game'] ?? 'Unknown',
          'entry': 0, // (still not using entryFee here)
          'prize': prizePool,
          // ✅ store raw counts + display string
          'joinedCount': joinedCount,
          'slotsCount': slots,
          'slots': '$joinedCount/$slots',
          'status': uiStatus,
          'tag': 'Team',
          'time': m['scheduledText'] ?? '',
          'isFull': isFull,
          'winner': m['winner'],
          'prizeDelivered': m['prizeDelivered'] ?? false,
        };
      }).toList();

      setState(() {
        // backend first, then static demo ones
        _allTournaments = [
          ...backendMaps,
          ..._staticTournaments,
        ];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error =
            'Failed to load tournaments (HTTP ${res.statusCode}). Showing demo tournaments.';
        _allTournaments = [..._staticTournaments];
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _error =
          'Failed to connect to backend: $e\nShowing demo tournaments only.';
      _allTournaments = [..._staticTournaments];
      _isLoading = false;
    });
  }
}


  // remove weird characters from time (08 Dec 2025 â etc.)
  String _cleanTime(String raw) {
    if (raw.isEmpty) return raw;
    final asciiOnly = raw.replaceAll(RegExp(r'[^\x00-\x7F]+'), ' ');
    return asciiOnly.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // 🔹 VIEW RESULT for backend tournaments (fromRepo == true)
  Future<void> _showBackendResultDialog(Map<String, dynamic> t) async {
    final dynamic rawId = t['id'];
    if (rawId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tournament id found for results.')),
      );
      return;
    }

    final int? tournamentId = int.tryParse(rawId.toString());
    if (tournamentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid tournament id: $rawId'),
        ),
      );
      return;
    }

    // mini loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

    TournamentResult? result;
    String? error;

    try {
      final uri = Uri.parse('$_resultsBaseUrl/$tournamentId');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        result = TournamentResult.fromJson(data);
      } else if (res.statusCode == 404) {
        error = 'Host has not added winners yet.';
      } else {
        error = 'Failed to load result (HTTP ${res.statusCode}).';
      }
    } catch (e) {
      error = 'Failed to connect to backend: $e';
    }

    if (!mounted) return;

    Navigator.of(context).pop(); // close loading

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF020617),
                      Color(0xFF020617),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF38BDF8),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFACC15), Color(0xFFF97316)],
                            ),
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tournament Results',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t['title']?.toString() ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _winnerRow('🥇 1st place', result!.firstPlace),
                    const SizedBox(height: 8),
                    _winnerRow('🥈 2nd place', result.secondPlace),
                    const SizedBox(height: 8),
                    _winnerRow('🥉 3rd place', result.thirdPlace),
                    const SizedBox(height: 12),
                    if ((result.extraInfo ?? '').isNotEmpty) ...[
                      const Text(
                        'Notes',
                        style: TextStyle(
                          color: Color(0xFFE5E7EB),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.extraInfo!,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _winnerRow(String label, String? value) {
    final display =
        (value == null || value.trim().isEmpty) ? '—' : value.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            display,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0B0F18);
    const Color cardBg = Color(0xFF101624);
    const Color accent = Color(0xFF4DD0E1);

    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 900;

    final visibleTournaments = _allTournaments.where((t) {
      final matchesFilter = () {
        if (_selectedFilter == 'All') return true;
        if (_selectedFilter == 'Free Entry') return t['entry'] == 0;
        if (_selectedFilter == 'Completed') return t['status'] == 'Completed';
        return t['tag'] == _selectedFilter;
      }();

      final matchesGame =
          _selectedGame == 'All Games' ? true : t['game'] == _selectedGame;

      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          t['title'].toString().toLowerCase().contains(q) ||
          t['game'].toString().toLowerCase().contains(q);

      return matchesFilter && matchesGame && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1724),
        elevation: 0,
        title: const Text(
          'Tournaments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _loadTournaments,
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hyperzone Tournaments',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF111725),
                        border: Border.all(
                          color: accent.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        cursorColor: accent,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white70,
                            size: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Games',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _gameChip('All Games', Icons.grid_view_rounded),
                    _gameChip('Valorant', Icons.sports_esports_rounded),
                    _gameChip('BGMI', Icons.smartphone),
                    _gameChip('Free Fire', Icons.whatshot_rounded),
                    _gameChip('CS:GO', Icons.center_focus_strong_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Mode',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All'),
                    _filterChip('Solo'),
                    _filterChip('Team'),
                    _filterChip('Squad'),
                    _filterChip('Free Entry'),
                    _filterChip('Completed'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              else if (_error != null && visibleTournaments.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else if (visibleTournaments.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Text(
                      'No tournaments found for this search / filter.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
  else
  GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: isWide ? 2 : 1,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      
      mainAxisExtent: 230,
    ),
    itemCount: visibleTournaments.length,
    itemBuilder: (context, index) {
      final t = visibleTournaments[index];
      final String title = t['title'] as String;

      VoidCallback? onViewWinners;

      if (t['fromRepo'] == true &&
          t['id'] != null &&
          t['status'] == 'Completed') {
        onViewWinners = () {
          _showBackendResultDialog(t);
        };
      } else if (t['status'] == 'Completed' &&
          _winnersByTournament.containsKey(title)) {
        onViewWinners = () {
          final winners = _winnersByTournament[title] ?? [];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TournamentWinnersScreen(
                tournamentName: title,
                winners: winners,
              ),
            ),
          );
        };
      }

      return _TournamentCard(
        t: t,
        cardBg: cardBg,
        accent: accent,
        onJoin: () => _showJoinDialog(context, t),
        onShare: () => _shareTournament(t),
        onViewWinners: onViewWinners,
      );
    },
  ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _gameChip(String label, IconData icon) {
    final bool selected = _selectedGame == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          setState(() {
            _selectedGame = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF4DD0E1), Color(0xFF7C4DFF)],
                  )
                : null,
            color: selected ? null : const Color(0xFF151B2A),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.white12,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.black : Colors.white60,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool selected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        selected: selected,
        selectedColor: const Color(0xFF4DD0E1),
        backgroundColor: const Color(0xFF151B2A),
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

void _showJoinDialog(BuildContext context, Map<String, dynamic> t) {
  final bool isCompleted = t['status'] == 'Completed';
  final bool isFull = t['isFull'] == true;

  // closed tournaments: do nothing
  if (isCompleted || isFull) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF101624),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Join "${t['title']}"?',
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(
        t['entry'] == 0
            ? 'This is a FREE ENTRY tournament.\n\nConfirm to join the lobby.'
            : 'Entry fee: ₹${t['entry']}.\n\nThis will be deducted from your wallet balance.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);

            final bool isBackend = t['fromRepo'] == true && t['id'] != null;
            final dynamic rawId = t['id'];
            final int? tId =
                rawId == null ? null : int.tryParse(rawId.toString());

            try {
              if (isBackend && tId != null && _currentUser != null) {
                final user = _currentUser!;

                // 🔸 Try multiple key names safely
                final String username = (user['username'] ??
                        user['name'] ??
                        user['displayName'] ??
                        'Player')
                    .toString();

                final String? userId =
                    (user['id'] ?? user['userId'])?.toString();

                final String? email = user['email']?.toString();

                // (optional) debug print – just for you in flutter run console
                // print('JOIN sending -> username=$username, userId=$userId, email=$email');

                await TournamentApiService.instance.joinTournament(
                  tournamentId: tId,
                  username: username,
                  userId: userId,
                  email: email,
                );
              }

              // show success regardless (frontend side)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joined ${t['title']} successfully 🎮'),
                ),
              );

              // refresh list so joinedCount / slots update
              _loadTournaments();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to join: $e')),
              );
            }
          },
          child: const Text(
            'Confirm',
            style: TextStyle(color: Color(0xFF4DD0E1)),
          ),
        ),
      ],
    ),
  );
}




}

  



void _shareTournament(Map<String, dynamic> t) {
  final String message = '''
${t['title']} (${t['game']})

Entry: ${t['entry'] == 0 ? 'Free' : '₹${t['entry']}'}  
Prize Pool: ₹${t['prize']}
Time: ${t['time'].toString()}
Slots: ${t['slots']}

Play on HYPERZONE 🎮
''';

  Share.share(
    message,
    subject: 'Join this ${t['game']} tournament on Hyperzone',
  );
}



class _TournamentCard extends StatelessWidget {
  final Map<String, dynamic> t;
  final Color cardBg;
  final Color accent;
  final VoidCallback onJoin;
  final VoidCallback onShare;
  final VoidCallback? onViewWinners;

  const _TournamentCard({
    required this.t,
    required this.cardBg,
    required this.accent,
    required this.onJoin,
    required this.onShare,
    this.onViewWinners,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Ongoing':
        return Colors.greenAccent;
      case 'Registration Open':
        return const Color(0xFF4DD0E1);
      case 'Closing Soon':
        return Colors.orangeAccent;
      case 'Free Entry':
        return Colors.lightGreenAccent;
      case 'Completed':
        return Colors.white70;
      default:
        return Colors.white70;
    }
  }

  String _cleanTime(String raw) {
    if (raw.isEmpty) return raw;
    final asciiOnly = raw.replaceAll(RegExp(r'[^\x00-\x7F]+'), ' ');
    return asciiOnly.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _gameBackground(String game) {
    switch (game) {
      case 'Valorant':
        return 'assets/games/valorant_bg.jpg';
      case 'BGMI':
        return 'assets/games/bgmi_bg.jpg';
      case 'Free Fire':
      case 'Free Fire Max':
        return 'assets/games/freefire_bg.jpg';
      case 'CS:GO':
        return 'assets/games/csgo_bg.jpg';
      default:
        return 'assets/games/default_bg.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(t['status']);
    final bgImagePath = _gameBackground(t['game']);
    final bool isCompleted = t['status'] == 'Completed';
    final bool isFull = t['isFull'] == true;
    final bool disableJoin = isCompleted || isFull;

    // ✅ winner + prize flags
    final String winnerText =
        (t['winner'] ?? '').toString().trim();
    final bool prizeDelivered = t['prizeDelivered'] == true;
    final bool showWinner =
        isCompleted && winnerText.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              bgImagePath,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: cardBg.withOpacity(0.82),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: icon + title + share
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4DD0E1), Color(0xFF1DE9B6)],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          t['game'].toString().substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t['game'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: onShare,
                        icon: const Icon(
                          Icons.share,
                          size: 18,
                          color: Colors.white70,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Status + tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 0.8),
                        ),
                        child: Text(
                          t['status'],
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.deepPurpleAccent,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          t['tag'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Time + slots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: Colors.white60),
                          const SizedBox(width: 4),
                          Text(
                            _cleanTime(t['time'].toString()),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.group,
                              size: 16, color: Colors.white60),
                          const SizedBox(width: 4),
                          Text(
                            t['slots'],
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Bottom row: prize, entry, winner info, join button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entry: ${t['entry'] == 0 ? "Free" : "₹${t['entry']}"}',
                            style: TextStyle(
                              color: t['entry'] == 0
                                  ? Colors.greenAccent
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Prize: ₹${t['prize']}',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),

                          // ✅ Winner + prize delivered text for completed tournaments
                          if (showWinner) ...[
                            const SizedBox(height: 4),
                            Text(
                              '🏅 Winner: $winnerText',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              prizeDelivered ? 'Prize Delivered' : 'Prize Pending',
                              style: TextStyle(
                                color: prizeDelivered
                                    ? Colors.greenAccent
                                    : Colors.amberAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          if (onViewWinners != null) ...[
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: onViewWinners,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View result',
                                style: TextStyle(
                                  color: Color(0xFF4DD0E1),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      ElevatedButton(
                        onPressed: disableJoin ? null : onJoin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              disableJoin ? Colors.grey.shade700 : accent,
                          foregroundColor:
                              disableJoin ? Colors.white70 : Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          disableJoin ? 'Closed' : 'Join',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// 🔹 DTO to match backend TournamentResultDto
class TournamentResult {
  final int tournamentId;
  final String? firstPlace;
  final String? secondPlace;
  final String? thirdPlace;
  final String? extraInfo;

  TournamentResult({
    required this.tournamentId,
    this.firstPlace,
    this.secondPlace,
    this.thirdPlace,
    this.extraInfo,
  });

  factory TournamentResult.fromJson(Map<String, dynamic> json) {
    return TournamentResult(
      tournamentId: json['tournamentId'] ?? 0,
      firstPlace: json['firstPlace'],
      secondPlace: json['secondPlace'],
      thirdPlace: json['thirdPlace'],
      extraInfo: json['extraInfo'],
    );
  }
}
