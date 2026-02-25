import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/admin_api_service.dart';

class AdminTournamentParticipantsScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const AdminTournamentParticipantsScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<AdminTournamentParticipantsScreen> createState() =>
      _AdminTournamentParticipantsScreenState();
}

class _AdminTournamentParticipantsScreenState
    extends State<AdminTournamentParticipantsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _participants = [];

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

Future<void> _loadParticipants() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final list = await AdminApiService(
      baseUrl: 'http://localhost:8080/api',
    ).getTournamentParticipants(
      widget.tournamentId.toString(), // int -> String
    );

    setState(() {
      _participants = list;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = 'Failed to load participants: $e';
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF020617);
    const cardBg = Color(0xFF020617);
    const accent = Color(0xFF4DD0E1);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
        title: Text(
          'Participants – ${widget.tournamentName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _loadParticipants,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : _participants.isEmpty
                      ? const Center(
                          child: Text(
                            'No participants joined yet.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _participants.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final p = _participants[index];
                            final username =
                                (p['username'] ?? '').toString();
                            final email =
                                (p['email'] ?? '—').toString();
                            final userId =
                                (p['userId'] ?? '—').toString();
                            final joinedAt =
                                (p['joinedAt'] ?? '').toString();

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4DD0E1),
                                          Color(0xFF7C4DFF),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      username.isEmpty
                                          ? '?'
                                          : username[0]
                                              .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'User ID: $userId',
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Joined at',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        joinedAt,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
