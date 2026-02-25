class Tournament {
  final String id;
  final String name;
  final String game;
  final String mode;
  final int entryFee;
  final int prizePool;
  final int maxPlayers;
  final int currentPlayers;
  final DateTime startTime;
  final String hostUserId;
  final bool isOfficial;
  final bool isBigTournament;
  final String? streamUrl;
  final String? winner;
  final bool prizeDelivered;
  final String status;
  final String? scheduledText;
  final bool? bigPrizePool;

  Tournament({
    required this.id,
    required this.name,
    required this.game,
    required this.mode,
    required this.entryFee,
    required this.prizePool,
    required this.maxPlayers,
    this.currentPlayers = 0,
    required this.startTime,
    required this.hostUserId,
    required this.isOfficial,
    required this.isBigTournament,
    this.streamUrl,
    this.winner,
    this.prizeDelivered = false,
    this.status = 'SCHEDULED',
    this.scheduledText,
    this.bigPrizePool,
  });

  /// Safer copyWith (includes all fields)
  Tournament copyWith({
    String? id,
    String? name,
    String? game,
    String? mode,
    int? entryFee,
    int? prizePool,
    int? maxPlayers,
    int? currentPlayers,
    DateTime? startTime,
    String? hostUserId,
    bool? isOfficial,
    bool? isBigTournament,
    String? streamUrl,
    String? winner,
    bool? prizeDelivered,
    String? status,
    String? scheduledText,
    bool? bigPrizePool,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      game: game ?? this.game,
      mode: mode ?? this.mode,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      startTime: startTime ?? this.startTime,
      hostUserId: hostUserId ?? this.hostUserId,
      isOfficial: isOfficial ?? this.isOfficial,
      isBigTournament: isBigTournament ?? this.isBigTournament,
      streamUrl: streamUrl ?? this.streamUrl,
      winner: winner ?? this.winner,
      prizeDelivered: prizeDelivered ?? this.prizeDelivered,
      status: status ?? this.status,
      scheduledText: scheduledText ?? this.scheduledText,
      bigPrizePool: bigPrizePool ?? this.bigPrizePool,
    );
  }

  /// Optional: fromJson helper (not strictly required but handy)
  factory Tournament.fromJson(Map<String, dynamic> m) {
    final dynamic rawFee =
        m['entryFee'] ?? m['entry_fee'] ?? m['fee'] ?? 0;
    final int entryFee = rawFee is num
        ? rawFee.toInt()
        : int.tryParse(rawFee.toString()) ?? 0;

    final numPrize = (m['prizePool'] as num?) ?? 0;
    final numSlots =
        (m['slots'] as num?) ?? (m['maxPlayers'] as num? ?? 0);
    final numJoined =
        (m['joinedCount'] as num?) ?? (m['currentPlayers'] as num? ?? 0);

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
          DateTime.tryParse(m['startTime']?.toString() ?? '') ??
              DateTime.now(),
      hostUserId:
          (m['createdBy'] ?? m['hostUserId'] ?? 'admin').toString(),
      isOfficial: (m['official'] ?? m['isOfficial'] ?? false) as bool,
      isBigTournament: numPrize >= 100000,
      streamUrl: m['streamUrl']?.toString(),
      winner: m['winner']?.toString(),
      prizeDelivered: m['prizeDelivered'] == true,
      status: (m['status'] ?? 'SCHEDULED').toString(),
      scheduledText: m['scheduledText']?.toString(),
      bigPrizePool:
          m['bigPrizePool'] as bool? ?? (numPrize >= 100000),
    );
  }
}
