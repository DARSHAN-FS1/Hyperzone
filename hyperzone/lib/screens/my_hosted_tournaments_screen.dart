import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';



const String _baseUrl = 'http://localhost:8080/api/tournaments';

class MyHostedTournamentsScreen extends StatefulWidget {
  const MyHostedTournamentsScreen({super.key});

  @override
  State<MyHostedTournamentsScreen> createState() =>
      _HostedTournamentsScreenState();

      
}

class _HostedTournamentsScreenState extends State<MyHostedTournamentsScreen> {
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  String? _error;

  String _selectedGame = 'All Games'; 
  String _selectedStatus = 'All'; 
  List<Map<String, dynamic>> _allHosted = [];

  @override
void initState() {
  super.initState();
  _loadCurrentUserAndHosted();
}

 Future<void> _loadCurrentUserAndHosted() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    
    final user = await AuthService().getSavedUser();

    print("My Hosted Screen -> currentUser = $user");

    if (!mounted) return;

    if (user == null || user['username'] == null) {
      setState(() {
        _currentUser = null;
        _error = "Please login again.";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _currentUser = user;
    });

    final username = user['username'].toString();
    await _loadHosted(username);
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _error = "Failed to load user: $e";
      _isLoading = false;
    });
  }
}



  Future<void> _loadHosted(String username) async {
    try {
      final uri = Uri.parse('$_baseUrl/hosted/$username');
      final res = await http.get(uri);

      if (res.statusCode != 200) {
        setState(() {
          _error =
              'Failed to load hosted tournaments (HTTP ${res.statusCode}).';
          _isLoading = false;
          _allHosted = [];
        });
        return;
      }

      final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;

      final hosted = list.map<Map<String, dynamic>>((dynamic item) {
        final m = item as Map<String, dynamic>;

        final int joinedCount = (m['joinedCount'] ?? 0) as int;
        final int slots = (m['slots'] ?? 0) as int;
        final bool isFull = slots > 0 && joinedCount >= slots;

        final String rawStatus = (m['status'] ?? '').toString().toUpperCase();
        String uiStatus;
        switch (rawStatus) {
          case 'LIVE':
            uiStatus = 'Live';
            break;
          case 'SCHEDULED':
            uiStatus = 'Scheduled';
            break;
          case 'COMPLETED':
            uiStatus = 'Completed';
            break;
          default:
            uiStatus = rawStatus.isEmpty ? 'Scheduled' : rawStatus;
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
          'title': m['name'] ?? '',
          'game': m['game'] ?? 'Unknown',
          'status': uiStatus,
          'rawStatus': rawStatus,
          'slots': '$joinedCount/$slots',
          'joinedCount': joinedCount,
          'maxSlots': slots,
          'prize': prizePool,
          'time': m['scheduledText'] ?? '',
          'official': m['official'] ?? false,
          'winner': m['winner'],
          'prizeDelivered': m['prizeDelivered'] ?? false,
          'streamUrl': m['streamUrl'],
        };
      }).toList();

      setState(() {
        _allHosted = hosted;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to connect to backend: $e';
        _isLoading = false;
        _allHosted = [];
      });
    }
  }

  
  String _cleanTime(String raw) {
    if (raw.isEmpty) return raw;
    final asciiOnly = raw.replaceAll(RegExp(r'[^\x00-\x7F]+'), ' ');
    return asciiOnly.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Live':
        return Colors.greenAccent;
      case 'Scheduled':
        return const Color(0xFF4DD0E1);
      case 'Completed':
        return Colors.white70;
      default:
        return Colors.white70;
    }
  }

  Future<void> _startTournament(Map<String, dynamic> t) async {
    final id = t['id'];
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1724),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Start tournament?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Do you want to mark "${t['title']}" as LIVE?',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Start',
              style: TextStyle(color: Color(0xFF4DD0E1)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final uri = Uri.parse('$_baseUrl/$id/start');
      final res = await http.put(uri);

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tournament "${t['title']}" is now LIVE')),
        );
        // reload list
        final user = _currentUser;
        if (user != null && user['username'] != null) {
          await _loadHosted(user['username'].toString());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to start (HTTP ${res.statusCode}): ${res.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start: $e')),
      );
    }
  }

  Future<void> _completeTournament(Map<String, dynamic> t) async {
    final id = t['id'];
    if (id == null) return;

    String winner = t['winner']?.toString() ?? '';
    bool prizeDelivered = t['prizeDelivered'] == true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1724),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Complete tournament',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Winner (team / player name)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF4DD0E1),
                decoration: InputDecoration(
                  hintText: 'e.g. Team HyperGods',
                  hintStyle:
                      const TextStyle(color: Colors.white54, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF151B2A),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                onChanged: (v) => winner = v,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: prizeDelivered,
                    activeColor: const Color(0xFF4DD0E1),
                    onChanged: (v) {
                      prizeDelivered = v ?? false;
                      (ctx as Element).markNeedsBuild();
                    },
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Prize delivered to winner',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF4DD0E1)),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      final uri = Uri.parse('$_baseUrl/$id/complete').replace(
        queryParameters: <String, String>{
          if (winner.trim().isNotEmpty) 'winner': winner.trim(),
          'prizeDelivered': prizeDelivered.toString(),
        },
      );

      final res = await http.put(uri);

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tournament "${t['title']}" marked completed')),
        );
        final user = _currentUser;
        if (user != null && user['username'] != null) {
          await _loadHosted(user['username'].toString());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to complete (HTTP ${res.statusCode}): ${res.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete: $e')),
      );
    }
  }

  Future<void> _viewParticipants(Map<String, dynamic> t) async {
    final id = t['id'];
    if (id == null) return;

    try {
      final uri = Uri.parse('$_baseUrl/$id/participants');
      final res = await http.get(uri);

      if (res.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load participants (HTTP ${res.statusCode})',
            ),
          ),
        );
        return;
      }

      final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
      final participants =
          list.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();

      await showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            backgroundColor: const Color(0xFF020617),
            insetPadding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520, maxHeight: 420),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participants (${participants.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: participants.isEmpty
                          ? const Center(
                              child: Text(
                                'No participants joined yet.',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: participants.length,
                              separatorBuilder: (_, __) => const Divider(
                                color: Colors.white12,
                                height: 1,
                              ),
                              itemBuilder: (_, index) {
                                final p = participants[index];
                                final username =
                                    (p['username'] ?? 'Player').toString();
                                final email =
                                    (p['email'] ?? '—').toString();
                                final userId =
                                    (p['userId'] ?? '—').toString();
                                final joinedAt =
                                    (p['joinedAt'] ?? '').toString();

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index + 1}.',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              username,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Email: $email',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              'User ID: $userId',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              'Joined: $joinedAt',
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load participants: $e')),
      );
    }
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

  Widget _gameFilterChip(String label) {
    final selected = _selectedGame == label;
    IconData icon;
    switch (label) {
      case 'Valorant':
        icon = Icons.sports_esports_rounded;
        break;
      case 'BGMI':
        icon = Icons.smartphone;
        break;
      case 'Free Fire':
        icon = Icons.whatshot_rounded;
        break;
      case 'CS:GO':
        icon = Icons.center_focus_strong_rounded;
        break;
      default:
        icon = Icons.grid_view_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 4),
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
        selected: selected,
        selectedColor: const Color(0xFF4DD0E1),
        backgroundColor: const Color(0xFF151B2A),
        onSelected: (_) {
          setState(() => _selectedGame = label);
        },
      ),
    );
  }

  Widget _statusFilterChip(String label) {
    final selected = _selectedStatus == label;
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
          setState(() => _selectedStatus = label);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0F18);
    const cardBg = Color(0xFF101624);

    final width = MediaQuery.of(context).size.width;
    final bool isWide = width > 900;

    final visible = _allHosted.where((t) {
      final matchesGame = _selectedGame == 'All Games'
          ? true
          : (t['game']?.toString() == _selectedGame);

      final status = t['status']?.toString() ?? '';
      final matchesStatus = _selectedStatus == 'All'
          ? true
          : (_selectedStatus == 'Scheduled' && status == 'Scheduled') ||
              (_selectedStatus == 'Live' && status == 'Live') ||
              (_selectedStatus == 'Completed' && status == 'Completed');

      return matchesGame && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1724),
        elevation: 0,
        title: const Text(
          'My Hosted Tournaments',
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
            onPressed: () async {
              final user = _currentUser;
              if (user != null && user['username'] != null) {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                await _loadHosted(user['username'].toString());
              }
            },
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
                  const Expanded(
                    child: Text(
                      'Manage your arena',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_currentUser != null &&
                      _currentUser!['username'] != null)
                    Text(
                      '@${_currentUser!['username']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Game filter',
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
                    _gameFilterChip('All Games'),
                    _gameFilterChip('Valorant'),
                    _gameFilterChip('BGMI'),
                    _gameFilterChip('Free Fire'),
                    _gameFilterChip('CS:GO'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Status',
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
                    _statusFilterChip('All'),
                    _statusFilterChip('Scheduled'),
                    _statusFilterChip('Live'),
                    _statusFilterChip('Completed'),
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
              else if (_error != null && visible.isEmpty)
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
              else if (visible.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Text(
                      'No hosted tournaments found.\nCreate one from "Host Tournament" screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
                    mainAxisExtent: 210,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final t = visible[index];
                    return _HostedTournamentCard(
                      t: t,
                      cardBg: cardBg,
                      statusColor: _statusColor(t['status'] ?? ''),
                      bgImagePath: _gameBackground(t['game'] ?? ''),
                      cleanTime: _cleanTime,
                      onStart: t['status'] == 'Scheduled'
                          ? () => _startTournament(t)
                          : null,
                      onComplete: t['status'] == 'Live'
                          ? () => _completeTournament(t)
                          : null,
                      onViewParticipants: () => _viewParticipants(t),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostedTournamentCard extends StatelessWidget {
  final Map<String, dynamic> t;
  final Color cardBg;
  final Color statusColor;
  final String bgImagePath;
  final String Function(String) cleanTime;

  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback onViewParticipants;

  const _HostedTournamentCard({
    required this.t,
    required this.cardBg,
    required this.statusColor,
    required this.bgImagePath,
    required this.cleanTime,
    required this.onViewParticipants,
    this.onStart,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = (t['status'] ?? '') == 'Completed';
    final bool isLive = (t['status'] ?? '') == 'Live';
    final bool isScheduled = (t['status'] ?? '') == 'Scheduled';
    final bool isOfficial = t['official'] == true;

    final winnerText = (t['winner'] ?? '').toString().trim();
    final bool prizeDelivered = t['prizeDelivered'] == true;
    final bool showWinner = isCompleted && winnerText.isNotEmpty;

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
                  // top: title + game + status
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
                          t['game']
                              .toString()
                              .substring(0, 2)
                              .toUpperCase(),
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
                              t['title'] ?? '',
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
                              t['game'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
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
                          t['status'] ?? '',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (isOfficial)
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
                          child: const Text(
                            'Official',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      if (isOfficial) const SizedBox(width: 6),
                      Text(
                        'Prize: ₹${t['prize'] ?? 0}',
                        style: const TextStyle(
                          color: Color(0xFF4DD0E1),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: Colors.white60),
                          const SizedBox(width: 4),
                          Text(
                            cleanTime(t['time']?.toString() ?? ''),
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
                            t['slots']?.toString() ?? '0/0',
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
                  if (showWinner) ...[
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
                    const SizedBox(height: 6),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // left side actions
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          OutlinedButton.icon(
                            onPressed: onViewParticipants,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.white24, width: 0.8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.people_alt_outlined,
                                size: 14, color: Colors.white70),
                            label: const Text(
                              'Players',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (isLive)
                            OutlinedButton.icon(
                              onPressed: onComplete,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.orangeAccent, width: 0.9),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.flag_rounded,
                                  size: 14, color: Colors.orangeAccent),
                              label: const Text(
                                'Mark Complete',
                                style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // right side main CTA
                      if (isScheduled)
                        ElevatedButton(
                          onPressed: onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DD0E1),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Start',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else if (isLive)
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        )
                      else if (isCompleted)
                        const Text(
                          'COMPLETED',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
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
