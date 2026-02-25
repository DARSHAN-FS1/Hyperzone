import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/tournament.dart';
import '../models/tournament_participant.dart';

class TournamentApiService {
  TournamentApiService._();
  static final TournamentApiService instance = TournamentApiService._();

  static const String _baseUrl = 'http://localhost:8080/api/tournaments';

  // ───────────────── CREATE TOURNAMENT REQUEST ─────────────────
  Future<void> createTournamentRequest({
    required String name,
    required String game,
    required String createdBy,
    required String date,
    required int slots,
    required double prizePool,
    String? streamUrl,
  }) async {
    final uri = Uri.parse('$_baseUrl/request');

    final body = {
      'name': name,
      'game': game,
      'createdBy': createdBy,
      'date': date,
      'slots': slots,
      'prizePool': prizePool,
      'streamUrl': streamUrl,
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create tournament request: ${res.body}');
    }
  }

    // ───────────────── GET PUBLIC TOURNAMENTS ─────────────────
  Future<List<Tournament>> getPublicTournaments() async {
    final uri = Uri.parse('$_baseUrl/public');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load tournaments: ${res.body}');
    }

    final List<dynamic> jsonList = jsonDecode(res.body) as List<dynamic>;

    return jsonList.map((data) {
      final m = data as Map<String, dynamic>;

      // Debug: show what backend actually sends
      print(
          '🔍 Tournament from backend: name=${m['name']} entryFee=${m['entryFee']} prizePool=${m['prizePool']}');

      // --- prize / slots / joined ---
      final numPrize = (m['prizePool'] as num?) ?? 0;
      final numSlots = (m['slots'] as num?) ?? (m['maxPlayers'] as num? ?? 0);
      final numJoined =
          (m['joinedCount'] as num?) ?? (m['currentPlayers'] as num? ?? 0);

      
      int entryFee;
      final dynamic rawEntryFee = m['entryFee'];

      if (rawEntryFee == null) {
        
        final int prize = numPrize.toInt();

        if (prize >= 500000) {
          entryFee = 1000;
        } else if (prize >= 200000) {
          entryFee = 500;
        } else if (prize >= 50000) {
          entryFee = 199;
        } else if (prize >= 10000) {
          entryFee = 99;
        } else {
          entryFee = 0; 
        }
      } else {
        // Backend sends a numeric fee
        entryFee = (rawEntryFee as num).toInt();
      }

      
      print(
          '✅ MAPPED TO MODEL: name=${m['name']} entryFee=$entryFee prizePool=$numPrize');

      return Tournament(
        id: (m['id'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        game: (m['game'] ?? '').toString(),
        mode: (m['mode'] ?? 'Solo').toString(),
        entryFee: entryFee,
        prizePool: numPrize.toInt(),
        maxPlayers: numSlots.toInt(),
        currentPlayers: numJoined.toInt(),
        startTime:
            DateTime.tryParse(m['startTime']?.toString() ?? '') ?? DateTime.now(),
        hostUserId: (m['createdBy'] ?? m['hostUserId'] ?? 'admin').toString(),
        isOfficial: (m['official'] ?? m['isOfficial'] ?? false) as bool,
        isBigTournament: numPrize >= 100000,
        streamUrl: m['streamUrl']?.toString(),
        winner: m['winner']?.toString(),
        prizeDelivered: m['prizeDelivered'] == true,
        status: (m['status'] ?? 'SCHEDULED').toString(),
      );
    }).toList();
  }



  // ───────────────── JOIN TOURNAMENT ─────────────────
  Future<void> joinTournament({
    required int tournamentId,
    required String username,
    String? userId,
    String? email,
  }) async {
    final uri = Uri.parse('$_baseUrl/$tournamentId/join');

    final body = <String, dynamic>{
      'username': username,
      if (userId != null) 'userId': userId,
      if (email != null) 'email': email,
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to join tournament: ${res.body}');
    }
  }

  // ───────────────── PARTICIPANTS (model-based) ─────────────────
  Future<List<TournamentParticipant>> getParticipants(int tournamentId) async {
    final uri = Uri.parse('$_baseUrl/$tournamentId/participants');

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load participants: ${res.body}');
    }

    final List<dynamic> jsonList = jsonDecode(res.body) as List<dynamic>;

    return jsonList
        .map((e) => TournamentParticipant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ───────────────── PARTICIPANTS as raw map (used in admin pages) ────────────────
  Future<List<Map<String, dynamic>>> getTournamentParticipants(
      int tournamentId) async {
    final uri =
        Uri.parse('$_baseUrl/$tournamentId/participants');

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to load participants (HTTP ${res.statusCode}): ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;

    return data.map<Map<String, dynamic>>((dynamic item) {
      final m = item as Map<String, dynamic>;
      return {
        'id': m['id'],
        'tournamentId': m['tournamentId'],
        'username': m['username'] ?? '',
        'userId': m['userId'],
        'email': m['email'],
        'joinedAt': m['joinedAt'],
      };
    }).toList();
  }
}
