import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import '../theme.dart';
import 'admin_login_screen.dart';

const Color kPrimaryColor = Color(0xFF007BFF);
const Color kBackgroundColor = Color(0xFF0C0F16);
const Color kCardColor = Color(0xFF1A1E26);
const Color kAccentColor = Color(0xFF00C7FF);
const Color kTextColor = Colors.white;

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildHeroSection(isDesktop, context),
              const SizedBox(height: 50),
              const CredibilityStrip(),
              const SizedBox(height: 80),
              const FeatureBreakdownSection(),
              const SizedBox(height: 80),
              const WalletSection(),
              const SizedBox(height: 80),
              const FinalCTABanner(),
              const SizedBox(height: 100),
              const HyperZoneFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'HYPERZONE',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: kAccentColor,
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              if (screenWidth > 600)
                ...['Features', 'Pricing', 'Support'].map(
                  (t) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t, style: const TextStyle(color: kTextColor)),
                  ),
                ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  );
                },
                child: const Text(
                  "Admin",
                  style: TextStyle(
                    color: kAccentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text("Login", style: TextStyle(color: kTextColor)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Sign Up Free',
                  style: TextStyle(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, BuildContext context) {
    return Container(
      height: isDesktop ? 600 : 420,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/hero_bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.65,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 110 : 25),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE ESPORTS BATTLEGROUND\nFOR CHAMPIONS',
            style: TextStyle(
              fontSize: isDesktop ? 60 : 34,
              fontWeight: FontWeight.w900,
              color: kTextColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Host tournaments. Join battles. Earn rewards.\nNo chaos. Just pure competitive domination.',
            style: TextStyle(fontSize: 18, color: Color(0xFFD0D0D0)),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildCTAButton(context, 'Start Hosting Now'),
              const SizedBox(width: 15),
              _buildCTAButton(context, 'Find Your Tournament', primary: false),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '₹1,20,000+ in tournament prizes every month',
            style: TextStyle(color: Color(0xFF8FA4C3), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context, String text,
      {bool primary = true}) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/signup'),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? kPrimaryColor : Colors.transparent,
        foregroundColor: primary ? kTextColor : kPrimaryColor,
        side: primary ? BorderSide.none : BorderSide(color: kPrimaryColor, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class CredibilityStrip extends StatelessWidget {
  const CredibilityStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final gameLogos = ['CS2', 'DOTA2', 'VALORANT', 'APEX', 'BGMI'];

    return Column(
      children: [
        const Text(
          'PLAYERS FROM THE BEST GAMES.',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: gameLogos
              .map(
                (logo) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    logo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kAccentColor,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class FeatureBreakdownSection extends StatelessWidget {
  const FeatureBreakdownSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 850;

    final features = [
      {
        'icon': Icons.emoji_events,
        'title': 'HOST & MANAGE',
        'desc':
            'Build brackets, set rules, automate scoring. Run pro-grade tournaments without stress.',
      },
      {
        'icon': Icons.sports_esports,
        'title': 'COMPETE & RISE',
        'desc':
            'Join ranked tournaments across top titles. Dominate leaderboards. Claim glory.',
      },
      {
        'icon': Icons.lock_clock_outlined,
        'title': 'INSTANT PAYOUTS',
        'desc':
            'Entry fees & winnings processed securely. Withdraw instantly to your wallet.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  features.map((f) => Expanded(child: FeatureCard(data: f))).toList(),
            )
          : Column(children: features.map((f) => FeatureCard(data: f)).toList()),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const FeatureCard({required this.data, super.key});

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(26),
        transform: hovered
            ? Matrix4.diagonal3Values(1.03, 1.03, 1)
            : Matrix4.diagonal3Values(1, 1, 1),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kAccentColor.withOpacity(0.3), width: 1),
          boxShadow: hovered
              ? [BoxShadow(color: kAccentColor.withOpacity(0.4), blurRadius: 14)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.data['icon'], size: 42, color: kAccentColor),
            const SizedBox(height: 15),
            Text(
              widget.data['title'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kAccentColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.data['desc'],
              style: const TextStyle(fontSize: 15, color: Color(0xFFC0C0C0)),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletSection extends StatefulWidget {
  const WalletSection({super.key});

  @override
  State<WalletSection> createState() => _WalletSectionState();
}

class _WalletSectionState extends State<WalletSection> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 850;

    final walletInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'MONEY MOVES.\nFULLY SECURED WALLET.',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: kTextColor,
          ),
        ),
        SizedBox(height: 18),
        Text(
          '• Add & withdraw funds instantly\n'
          '• Zero fees on deposits\n'
          '• Track tournament history & rewards',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );

    final walletCard = Container(
      width: isDesktop ? 300 : 260,
      height: 220,
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentColor.withOpacity(0.7), width: 2),
      ),
      padding: const EdgeInsets.all(22),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '₹12,345.67',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: kAccentColor,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'HyperZone Wallet',
            style: TextStyle(
              color: Color(0xFFC0C0C0),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24),
      child: MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          transform: hovered
              ? Matrix4.diagonal3Values(1.01, 1.01, 1)
              : Matrix4.diagonal3Values(1, 1, 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5B4B8A),
                Color(0xFFB3A5FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 24,
            vertical: isDesktop ? 40 : 28,
          ),
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: walletInfo),
                    const SizedBox(width: 40),
                    walletCard,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    walletInfo,
                    const SizedBox(height: 24),
                    Center(child: walletCard),
                  ],
                ),
        ),
      ),
    );
  }
}

class FinalCTABanner extends StatefulWidget {
  const FinalCTABanner({super.key});

  @override
  State<FinalCTABanner> createState() => _FinalCTABannerState();
}

class _FinalCTABannerState extends State<FinalCTABanner> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 900 ? 900.0 : 700.0;

    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          transform: hovered
              ? Matrix4.diagonal3Values(1.01, 1.01, 1)
              : Matrix4.diagonal3Values(1, 1, 1),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(6),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.white24,
              ),
              const SizedBox(height: 28),
              const Text(
                'JOIN THE BATTLEFIELD.\nBECOME A LEGEND.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: kTextColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    'COMPETE NOW',
                    style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HyperZoneFooter extends StatefulWidget {
  const HyperZoneFooter({super.key});
  @override
  State<HyperZoneFooter> createState() => _HyperZoneFooterState();
}

class _HyperZoneFooterState extends State<HyperZoneFooter> {
  double fbSize = 24;
  double ytSize = 24;
  double dcSize = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 35),
      color: kBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Text('Company', style: TextStyle(color: Color(0xFF8FA4C3))),
              SizedBox(width: 20),
              Text('Support', style: TextStyle(color: Color(0xFF8FA4C3))),
              SizedBox(width: 20),
              Text('Privacy', style: TextStyle(color: Color(0xFF8FA4C3))),
            ],
          ),
          Row(
            children: [
              MouseRegion(
                onEnter: (_) => setState(() => fbSize = 30),
                onExit: (_) => setState(() => fbSize = 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.facebook, size: fbSize, color: kAccentColor),
                ),
              ),
              const SizedBox(width: 18),
              MouseRegion(
                onEnter: (_) => setState(() => ytSize = 30),
                onExit: (_) => setState(() => ytSize = 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.youtube_searched_for,
                    size: ytSize,
                    color: kAccentColor,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              MouseRegion(
                onEnter: (_) => setState(() => dcSize = 30),
                onExit: (_) => setState(() => dcSize = 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.discord, size: dcSize, color: kAccentColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
