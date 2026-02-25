import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardSummary {
  final int totalUsers;
  final int activeUsers;
  final int totalTournaments;
  final int activeTournaments;
  final int pendingTournaments;
  final double totalPrizePool;
  final int pendingComplaints;

  DashboardSummary({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalTournaments,
    required this.activeTournaments,
    required this.pendingTournaments,
    required this.totalPrizePool,
    required this.pendingComplaints,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalTournaments: json['totalTournaments'] ?? 0,
      activeTournaments: json['activeTournaments'] ?? 0,
      pendingTournaments: json['pendingTournaments'] ?? 0,
      totalPrizePool: (json['totalPrizePool'] ?? 0).toDouble(),
      pendingComplaints: json['pendingComplaints'] ?? 0,
    );
  }
}

class AdminTournament {
  final String id;
  final String name;
  final String game;
  final String status;
  final String createdBy;
  final String date;
  final int slots;
  final double prizePool;
  final bool isOfficial;
  final int entryFee;
  final String? streamUrl;

  AdminTournament({
    required this.id,
    required this.name,
    required this.game,
    required this.status,
    required this.createdBy,
    required this.date,
    required this.slots,
    required this.prizePool,
    required this.isOfficial,
    required this.entryFee,
    this.streamUrl,
  });

  factory AdminTournament.fromJson(Map<String, dynamic> json) {
    final dynamic officialRaw =
        json['official'] ?? json['isOfficial'] ?? false;
    final bool official = officialRaw is bool
        ? officialRaw
        : officialRaw.toString().toLowerCase() == 'true';

    return AdminTournament(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      game: json['game'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdBy: json['createdBy'] ?? 'Host',
      date: json['date'] ?? '',
      slots: json['slots'] ?? 0,
      prizePool: (json['prizePool'] ?? 0).toDouble(),
      isOfficial: official,
      entryFee: int.tryParse((json['entryFee'] ?? 0).toString()) ?? 0,
      streamUrl: json['streamUrl']?.toString(),
    );
  }
}

class Complaint {
  final String id;
  final String user;
  final String type;
  final String status;
  final String date;

  Complaint({
    required this.id,
    required this.user,
    required this.type,
    required this.status,
    required this.date,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id']?.toString() ?? '',
      user: json['user'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'NEW',
      date: json['date'] ?? '',
    );
  }
}

class AdminApiService {
  final String baseUrl;
  final http.Client _client;

  AdminApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  bool get isDemoMode => baseUrl.trim().isEmpty;

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<DashboardSummary> fetchSummary({String? token}) async {
    final uri = Uri.parse('$baseUrl/admin/dashboard-summary');
    final res = await _client.get(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load dashboard summary: ${res.statusCode}',
      );
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return DashboardSummary.fromJson(data);
  }

  Future<List<AdminTournament>> fetchPendingTournaments({
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/pending-tournaments');
    final res = await _client.get(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load pending tournaments: ${res.statusCode}',
      );
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => AdminTournament.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AdminTournament>> fetchOfficialTournaments({
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/admin-tournaments');
    final res = await _client.get(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load official tournaments: ${res.statusCode}',
      );
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => AdminTournament.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Complaint>> fetchPendingComplaints({
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/complaints/pending');
    final res = await _client.get(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load complaints: ${res.statusCode}',
      );
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveTournament(String id, {String? token}) async {
    final uri =
        Uri.parse('$baseUrl/admin/pending-tournaments/$id/approve');
    final res = await _client.post(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to approve tournament: ${res.statusCode}',
      );
    }
  }

  Future<void> rejectTournament(String id, {String? token}) async {
    final uri =
        Uri.parse('$baseUrl/admin/pending-tournaments/$id/reject');
    final res = await _client.post(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to reject tournament: ${res.statusCode}',
      );
    }
  }

  Future<void> startTournament(String id, {String? token}) async {
    final uri = Uri.parse('$baseUrl/tournaments/$id/start');
    final res = await _client.put(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to start tournament: ${res.statusCode}',
      );
    }
  }

  Future<void> completeTournament(String id, {String? token}) async {
    final uri = Uri.parse('$baseUrl/tournaments/$id/complete');
    final res = await _client.put(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to complete tournament: ${res.statusCode}',
      );
    }
  }

  Future<void> markComplaintResolved(String id, {String? token}) async {
    final uri = Uri.parse('$baseUrl/admin/complaints/$id/resolve');
    final res = await _client.post(uri, headers: _headers(token: token));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to resolve complaint: ${res.statusCode}',
      );
    }
  }

  Future<AdminTournament> createOfficialTournament({
    required String name,
    required String game,
    required int slots,
    required double prizePool,
    required String dateText,
    String? streamUrl,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/admin-tournaments');

    final body = jsonEncode({
      'name': name,
      'game': game,
      'slots': slots,
      'prizePool': prizePool,
      'date': dateText,
      'streamUrl': streamUrl,
    });

    final res = await _client.post(
      uri,
      headers: _headers(token: token),
      body: body,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(
        'Failed to create official tournament: ${res.statusCode}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return AdminTournament.fromJson(data);
  }

  Future<void> submitComplaint({
    required String user,
    required String email,
    required String type,
    required String message,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/complaints');

    final body = jsonEncode({
      'user': user,
      'email': email,
      'type': type,
      'message': message,
    });

    final res = await _client.post(
      uri,
      headers: _headers(token: token),
      body: body,
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(
        'Failed to submit complaint: ${res.statusCode}',
      );
    }
  }
  // 🔹 Fetch participants list for a given tournament
Future<List<Map<String, dynamic>>> getTournamentParticipants(
  String tournamentId, {
  String? token,
}) async {
  final url = Uri.parse('$baseUrl/tournaments/$tournamentId/participants');

  final res = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode == 200) {
    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception(
        'Failed to load participants (HTTP ${res.statusCode})');
  }
}

}
