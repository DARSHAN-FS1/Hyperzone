import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TournamentWinnersScreen extends StatelessWidget {
  final String tournamentName;
  final List<Map<String, dynamic>> winners;

  const TournamentWinnersScreen({
    super.key,
    required this.tournamentName,
    required this.winners,
  });

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0B0F18);
    const Color cardBg = Color(0xFF121825);
    const Color accent = Color(0xFF4DD0E1);

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
          'Winners',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final msg = _buildShareMessage();
              Share.share(
                msg,
                subject: 'Winners of $tournamentName',
              );
            },
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tournamentName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Final standings & prize distribution',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: winners.isEmpty
                    ? const Center(
                        child: Text(
                          'No winner data available yet.',
                          style: TextStyle(color: Colors.white60),
                        ),
                      )
                    : ListView.builder(
                        itemCount: winners.length,
                        itemBuilder: (context, index) {
                          final w = winners[index];
                          return _WinnerCard(
                            winner: w,
                            accent: accent,
                            cardBg: cardBg,
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

  String _buildShareMessage() {
    if (winners.isEmpty) {
      return 'Final standings for $tournamentName are not available yet.';
    }

    final buffer = StringBuffer();
    buffer.writeln('🏆 Winners of $tournamentName');
    buffer.writeln('');

    for (final w in winners) {
      buffer.writeln(
        '#${w['rank']} - ${w['name']} (${w['team']}) '
        '• Kills: ${w['kills']} • Prize: ₹${w['prize']}',
      );
    }

    buffer.writeln('');
    buffer.writeln('Played on HYPERZONE 🎮');

    return buffer.toString();
  }
}

class _WinnerCard extends StatefulWidget {
  final Map<String, dynamic> winner;
  final Color accent;
  final Color cardBg;

  const _WinnerCard({
    required this.winner,
    required this.accent,
    required this.cardBg,
  });

  @override
  State<_WinnerCard> createState() => _WinnerCardState();
}

class _WinnerCardState extends State<_WinnerCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.winner;
    final rank = w['rank'] as int;
    final name = w['name'].toString();
    final team = w['team'].toString();
    final kills = w['kills'] as int;
    final prize = w['prize'] as int;

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
            color: rank == 1
                ? widget.accent
                : _hovered
                    ? widget.accent.withOpacity(0.5)
                    : Colors.white12,
            width: rank == 1 ? 1.4 : 1,
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
            _RankBadge(rank: rank),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          team,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.sports_esports,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kills: $kills',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prize > 0 ? '₹$prize' : '—',
                  style: TextStyle(
                    color: widget.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Prize',
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

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  Color _bgColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF1F2933);
    }
  }

  Color _textColor() {
    if (rank <= 3) return Colors.black;
    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _bgColor(),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          color: _textColor(),
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}
