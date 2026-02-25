import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/tournament_repository.dart';
import '../models/tournament.dart';

class LiveNowSection extends StatelessWidget {
  const LiveNowSection({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TournamentRepository.instance;
    final List<Tournament> live = repo.getLiveTournaments();

    if (live.isEmpty) {
      return const SizedBox.shrink(); // no live tournament → show nothing
    }

    final Tournament t = live.last; // latest live tournament

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Live now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _LiveCard(tournament: t),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  final Tournament tournament;

  const _LiveCard({required this.tournament});

  String _gameImagePath() {
    switch (tournament.game) {
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

  Future<void> _openStream(BuildContext context) async {
    final raw = tournament.streamUrl;
    if (raw == null || raw.trim().isEmpty) return;

    String url = raw.trim();
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open stream link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF4DD0E1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _gameImagePath(),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tournament.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tournament.game,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mode: ${tournament.mode} • Prize: ₹${tournament.prizePool}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openStream(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Watch now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
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
