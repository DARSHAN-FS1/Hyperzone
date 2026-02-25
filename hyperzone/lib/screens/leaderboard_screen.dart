import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0B0F18);
    const Color cardBg = Color(0xFF101624);
    const Color accent = Color(0xFF4DD0E1);

    final players = [
      {'rank': 1, 'name': 'ToxicRanger', 'points': 1620, 'earnings': 4800},
      {'rank': 2, 'name': 'ShadowNova', 'points': 1490, 'earnings': 3900},
      {'rank': 3, 'name': 'PixelSniper', 'points': 1380, 'earnings': 3200},
      {'rank': 4, 'name': 'CrimsonWolf', 'points': 1205, 'earnings': 2100},
      {'rank': 5, 'name': 'CyberGhost', 'points': 1120, 'earnings': 1800},
      {'rank': 6, 'name': 'MetalFury', 'points': 980, 'earnings': 1200},
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1724),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top players this season',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ranked by points and total winnings in ₹',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final p = players[index];
                    return _LeaderCard(
                      rank: p['rank'] as int,
                      name: p['name'].toString(),
                      points: p['points'] as int,
                      earnings: p['earnings'] as int,
                      cardBg: cardBg,
                      accent: accent,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderCard extends StatefulWidget {
  final int rank;
  final String name;
  final int points;
  final int earnings;
  final Color cardBg;
  final Color accent;

  const _LeaderCard({
    required this.rank,
    required this.name,
    required this.points,
    required this.earnings,
    required this.cardBg,
    required this.accent,
  });

  @override
  State<_LeaderCard> createState() => _LeaderCardState();
}

class _LeaderCardState extends State<_LeaderCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final rank = widget.rank;

    Color badgeColor;
    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32);
    } else {
      badgeColor = const Color(0xFF1F2933);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rank <= 3
                ? widget.accent
                : _hovered
                    ? widget.accent.withOpacity(0.5)
                    : Colors.white12,
            width: rank <= 3 ? 1.4 : 1,
          ),
          boxShadow: _hovered || rank <= 3
              ? [
                  BoxShadow(
                    color: widget.accent.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.points} pts',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${widget.earnings}',
                  style: TextStyle(
                    color: widget.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Winnings',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
