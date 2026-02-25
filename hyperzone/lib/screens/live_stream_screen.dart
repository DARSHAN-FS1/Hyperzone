import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/tournament.dart';

class LiveStreamScreen extends StatefulWidget {
  final Tournament tournament;

  const LiveStreamScreen({
    super.key,
    required this.tournament,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late final YoutubePlayerController _ytController;

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    // ----- YOUTUBE CONTROLLER -----
    final rawUrl = widget.tournament.streamUrl ?? '';
    String? videoId = YoutubePlayerController.convertUrlToId(rawUrl);

    // Fallback demo video if no valid ID
    videoId ??= 'dQw4w9WgXcQ';

    _ytController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );

    // ----- DUMMY CHAT MESSAGES (More varied for better visual test) -----
    _messages.addAll(const [
      _ChatMessage(
        author: 'System',
        text: 'Welcome to Hyperzone Live Center!',
        isSystem: true,
      ),
      _ChatMessage(
        author: 'Caster',
        text: 'Match will start shortly…',
        isSystem: true,
      ),
      _ChatMessage(
        author: 'Mod',
        text: 'Please keep the chat clean and friendly 🙂',
        isSystem: true,
      ),
      _ChatMessage(
        author: 'Viewer01',
        text: 'Let’s go team, drop your predictions!',
        isSystem: false,
      ),
      _ChatMessage(
        author: 'You',
        text: 'I predict 5-1 victory!',
        isMe: true,
        isSystem: false,
      ),
      _ChatMessage(
        author: 'Viewer02',
        text: 'Free Fire is the best game!',
        isSystem: false,
      ),
    ]);
  }

  @override
  void dispose() {
    _ytController.close();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  bool get _isLiveStatus =>
      widget.tournament.status.toUpperCase() == 'LIVE';

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    final size = MediaQuery.of(context).size;
    final playerHeight = size.height * 0.58; // big cinematic player

    return YoutubePlayerScaffold(
      controller: _ytController,
      backgroundColor: const Color(0xFF020617),
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: const Color(0xFF020617),
          appBar: AppBar(
            backgroundColor: const Color(0xFF020617),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              t.game,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              // Placeholder for Follow Button
              Container(
                margin: const EdgeInsets.only(right: 18),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 14),
                  label: const Text('Follow', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: player + info
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNeonPlayerContainer(playerHeight, player),
                      const SizedBox(height: 16),
                      // NO MORE VIDEOS HERE. ONLY INFO BAR.
                      _buildTournamentInfoBar(t),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // RIGHT: chat
                Expanded(
                  flex: 3,
                  child: _buildChatPanel(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========= NEON PLAYER CONTAINER (Unchanged) =========

  Widget _buildNeonPlayerContainer(double height, Widget player) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF22C55E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2.4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withOpacity(0.35),
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: player,
          ),
        ),
      ),
    );
  }

  // ========= INFO BAR BELOW PLAYER (Slightly improved structure) =========

  Widget _buildTournamentInfoBar(Tournament t) {
    final int entryFee = t.entryFee;
    final int prize = t.prizePool;

    final bool hasBigPrize = prize >= 100000;
    final String scheduledText = '${t.scheduledText ?? ''}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Game/Prize Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name, // The main stream title
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Slightly larger
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${t.game} | Prize ₹$prize', // Secondary game info
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // Share Button
            IconButton(
              onPressed: () { /* Handle Share logic */ },
              icon: const Icon(Icons.share_rounded, color: Colors.white70),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        const Divider(color: Color(0xFF111827), height: 1), // Separator
        const SizedBox(height: 12),

        // Pills/Tags Row
        Row(
          children: [
            _smallPill(
              label: _isLiveStatus ? 'LIVE' : 'SCHEDULED',
              color:
                  _isLiveStatus ? const Color(0xFF22C55E) : const Color(0xFFFACC15),
              icon: _isLiveStatus ? Icons.circle : Icons.schedule_rounded,
            ),
            const SizedBox(width: 8),
            _smallPill(
              label: 'Entry: ₹$entryFee',
              color: const Color(0xFF4B5563),
            ),
            const SizedBox(width: 8),
            _smallPill(
              label: 'Prize: ₹$prize',
              color: const Color(0xFFFB4B56),
            ),
            if (hasBigPrize) ...[
              const SizedBox(width: 8),
              _smallPill(
                label: '🔥 Big Prize',
                color: const Color(0xFFEC4899),
              ),
            ],
            const Spacer(),
            if (scheduledText.isNotEmpty)
              Text(
                scheduledText,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
                textAlign: TextAlign.right,
              ),
          ],
        ),
      ],
    );
  }

  Widget _smallPill({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ========= CHAT PANEL (Improved Bubble/Readability) =========

  Widget _buildChatPanel() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF1D4ED8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2.4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: -12,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: const [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 18, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Live Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFF111827), height: 1),

            // MESSAGES
            Expanded(
              child: ListView.builder(
                controller: _chatScrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  return _buildChatMessage(m);
                },
              ),
            ),

            // INPUT
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Darker background for input area
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Send a message…',
                        hintStyle: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: Color(0xFF0EA5E9),
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New private method for individual chat message rendering
  Widget _buildChatMessage(_ChatMessage m) {
    Color bubbleColor;
    Color textColor;
    Alignment alignment;
    Widget messageContent;

    if (m.isSystem) {
      bubbleColor = const Color(0xFF1F2937); // Neutral/System background
      textColor = Colors.white70;
      alignment = Alignment.centerLeft;
      messageContent = Text(
        m.text,
        style: TextStyle(color: textColor, fontSize: 12, fontStyle: FontStyle.italic),
      );
    } else if (m.isMe) {
      bubbleColor = const Color(0xFF0EA5E9); // Blue for "Me"
      textColor = Colors.white;
      alignment = Alignment.centerRight;
      messageContent = Text(
        m.text,
        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
      );
    } else {
      bubbleColor = const Color(0xFF374151); // Dark Gray for others
      textColor = Colors.white;
      alignment = Alignment.centerLeft;
      messageContent = RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${m.author}: ',
              style: TextStyle(
                color: const Color(0xFF22C55E), // Author name in green
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: m.text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Apply specific radius/shape for bubbles
    BorderRadius borderRadius;
    if (m.isSystem) {
      borderRadius = BorderRadius.circular(8);
    } else if (m.isMe) {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(4),
      );
    } else {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
      );
    }

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.2), // Limit chat width
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: messageContent,
      ),
    );
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        author: 'You',
        text: text,
        isMe: true,
      ));
    });

    _chatController.clear();
    // Scroll to the bottom after sending a message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// ---------- simple chat model (Unchanged) ----------

class _ChatMessage {
  final String author;
  final String text;
  final bool isMe;
  final bool isSystem;

  const _ChatMessage({
    required this.author,
    required this.text,
    this.isMe = false,
    this.isSystem = false,
  });
}