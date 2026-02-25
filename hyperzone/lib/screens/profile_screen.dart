import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // You can later replace this with real user data from backend
  final String username = "Darshan Chandankhede";
  final String handle = "@hyper_darshan";
  final String email = "darshan@example.com";
  final int rank = 12;
  final int totalCoins = 4850;  // in-app coins
  final int totalMatches = 67;
  final int wins = 19;
  final double totalEarnings = 32750; // in ₹

  final List<TournamentHistory> history = [
    TournamentHistory(
      title: "Hyperzone Elite Clash",
      game: "BGMI Custom Lobby",
      date: "28 Nov 2025 • 9:30 PM",
      position: "1st",
      prizeMoney: 7500,
      kills: 12,
      points: 98,
      isWin: true,
    ),
    TournamentHistory(
      title: "Midnight Rush Arena",
      game: "Valorant 5v5",
      date: "26 Nov 2025 • 11:00 PM",
      position: "3rd",
      prizeMoney: 2500,
      kills: 22,
      points: 76,
      isWin: false,
    ),
    TournamentHistory(
      title: "Daily Grind Scrims",
      game: "BGMI TDM",
      date: "24 Nov 2025 • 7:15 PM",
      position: "2nd",
      prizeMoney: 5200,
      kills: 17,
      points: 84,
      isWin: false,
    ),
    TournamentHistory(
      title: "Sunday Showdown",
      game: "Free Fire MAX",
      date: "17 Nov 2025 • 4:00 PM",
      position: "1st",
      prizeMoney: 10000,
      kills: 9,
      points: 91,
      isWin: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050814) : const Color(0xFFF3F5FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 18),
            _buildStatsRow(context),
            const SizedBox(height: 24),
            Text(
              "Match History",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _HistoryCard(item: history[index]);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B2140),
            Color(0xFF272F56),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: -8,
            offset: Offset(0, 12),
            color: Colors.black54,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF5AF2D6),
                width: 2,
              ),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF313A6B),
                  Color(0xFF151A33),
                ],
              ),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "U",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  handle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 15,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildChip(
                      icon: Icons.military_tech_rounded,
                      label: "Rank #$rank",
                    ),
                    _buildChip(
                      icon: Icons.stars_rounded,
                      label: "$totalCoins Coins",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF5AF2D6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final winRate =
        totalMatches == 0 ? 0 : ((wins / totalMatches) * 100).round();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: "Matches",
            value: "$totalMatches",
            subtitle: "Total played",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: "Win rate",
            value: "$winRate%",
            subtitle: "Win percentage",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: "Earnings",
            value: "₹${totalEarnings.toStringAsFixed(0)}",
            subtitle: "Total winnings",
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF111629) : Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: -6,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.45),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white38 : Colors.black45,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentHistory {
  final String title;
  final String game;
  final String date;
  final String position;
  final double prizeMoney;
  final int kills;
  final int points;
  final bool isWin;

  TournamentHistory({
    required this.title,
    required this.game,
    required this.date,
    required this.position,
    required this.prizeMoney,
    required this.kills,
    required this.points,
    required this.isWin,
  });
}

class _HistoryCard extends StatefulWidget {
  final TournamentHistory item;

  const _HistoryCard({required this.item});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _isHovering = false;

  void _setHover(bool hover) {
    if (!kIsWeb) return; // only animate hover for web
    setState(() {
      _isHovering = hover;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF101427) : Colors.white;

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: _isHovering
            ? (Matrix4.identity()..scale(1.02))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: baseColor,
          boxShadow: [
            if (_isHovering)
              BoxShadow(
                blurRadius: 18,
                spreadRadius: -10,
                offset: const Offset(0, 14),
                color: Colors.black.withOpacity(0.7),
              )
            else
              BoxShadow(
                blurRadius: 10,
                spreadRadius: -8,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.5),
              ),
          ],
          border: Border.all(
            color: item.isWin
                ? const Color(0xFF4BE6C1).withOpacity(0.7)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Left: Icon + status bar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: item.isWin
                        ? const [Color(0xFF4BE6C1), Color(0xFF1EADFF)]
                        : const [Color(0xFF666C89), Color(0xFF3B425C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  item.isWin ? Icons.emoji_events_rounded : Icons.sports_esports,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              // Mid: Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.game,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black54,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                isDark ? Colors.white38 : Colors.black45,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Right: stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: item.isWin
                          ? const Color(0xFF163E2D)
                          : const Color(0xFF3B3044),
                    ),
                    child: Text(
                      item.isWin ? "WIN • ${item.position}" : item.position,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.isWin
                            ? const Color(0xFF4BE6C1)
                            : const Color(0xFFE0C0FF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹${item.prizeMoney.toStringAsFixed(0)}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Kills ${item.kills} • ${item.points} pts",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
