// lib/widgets/widgets.dart
import 'package:flutter/material.dart';

// --- Reusable Text and Headers ---
class NavText extends StatelessWidget {
  final String title;
  const NavText(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// --- 1. Hero Section ---
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B2240),
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 30, top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BECOME THE',
              style: TextStyle(
                  color: Colors.white, fontSize: 20, letterSpacing: 2),
            ),
            Text(
              'ARENA MASTER',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.0),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                PrimaryButton('JOIN TOURNAMENT',
                    color: Color(0xFF4DD0E1)), 
                SizedBox(width: 12),
                PrimaryButton('HOST TOURNAMENT',
                    color: Colors.transparent, borderColor: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Button Widget
class PrimaryButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color? borderColor;

  const PrimaryButton(this.text,
      {super.key, required this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: color,
        side: BorderSide(color: borderColor ?? color),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: borderColor == null ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13),
      ),
    );
  }
}

// --- Tournament Carousel ---
class TournamentCarousel extends StatelessWidget {
  const TournamentCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 12),
            child: TournamentCard(isTrending: true),
          );
        },
      ),
    );
  }
}

// --- Tournament Filter Tabs ---
class TournamentFilterTabs extends StatelessWidget {
  const TournamentFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: const [
        FilterButton('ALL', isSelected: true),
        FilterButton('SOLO'),
        FilterButton('TEAM'),
        FilterButton('FREE ENTRY'),
      ],
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  const FilterButton(this.text, {super.key, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF4DD0E1) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }
}

// --- Tournament List ---
class TournamentList extends StatelessWidget {
  const TournamentList({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int cross = 1;
    if (width > 1200) cross = 3;
    else if (width > 800) cross = 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) => const TournamentCard(),
    );
  }
}

class TournamentCard extends StatelessWidget {
  final bool isTrending;
  const TournamentCard({super.key, this.isTrending = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2240),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / header area
          Container(
            height: isTrending ? 120 : 90,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Center(child: Icon(Icons.videogame_asset, color: Colors.white54)),
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isTrending ? '\$10,000 PRIZE POOL' : 'Valorant Cup',
                    style: TextStyle(
                        color: isTrending ? const Color(0xFF4DD0E1) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isTrending ? 14 : 13)),
                const SizedBox(height: 6),
                Text(isTrending ? 'Apex Legends Tournament' : 'Starts: 7:00 PM IST',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          if (isTrending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton('JOIN NOW', color: Colors.redAccent, borderColor: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Quick Access Card ---
class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2240),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Upcoming Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Text('Halo Infinite - 7 PM IST', style: TextStyle(color: Colors.white70)),
          const Divider(color: Colors.white12, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Win +\$25', style: TextStyle(color: Colors.greenAccent[400], fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Top Players & News ---
class TopPlayersList extends StatelessWidget {
  const TopPlayersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(3, (index) => const PlayerListItem(name: 'HairyBoss', stat: '+983 points')));
  }
}

class PlayerListItem extends StatelessWidget {
  final String name;
  final String stat;
  const PlayerListItem({super.key, required this.name, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        const CircleAvatar(backgroundColor: Color(0xFF4A4E6C), radius: 15, child: Icon(Icons.person, size: 18, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Text(stat, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }
}

class NewsFeedList extends StatelessWidget {
  const NewsFeedList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(3, (index) => const NewsListItem(title: 'New Feature: Automated Reporting', date: '3h ago')));
  }
}

class NewsListItem extends StatelessWidget {
  final String title;
  final String date;
  const NewsListItem({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      Text(date, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ]));
  }
}

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      SectionHeader('HOW IT WORKS'),
      SizedBox(height: 8),
      Text('1) Sign up and join\n2) Play matches\n3) Win & cash out', style: TextStyle(color: Colors.white70)),
    ]);
  }
}
