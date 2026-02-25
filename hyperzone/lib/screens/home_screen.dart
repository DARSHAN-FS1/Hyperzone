import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import 'host_tournament_screen.dart';
import 'leaderboard_screen.dart';
import 'tournaments_screen.dart';
import 'wallet_screen.dart';
import 'rewards_screen.dart';
import 'contact_us_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'my_hosted_tournaments_screen.dart';
import '../models/tournament.dart';
import '../services/tournament_api_service.dart';
import 'live_stream_screen.dart';



// Backend public tournaments endpoint
const String _publicTournamentsUrl =
    'http://localhost:8080/api/tournaments/public';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _username = "Player";
  String _email = "player@example.com";

  static const double desktop = 1100;
  static const double tablet = 800;
  static const double phone = 600;

  // Live events game filter
  String _selectedLiveGame = 'All';

  // All tournaments used on Home (live + upcoming + big prize)
  List<Tournament> _tournaments = [];

  // Wallet & joined state
  double _walletBalance = 5000; // starting balance
  final Set<String> _joinedTournamentIds = {};

  // Wallet transactions
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Prize Won – Valo Night',
      'subtitle': 'Valorant • Winner Reward',
      'amount': 150000,
      'time': 'Yesterday • 9:45 PM',
    },
    {
      'title': 'Wallet Top-up',
      'subtitle': 'UPI • Add Money',
      'amount': 500,
      'time': '02 Dec • 6:30 PM',
    },
  ];

  // Notifications (for bell icon)
  // Each item: title, subtitle, roomId, password, time
  final List<Map<String, String>> _notifications = [];
  int _unreadNotifications = 0;

  // random generator for Room ID / Password
  final Random _rand = Random();

  // Polling timer for admin status changes
  Timer? _adminPollTimer;

  // Remember last status from backend per tournament id
  // so we can detect changes LIVE / COMPLETED
  final Map<int, String> _lastStatusById = {};

  @override
  void initState() {
    super.initState();

    _loadUser();
    _fetchTournamentsFromBackend();
    _checkAdminTournamentUpdates();
    _adminPollTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => _checkAdminTournamentUpdates(),
    );
  }

  @override
  void dispose() {
    _adminPollTimer?.cancel();
    super.dispose();
  }

  void _seedSampleTournaments() {
    final now = DateTime.now();

    _tournaments.addAll([
      Tournament(
        id: 't1',
        name: 'Hyperzone Grand Masters',
        game: 'BGMI',
        mode: 'Squad',
        entryFee: 1000,
        prizePool: 1000000,
        maxPlayers: 100,
        currentPlayers: 24,
        startTime: now.add(const Duration(hours: 3)),
        hostUserId: 'Admin', // admin-hosted
        isOfficial: true, // official
        isBigTournament: true,
        streamUrl: 'https://www.youtube.com/@scoutop/live',

      ),
      Tournament(
        id: 't2',
        name: 'Valo Night – Hyperzone Cup',
        game: 'Valorant',
        mode: 'Solo',
        entryFee: 500,
        prizePool: 150000,
        maxPlayers: 80,
        currentPlayers: 12,
        startTime: now.add(const Duration(hours: 5)),
        hostUserId: 'Admin',
        isOfficial: true,
        isBigTournament: true,
        streamUrl: 'https://www.youtube.com/@JonathanGamingYT/live',
      ),
      Tournament(
        id: 't3',
        name: 'Free Fire Rush',
        game: 'Free Fire',
        mode: 'Squad',
        entryFee: 0,
        prizePool: 20000,
        maxPlayers: 64,
        currentPlayers: 40,
        startTime: now.add(const Duration(days: 1, hours: 1)),
        hostUserId: 'demo-user',
        isOfficial: false,
        isBigTournament: false,
        streamUrl: null,
      ),
      Tournament(
        id: 't4',
        name: 'CS:GO Legacy League',
        game: 'CS:GO',
        mode: 'Team',
        entryFee: 79,
        prizePool: 7000,
        maxPlayers: 16,
        currentPlayers: 8,
        startTime: now.add(const Duration(days: 2)),
        hostUserId: 'demo-user',
        isOfficial: false,
        isBigTournament: false,
        streamUrl: null,
      ),
    ]);
  }

Future<void> _fetchTournamentsFromBackend() async {
  try {
    final list = await TournamentApiService.instance.getPublicTournaments();

    if (!mounted) return;

    // Remove COMPLETED / CANCELLED from Home screen
    final filtered = list.where((t) {
      final s = t.status.toUpperCase();
      return s != 'COMPLETED' && s != 'CANCELLED';
    }).toList();

    setState(() {
      _tournaments = filtered;
    });
  } catch (e) {
    print("⚠️ Failed to load tournaments: $e");

    if (_tournaments.isEmpty) {
      _seedSampleTournaments();
      setState(() {});
    }
  }
}


  // ========= USER LOAD =========
  Future<void> _loadUser() async {
    final auth = AuthService();
    final user = await auth.getSavedUser();

    if (user != null && mounted) {
      setState(() {
        _username = user['username']?.toString() ?? "Player";
        _email = user['email']?.toString() ?? "player@example.com";
      });
    }
  }

  Future<void> _logout() async {
    final auth = AuthService();
    await auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ===== Helpers for room credentials =====
  String _generateRoomId() {
    final num = 1000 + _rand.nextInt(9000);
    return 'ROOM$num';
  }

  String _generatePassword() {
    final num = 1000 + _rand.nextInt(9000);
    return 'PASS$num';
  }

  // JOIN HANDLER: wallet + notification + dialog
  void _handleJoinTournament(Tournament t) {
    
    if (_joinedTournamentIds.contains(t.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You already joined ${t.name}.')),
      );
      return;
    }

    
    final int fee = (t.entryFee is num)
        ? (t.entryFee as num).toInt()
        : 0;

    
    if (fee > _walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance to join this tournament.'),
        ),
      );
      return;
    }

    
    final String roomId = _generateRoomId();
    final String password = _generatePassword();

   
    setState(() {
      _walletBalance -= fee;
      _joinedTournamentIds.add(t.id);

      // Transaction history (for WalletScreen)
      if (fee > 0) {
        _transactions.insert(0, {
          'title': 'Joined ${t.name}',
          'subtitle': '${t.game} • ${t.mode}',
          'amount': -fee,
          'time': 'Just now',
        });
      }

      // Notification for wallet + room details
      _notifications.insert(0, {
        'title': fee > 0
            ? 'Wallet debited ₹$fee'
            : 'Joined ${t.name}',
        'subtitle': fee > 0
            ? '₹$fee deducted for ${t.name} (${t.game} • ${t.mode})'
            : 'Game: ${t.game} • Entry: Free',
        'roomId': roomId,
        'password': password,
        'time': 'Just now',
      });

      _unreadNotifications++;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF101624),
                      Color(0xFF050A12),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF4DD0E1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4DD0E1).withOpacity(0.45),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4DD0E1), Color(0xFF00BFA5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DD0E1).withOpacity(0.7),
                            blurRadius: 22,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.black,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Entry Locked In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You are now registered for',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '"${t.name}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Game: ${t.game}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Mode: ${t.mode}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Entry fee charged',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            fee == 0 ? 'Free' : '₹$fee',
                            style: const TextStyle(
                              color: Color(0xFF4DD0E1),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Room ID & Password have been added to Notifications.\n'
                      'Check the bell icon in the header before match start.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                       ElevatedButton(
  onPressed: () {
    Navigator.pop(ctx);
    Navigator.pushNamed(
      context,
      '/wallet',
      arguments: {
        'balance': _walletBalance,
        'transactions': _transactions,
      },
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF4DD0E1),
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 10,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  child: const Text(
    'View Wallet',
    style: TextStyle(
      fontWeight: FontWeight.w700,
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
          ),
        );
      },
    );
  }


 // ===== Backend polling for admin START / COMPLETE =====
Future<void> _checkAdminTournamentUpdates() async {
  try {
    final res = await http.get(Uri.parse(_publicTournamentsUrl));
    if (res.statusCode != 200) return;

    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;

    final List<Map<String, String>> newNotifs = [];
    int newUnread = 0;

    for (final item in list) {
      final m = item as Map<String, dynamic>;
      if (m['id'] == null) continue;

      final int id = (m['id'] as num).toInt();
      final String status = (m['status'] ?? '').toString().toUpperCase();
      final String name = (m['name'] ?? '').toString();
      final String game = (m['game'] ?? '').toString();
      final String? winner =
          m['winner'] == null ? null : m['winner'].toString();

      final dynamic rawPrizeDelivered = m['prizeDelivered'];
      final bool prizeDelivered = rawPrizeDelivered == true;

      final String? oldStatus = _lastStatusById[id];

      if (oldStatus != null && oldStatus != status) {
        if (status == 'LIVE') {
          newNotifs.insert(0, {
            'title': 'Match Started: $name',
            'subtitle': 'Game: $game • Status: LIVE',
            'roomId': '-',
            'password': '-',
            'time': 'Just now',
          });
          newUnread++;
        } else if (status == 'COMPLETED') {
          final String prizeText =
              prizeDelivered ? 'Prize Delivered' : 'Prize pending';
          final String winnerLine =
              (winner != null && winner.trim().isNotEmpty)
                  ? '🏅 Winner: $winner • $prizeText'
                  : 'Match completed • $prizeText';

          newNotifs.insert(0, {
            'title': 'Match Completed: $name',
            'subtitle': winnerLine,
            'roomId': '-',
            'password': '-',
            'time': 'Just now',
          });
          newUnread++;
        }
      }

      _lastStatusById[id] = status;
    }

    if (!mounted) return;

    // Refresh tournaments from your TournamentApiService
    final backendList =
        await TournamentApiService.instance.getPublicTournaments();

    // Remove COMPLETED / CANCELLED from Home screen
    final filtered = backendList.where((t) {
      final s = t.status.toUpperCase();
      return s != 'COMPLETED' && s != 'CANCELLED';
    }).toList();

    setState(() {
      if (newNotifs.isNotEmpty) {
        _notifications.insertAll(0, newNotifs);
        _unreadNotifications += newUnread;
      }
      _tournaments = filtered;
    });
  } catch (_) {
    // ignore
  }
}
 


  static Widget _TopNavItem(String title, {VoidCallback? onTap}) {
    return _HoverTextButton(title: title, onTap: onTap);
  }

  static Widget _NewsCard({
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1724),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const Color accentColor = Color(0xFF4DD0E1);
    const Color darkCardBg = Color(0xFF0F1724);

    final headlineStyle = theme.textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w900,
      color: Colors.white,
      shadows: [
        Shadow(color: accentColor.withOpacity(0.4), blurRadius: 15.0),
        const Shadow(color: Colors.black, blurRadius: 3.0),
      ],
    );

    final sectionTitleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: accentColor.withOpacity(0.8),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0B0F18),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0B0F18),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F1724),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF4DD0E1),
                      child: Text(
                        _username.isNotEmpty
                            ? _username[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _drawerItem(Icons.home, "Home", onTap: () {
                Navigator.pop(context);
              }),
              _drawerItem(Icons.person, "My Profile", onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              }),
              _drawerItem(Icons.card_giftcard, "My Reward", onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RewardsScreen(),
                  ),
                );
              }),
              _drawerItem(Icons.phone, "Contact Us", onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactUsScreen(),
                  ),
                );
              }),
              _drawerItem(Icons.privacy_tip, "Privacy Policy", onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              }),
              _drawerItem(Icons.description, "Terms & Conditions", onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsScreen(),
                  ),
                );
              }),
              const Spacer(),
              const Divider(color: Colors.white24),
              _drawerItem(
                Icons.logout,
                "Logout",
                color: Colors.redAccent,
                onTap: () async {
                  await _logout();
                },
              ),
              _drawerItem(
                Icons.delete_forever,
                "Delete Account",
                color: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF121A22),
                      title: const Text(
                        "Delete Account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        "This action cannot be undone!",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          final isDesktop = w >= desktop;
          final isTablet = w >= phone && w < desktop;
          final isPhone = w < phone;
          final isWide = isDesktop || isTablet;

          final horizontalPadding = isPhone ? 12.0 : isTablet ? 24.0 : 48.0;

          final int leftColumnFlex = isDesktop ? 7 : 1;
          final int rightColumnFlex = isDesktop ? 3 : 1;
          final int gridCount = isDesktop ? 6 : isTablet ? 3 : 1;

          // HEADER
          Widget header = Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF071021),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.videogame_asset,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'HYPERZONE',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        fontSize: 20,
                        shadows: [
                          Shadow(
                            color: accentColor.withOpacity(0.5),
                            blurRadius: 5.0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
               if (isWide)
  Row(
    children: [
      _TopNavItem(
        'HOST',
        onTap: () {
          Navigator.pushNamed(context, '/host');
        },
      ),
      const SizedBox(width: 16),
      _TopNavItem(
        'TOURNAMENTS',
        onTap: () {
          Navigator.pushNamed(context, '/tournaments');
        },
      ),
      const SizedBox(width: 16),
     _TopNavItem(
  'WALLET',
  onTap: () {
    Navigator.pushNamed(
      context,
      '/wallet',
      arguments: {
        'balance': _walletBalance,
        'transactions': _transactions,
      },
    );
  },
),

      const SizedBox(width: 16),
      _TopNavItem(
        'LEADERBOARD',
        onTap: () {
          Navigator.pushNamed(context, '/leaderboard');
        },
      ),
      const SizedBox(width: 16),
      _TopNavItem(
        'MY HOSTED',
        onTap: () {
          Navigator.pushNamed(context, '/my-hosted');
        },
      ),
    ],
  ),

                const SizedBox(width: 16),
                // Wallet
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1720),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${_walletBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Notification bell with count
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _unreadNotifications = 0;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationsScreen(
                              notifications: _notifications,
                            ),
                          ),
                        );
                      },
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _unreadNotifications > 9
                                ? '9+'
                                : '$_unreadNotifications',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );

          // SCROLL CONTENT
          Widget scrollableContent = SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO / POSTER
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 260),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF0B0F13),
                        image: const DecorationImage(
                          image:
                              AssetImage('assets/hero_bg_placeholder.png'),
                          fit: BoxFit.cover,
                          opacity: 0.65,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isPhone ? 18 : 28,
                          vertical: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'BECOME THE',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white70,
                                fontSize: isPhone ? 14 : 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'ARENA MASTER',
                              style: headlineStyle!.copyWith(
                                fontSize: isPhone ? 28 : 44,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                // JOIN TOURNAMENT → go to /tournaments
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/tournaments');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    padding: const EdgeInsets.symmetric(
      horizontal: 22,
      vertical: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ),
  child: const Text(
    'JOIN TOURNAMENT',
    style: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(width: 12),

// HOST TOURNAMENT → go to /host
OutlinedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/host');
  },
  style: OutlinedButton.styleFrom(
    side: const BorderSide(color: Colors.white24),
    padding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ),
  child: const Text(
    'HOST TOURNAMENT',
    style: TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
    ),
  ),
),

                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // MAIN CONTENT (LEFT + RIGHT)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: leftColumnFlex,
                                child: _LeftContentColumn(
                                  isPhone: isPhone,
                                  isDesktop: isDesktop,
                                  sectionTitleStyle: sectionTitleStyle,
                                  headlineStyle: headlineStyle,
                                  gridCount: gridCount,
                                  tournaments: _tournaments,
                                  selectedLiveGame: _selectedLiveGame,
                                  onLiveGameChanged: (g) {
                                    setState(() {
                                      _selectedLiveGame = g;
                                    });
                                  },
                                  onJoinTournament: _handleJoinTournament,
                                ),
                              ),
                              const SizedBox(width: 20),
                              if (!isPhone)
                                Expanded(
                                  flex: rightColumnFlex,
                                  child: _RightSidebarColumn(
                                    darkCardBg: darkCardBg,
                                    accentColor: accentColor,
                                    sectionTitleStyle: sectionTitleStyle,
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LeftContentColumn(
                                isPhone: isPhone,
                                isDesktop: isDesktop,
                                sectionTitleStyle: sectionTitleStyle,
                                headlineStyle: headlineStyle,
                                gridCount: gridCount,
                                tournaments: _tournaments,
                                selectedLiveGame: _selectedLiveGame,
                                onLiveGameChanged: (g) {
                                  setState(() {
                                    _selectedLiveGame = g;
                                  });
                                },
                                onJoinTournament: _handleJoinTournament,
                              ),
                              const SizedBox(height: 30),
                              _RightSidebarColumn(
                                darkCardBg: darkCardBg,
                                accentColor: accentColor,
                                sectionTitleStyle: sectionTitleStyle,
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 48),

                  // CYBER NEWS SECTION
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CYBER ZONE NEWS & UPDATES',
                          style: sectionTitleStyle,
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isPhone ? 1 : 3,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                            mainAxisExtent: 180,
                          ),
                          itemBuilder: (context, idx) {
                            if (idx == 2) {
                              return _SubscribeCard(
                                accentColor: accentColor,
                              );
                            }
                            if (idx == 0) {
                              return _NewsCard(
                                title:
                                    'PUBG Mobile / BGMI Esports 2025 Roadmap',
                                subtitle:
                                    'New LAN events and a massive ₹2 Cr prize pool season.',
                                imagePath: 'assets/games/bgmi_bg.jpg',
                              );
                            }
                            return _NewsCard(
                              title:
                                  'Valorant Champions Tour: Asia Qualifiers',
                              subtitle:
                                  'Top teams from India and SEA fight for a spot at VCT Masters.',
                              imagePath: 'assets/games/valorant_bg.jpg',
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      '© ${DateTime.now().year} Hyperzone',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                header,
                const SizedBox(height: 8),
                Expanded(child: scrollableContent),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String label, {
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }
}

// ===== Small hover nav button =====

class _HoverTextButton extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const _HoverTextButton({
    required this.title,
    this.onTap,
  });

  @override
  State<_HoverTextButton> createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<_HoverTextButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const Color normal = Colors.white70;
    const Color hoverColor = Color(0xFF4DD0E1);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          style: TextStyle(
            color: _hovered ? hoverColor : normal,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            shadows: _hovered
                ? const [
                    Shadow(
                      color: Color(0x804DD0E1),
                      blurRadius: 10,
                    ),
                  ]
                : const [],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(widget.title),
          ),
        ),
      ),
    );
  }
}

// ===== LEFT COLUMN (HYPERZONE, BIG PRIZE, LIVE, UPCOMING) =====

class _LeftContentColumn extends StatelessWidget {
  final bool isPhone;
  final bool isDesktop;
  final TextStyle? sectionTitleStyle;
  final TextStyle? headlineStyle;
  final int gridCount;
  final List<Tournament> tournaments;
  final String selectedLiveGame;
  final ValueChanged<String> onLiveGameChanged;
  final void Function(Tournament) onJoinTournament;

  const _LeftContentColumn({
    required this.isPhone,
    required this.isDesktop,
    required this.sectionTitleStyle,
    required this.headlineStyle,
    required this.gridCount,
    required this.tournaments,
    required this.selectedLiveGame,
    required this.onLiveGameChanged,
    required this.onJoinTournament,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkCardBg = Color(0xFF0E1720);

    final now = DateTime.now();

    // 1) Filter out COMPLETED / CANCELLED for Home screen only
    final List<Tournament> playable = tournaments.where((t) {
      final s = t.status.toUpperCase();
      return s != 'COMPLETED' && s != 'CANCELLED';
    }).toList();

    // Upcoming = future by startTime (fallback: all playable)
    var upcoming = playable
        .where((t) => t.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (upcoming.isEmpty && playable.isNotEmpty) {
      upcoming = List<Tournament>.from(playable)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    // Big prize = prize > 100000 (only from playable)
    final bigPrize =
        playable.where((t) => t.prizePool > 100000).toList();

    // Hyperzone tournaments = hosted by Admin only (only from playable)
    final hyperzoneTournaments = playable.where((t) {
      final host = t.hostUserId?.toLowerCase() ?? '';
      return host == 'admin';
    }).toList();

    // LIVE tournaments:
    // use only LIVE + streamUrl from playable
    final liveBaseRaw = playable.where((t) {
      final hasStream =
          t.streamUrl != null && t.streamUrl!.trim().isNotEmpty;
      final s = t.status.toUpperCase();
      return hasStream && s == 'LIVE';
    }).toList();

    final bool anyRealLive = liveBaseRaw.isNotEmpty;
    final List<Tournament> liveSource =
        anyRealLive ? liveBaseRaw : playable;

    List<Tournament> liveFiltered;
    if (selectedLiveGame == 'All') {
      liveFiltered = liveSource;
    } else {
      liveFiltered =
          liveSource.where((t) => t.game == selectedLiveGame).toList();
    }

    final Tournament? liveMain =
        liveFiltered.isNotEmpty ? liveFiltered[0] : null;
    final Tournament? liveSecond =
        liveFiltered.length > 1 ? liveFiltered[1] : null;
    final Tournament? liveThird =
        liveFiltered.length > 2 ? liveFiltered[2] : null;

    final List<Widget> liveRowChildren = [];
    liveRowChildren.add(
      Expanded(
        child: _LivePlayerCard(
          darkCardBg: darkCardBg,
          liveTournament: liveMain,
        ),
      ),
    );
    if (!isPhone) {
      liveRowChildren.add(const SizedBox(width: 16));
      liveRowChildren.add(
        Expanded(
          child: _LivePlayerCard(
            darkCardBg: darkCardBg,
            liveTournament: liveSecond,
          ),
        ),
      );
    }
    if (isDesktop) {
      liveRowChildren.add(const SizedBox(width: 16));
      liveRowChildren.add(
        Expanded(
          child: _LivePlayerCard(
            darkCardBg: darkCardBg,
            liveTournament: liveThird,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HYPERZONE TOURNAMENTS
        if (hyperzoneTournaments.isNotEmpty) ...[
          Text(
            'HYPERZONE TOURNAMENTS',
            style: sectionTitleStyle?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hyperzoneTournaments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (ctx, i) => _BigPrizeCard(
                tournament: hyperzoneTournaments[i],
                onJoin: onJoinTournament,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // BIG PRIZE POOL
        if (bigPrize.isNotEmpty) ...[
          Text(
            'BIG PRIZE POOL TOURNAMENTS',
            style: sectionTitleStyle?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bigPrize.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (ctx, i) => _BigPrizeCard(
                tournament: bigPrize[i],
                onJoin: onJoinTournament,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // LIVE EVENTS
        Text(
          'LIVE EVENTS',
          style: headlineStyle?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _LiveFilterChip(
              label: 'ALL',
              selected: selectedLiveGame == 'All',
              onTap: () => onLiveGameChanged('All'),
            ),
            _LiveFilterChip(
              label: 'VALORANT',
              selected: selectedLiveGame == 'Valorant',
              onTap: () => onLiveGameChanged('Valorant'),
            ),
            _LiveFilterChip(
              label: 'BGMI',
              selected: selectedLiveGame == 'BGMI',
              onTap: () => onLiveGameChanged('BGMI'),
            ),
            _LiveFilterChip(
              label: 'FREE FIRE',
              selected: selectedLiveGame == 'Free Fire',
              onTap: () => onLiveGameChanged('Free Fire'),
            ),
            _LiveFilterChip(
              label: 'CS:GO',
              selected: selectedLiveGame == 'CS:GO',
              onTap: () => onLiveGameChanged('CS:GO'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: liveRowChildren,
        ),
        const SizedBox(height: 32),

        // ONGOING & UPCOMING MATCHES
        Text('ONGOING & UPCOMING MATCHES', style: sectionTitleStyle),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcoming.length.clamp(0, 6),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: isPhone ? 150 : 170,
          ),
          itemBuilder: (context, idx) {
            final t = upcoming[idx];
            return _TournamentFromModelCard(
              t: t,
              onJoin: onJoinTournament,
            );
          },
        ),
      ],
    );
  }
}


// ===== live filter chip =====

class _LiveFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LiveFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color neonBlue = Color(0xFF4DD0E1);
    const Color darkBg = Color(0xFF0D151A);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? neonBlue : darkBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ===== LIVE player big card =====

class _LivePlayerCard extends StatelessWidget {
  final Color darkCardBg;
  final Tournament? liveTournament;

  const _LivePlayerCard({
    required this.darkCardBg,
    this.liveTournament,
  });

  String _gameImagePath(String game) {
    switch (game) {
      case 'Valorant':
        return 'assets/games/valorant_bg.jpg';
      case 'BGMI':
        return 'assets/games/bgmi_bg.jpg';
      case 'Free Fire':
        return 'assets/games/freefire_bg.jpg';
      case 'CS:GO':
        return 'assets/games/csgo_bg.jpg';
      default:
        return 'assets/stream_placeholder.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTournament = liveTournament != null;
    final String bgImage = hasTournament
        ? _gameImagePath(liveTournament!.game)
        : 'assets/stream_placeholder.jpg';

    final String titleText = hasTournament
        ? 'Watch Live: ${liveTournament!.name}'
        : 'Watch Live Event';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasTournament
    ? () {
        Navigator.pushNamed(
          context,
          '/live',
          arguments: liveTournament,
        );
      }
    : null,

          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: darkCardBg,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(bgImage),
                  fit: BoxFit.cover,
                  opacity: 0.4,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}






// ===== Live info small card (unused currently) =====

class _LiveInfoCard extends StatelessWidget {
  final Tournament? liveTournament;

  const _LiveInfoCard({this.liveTournament});

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFF101624);
    const Color accent = Color(0xFF4DD0E1);
    const Color neonPink = Color(0xFFFF4DAB);

    final hasLive = liveTournament != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: hasLive
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: neonPink,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'LIVE',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  liveTournament!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prize: ₹${liveTournament!.prizePool}',
                  style: const TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mode: ${liveTournament!.mode}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'New Feature: Automated match reporting',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            )
                    : const Center(
              child: Text(
                'Next event coming soon',
                style: TextStyle(color: Colors.white70),
              ),
            ),
    );
  }
}

// ===== RIGHT SIDEBAR =====

class _RightSidebarColumn extends StatelessWidget {
  final Color darkCardBg;
  final Color accentColor;
  final TextStyle? sectionTitleStyle;

  const _RightSidebarColumn({
    required this.darkCardBg,
    required this.accentColor,
    required this.sectionTitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        _SidebarCard(
          title: 'QUICK ACCESS',
          titleStyle: sectionTitleStyle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Upcoming Match: Hyperzone Grand Masters - 7 PM IST',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                'Recent Activity: Win +₹250',
                style: TextStyle(color: accentColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SidebarCard(
          title: 'FEATURED STREAMERS',
          titleStyle: sectionTitleStyle,
          child: Column(
            children: const [
              _StreamerItem(
                name: 'Scout',
                status: 'BGMI • 8 PM Daily',
                youtubeUrl: 'https://www.youtube.com/@scoutop',
              ),
              _StreamerItem(
                name: 'Jonathan Gaming',
                status: 'BGMI • Scrims & T1',
                youtubeUrl: 'https://www.youtube.com/@JonathanGamingYT',
              ),
              _StreamerItem(
                name: 'Mortal',
                status: 'Variety • Watch Parties',
                youtubeUrl: 'https://www.youtube.com/@MortaL',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SidebarCard(
          title: 'NEW BADGES & EMBLEMS',
          titleStyle: sectionTitleStyle,
          child: Column(
            children: const [
              _EmblemItem(
                name: 'Tactical Ace',
                value: '+823',
              ),
              _EmblemItem(
                name: 'Clutch King',
                value: '+5',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarCard extends StatelessWidget {
  final String title;
  final Widget child;
  final TextStyle? titleStyle;

  const _SidebarCard({
    required this.title,
    required this.child,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkCardBg = Color(0xFF0F1720);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ===== Streamer item (YouTube follow) =====

class _StreamerItem extends StatelessWidget {
  final String name;
  final String status;
  final String youtubeUrl;

  const _StreamerItem({
    required this.name,
    required this.status,
    required this.youtubeUrl,
  });

  @override
  Widget build(BuildContext context) {
    const Color neonBlue = Color(0xFF4DD0E1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF0D1720),
            child: Icon(Icons.person, color: Colors.white70),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(youtubeUrl);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: neonBlue,
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}

class _EmblemItem extends StatelessWidget {
  final String name;
  final String value;

  const _EmblemItem({
    required this.name,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF4DD0E1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: accentColor, size: 20),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== HYPERZONE OFFICIAL TOURNAMENT CARD (kept for future) =====

class _HyperzoneTournamentCard extends StatefulWidget {
  final Tournament t;
  final void Function(Tournament) onJoin;

  const _HyperzoneTournamentCard({
    required this.t,
    required this.onJoin,
  });

  @override
  State<_HyperzoneTournamentCard> createState() =>
      _HyperzoneTournamentCardState();
}

class _HyperzoneTournamentCardState extends State<_HyperzoneTournamentCard> {
  bool _hover = false;

  String _gameImagePath(String game) {
    switch (game) {
      case 'Valorant':
        return 'assets/games/valorant_bg.jpg';
      case 'BGMI':
        return 'assets/games/bgmi_bg.jpg';
      case 'Free Fire':
        return 'assets/games/freefire_bg.jpg';
      case 'CS:GO':
        return 'assets/games/csgo_bg.jpg';
      default:
        return 'assets/stream_placeholder.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF4DD0E1);
    const Color officialTag = Color(0xFFFF4DAB);

    final t = widget.t;
    final bgImage = _gameImagePath(t.game);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: 260,
        height: 150,
        margin: const EdgeInsets.only(right: 4),
        transform:
            _hover ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: const Color(0xFF101624),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hover ? accent : Colors.white12,
            width: 1,
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Left image
            Container(
              width: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(bgImage),
                  fit: BoxFit.cover,
                  opacity: 0.9,
                ),
              ),
            ),

            // Right content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OFFICIAL pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: officialTag,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'OFFICIAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'HYPERZONE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      t.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t.game} • ${t.mode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),

                    // Prize + entry
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prize Pool',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '₹${t.prizePool}',
                              style: const TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Entry',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              t.entryFee == 0
                                  ? 'Free'
                                  : '₹${t.entryFee.toString()}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () => widget.onJoin(t),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Big prize card =====

class _BigPrizeCard extends StatefulWidget {
  final Tournament tournament;
  final void Function(Tournament) onJoin;

  const _BigPrizeCard({
    required this.tournament,
    required this.onJoin,
  });

  @override
  State<_BigPrizeCard> createState() => _BigPrizeCardState();
}

class _BigPrizeCardState extends State<_BigPrizeCard> {
  bool _hover = false;

  String _gameImagePath(String game) {
    switch (game) {
      case 'Valorant':
        return 'assets/games/valorant_bg.jpg';
      case 'BGMI':
        return 'assets/games/bgmi_bg.jpg';
      case 'Free Fire':
        return 'assets/games/freefire_bg.jpg';
      case 'CS:GO':
        return 'assets/games/csgo_bg.jpg';
      default:
        return 'assets/stream_placeholder.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF4DD0E1);

    final t = widget.tournament;
    final bgImage = _gameImagePath(t.game);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 260,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hover ? accent : Colors.white12,
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                bgImage,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.game,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Prize: ₹${t.prizePool}',
                    style: const TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Entry: ${t.entryFee == 0 ? "Free" : "₹${t.entryFee}"}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => widget.onJoin(t),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
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

// ===== ONGOING & UPCOMING match card =====

class _TournamentFromModelCard extends StatefulWidget {
  final Tournament t;
  final void Function(Tournament) onJoin;

  const _TournamentFromModelCard({
    required this.t,
    required this.onJoin,
  });

  @override
  State<_TournamentFromModelCard> createState() =>
      _TournamentFromModelCardState();
}

class _TournamentFromModelCardState extends State<_TournamentFromModelCard> {
  bool _hover = false;

  String _gameImagePath(String game) {
    switch (game) {
      case 'Valorant':
        return 'assets/games/valorant_bg.jpg';
      case 'BGMI':
        return 'assets/games/bgmi_bg.jpg';
      case 'Free Fire':
        return 'assets/games/freefire_bg.jpg';
      case 'CS:GO':
        return 'assets/games/csgo_bg.jpg';
      default:
        return 'assets/stream_placeholder.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFF101624);
    const Color accent = Color(0xFF4DD0E1);

    final t = widget.t;
    final bgImage = _gameImagePath(t.game);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Transform.scale(
        scale: _hover ? 1.02 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hover ? accent : Colors.white12,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(bgImage),
                      fit: BoxFit.cover,
                      opacity: 0.7,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${t.game} • ${t.mode}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Entry: ${t.entryFee == 0 ? "Free" : "₹${t.entryFee}"}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Prize: ₹${t.prizePool}',
                        style: const TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onJoin(t);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Join',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Subscribe card =====

class _SubscribeCard extends StatelessWidget {
  final Color accentColor;
  const _SubscribeCard({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    const Color neonPink = Color(0xFFFF4DAB);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1724),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'New build: Gearbred Neighborhood',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: neonPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'Subscribe',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== NOTIFICATIONS SCREEN =====

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> notifications;

  const NotificationsScreen({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1724),
        elevation: 0,
        title: const Text(
          'Notifications',
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
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet.\nJoin tournaments to see updates here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101624),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0, right: 8),
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.cyanAccent,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n['subtitle'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Room ID: ${n['roomId'] ?? '-'}  |  Password: ${n['password'] ?? '-'}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        n['time'] ?? '',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

