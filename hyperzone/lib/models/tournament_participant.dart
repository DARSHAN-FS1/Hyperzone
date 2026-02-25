class TournamentParticipant {
  final int id;
  final int tournamentId;
  final String username;
  final String? userId;
  final String? email;
  final DateTime joinedAt;

  TournamentParticipant({
    required this.id,
    required this.tournamentId,
    required this.username,
    this.userId,
    this.email,
    required this.joinedAt,
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      id: json['id'] as int,
      tournamentId: json['tournamentId'] as int,
      username: (json['username'] ?? '').toString(),
      userId: json['userId']?.toString(),
      email: json['email']?.toString(),
      joinedAt: DateTime.parse(json['joinedAt'].toString()),
    );
  }
}
