import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color darkBg = Color(0xFF070A11);
  static const Color cardBg = Color(0xFF101624);
  static const Color neonBlue = Color(0xFF00FFFF);
  static const Color highlightColor = Color(0xFF4C5874);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBg, const Color(0xFF0B0F18)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: cardBg.withOpacity(0.8),
              expandedHeight: 80.0,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        color: neonBlue.withOpacity(0.5),
                        blurRadius: 5,
                      )
                    ],
                  ),
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: neonBlue.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: neonBlue.withOpacity(0.15),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last Updated: December 2, 2025',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // 1. Introduction
                          buildSection(
                            icon: Icons.lock_outline,
                            header: '1. Introduction',
                            content:
                                'This Privacy Policy explains how Hyperzone collects, uses, and protects your personal data when you use our gaming platform. By using Hyperzone, you agree to the practices described in this policy.',
                          ),
                          buildNeonDivider(),

                          // 2. Data We Collect
                          buildSection(
                            icon: Icons.storage_outlined,
                            header: '2. Data We Collect',
                            content:
                                'We may collect the following types of information when you use Hyperzone:',
                            listItems: [
                              'Account information such as username, email address, and profile details.',
                              'Gameplay data like match history, scores, and in-game actions.',
                              'Device and log data such as IP address, browser type, and access times.',
                              'Payment-related information processed securely by third-party providers.',
                            ],
                          ),
                          buildNeonDivider(),

                          // 3. How We Use Your Data
                          buildSection(
                            icon: Icons.settings_suggest_outlined,
                            header: '3. How We Use Your Data',
                            content: 'Your information may be used to:',
                            listItems: [
                              'Operate and improve the Hyperzone platform and services.',
                              'Match you with tournaments, events, and opponents.',
                              'Detect, prevent, and address fraud, abuse, or security incidents.',
                              'Send important updates about tournaments, changes to terms, or system alerts.',
                            ],
                          ),
                          buildNeonDivider(),

                          // 4. Data Sharing
                          buildSection(
                            icon: Icons.share_outlined,
                            header: '4. Data Sharing & Third Parties',
                            content:
                                'We do not sell your personal data. We may share limited information with trusted third-party providers (such as payment gateways, analytics tools, or anti-cheat systems) only to operate the Service. These partners are required to protect your data and use it only for the purposes we specify.',
                          ),
                          buildNeonDivider(),

                          // 5. Your Controls
                          buildSection(
                            icon: Icons.admin_panel_settings_outlined,
                            header: '5. Your Rights & Controls',
                            content:
                                'You may update your account information at any time from your profile. You can also request deletion of your account and associated data, subject to our legal and security obligations.',
                          ),
                        ],
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

  // --- Helper Widgets (same style as Terms) ---

  Widget buildSection({
    required IconData icon,
    required String header,
    required String content,
    List<String>? listItems,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: neonBlue, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                header,
                style: const TextStyle(
                  color: neonBlue,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14.5,
            height: 1.6,
          ),
        ),
        if (listItems != null && listItems.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...listItems.map((item) => buildListItem(item)).toList(),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.star_half, color: highlightColor, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNeonDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15.0),
      height: 1.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            neonBlue.withOpacity(0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
