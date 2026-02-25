import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const Color darkBg = Color(0xFF070A11);
  static const Color cardBg = Color(0xFF101624);
  static const Color neonBlue = Color(0xFF00FFFF);
  static const Color highlightColor = Color(0xFF4C5874);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Container(
        // Subtle gradient background
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
                  'Terms & Conditions',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    shadows: [Shadow(color: neonBlue.withOpacity(0.5), blurRadius: 5)],
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
                    // Main Content Container
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
                            style: TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 25),

                          // Section 1: Acceptance
                          buildSection(
                            icon: Icons.assignment_turned_in_outlined,
                            header: '1. Acceptance of Terms',
                            content:
                                'By accessing or using the Hyperzone gaming platform (the "Service"), you agree to be bound by these Terms and Conditions ("Terms"). If you disagree with any part of the terms, then you may not access the Service. Continued use signifies your full agreement.',
                          ),
                          buildNeonDivider(),

                          // Section 2: User Obligations
                          buildSection(
                            icon: Icons.policy_outlined,
                            header: '2. User Obligations',
                            content:
                                'You are responsible for all activity that occurs under your account. You agree not to use the Service for any unlawful or prohibited activities, including, but not limited to:',
                            listItems: [
                              'Cheating, hacking, or exploiting game mechanics.',
                              'Harassment or abusive behavior towards other users.',
                              'Distributing malware or unauthorized advertising.',
                              'Attempting to gain unauthorized access to the system.',
                            ],
                          ),
                          buildNeonDivider(),

                          // Section 3: Intellectual Property
                          buildSection(
                            icon: Icons.copyright_outlined,
                            header: '3. Intellectual Property',
                            content:
                                'All content, including text, graphics, logos, and software, is the property of Hyperzone or its content suppliers and is protected by international copyright laws. You may not reproduce, duplicate, copy, sell, resell, or exploit any portion of the Service without express written permission from Hyperzone.',
                          ),
                          buildNeonDivider(),

                          // Section 4: Limitation of Liability
                          buildSection(
                            icon: Icons.gavel_outlined,
                            header: '4. Limitation of Liability',
                            content:
                                'Hyperzone will not be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or use of or inability to access or use the Service; (ii) any conduct or content of any third party on the Service.',
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

  // --- Helper Widgets ---

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
                    color: neonBlue, fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(color: Colors.white70, fontSize: 14.5, height: 1.6),
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
              style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
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