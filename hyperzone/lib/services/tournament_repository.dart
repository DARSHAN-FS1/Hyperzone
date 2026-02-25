import 'package:uuid/uuid.dart';
import '../models/tournament.dart';

class TournamentRepository {
  TournamentRepository._internal();
  static final TournamentRepository instance = TournamentRepository._internal();

  final List<Tournament> _tournaments = [];

  List<Tournament> getAllTournaments() => List.unmodifiable(_tournaments);

  List<Tournament> getBigTournaments() =>
      _tournaments.where((t) => t.isBigTournament).toList();

  List<Tournament> getLiveTournaments() =>
      _tournaments.where((t) =>
          t.streamUrl != null &&
          t.streamUrl!.trim().isNotEmpty).toList();


  void addTournament({
    required String name,
    required String game,
    required String mode,      // Solo / Team / Squad
    required int entryFee,
    required int prizePool,
    required int maxPlayers,
    required DateTime startTime,
    required String hostUserId,
    String? streamUrl,
  }) {
    final bool isBig = prizePool >= 5000 || maxPlayers >= 100;

    final tournament = Tournament(
      id: const Uuid().v4(),
      name: name,
      game: game,
      mode: mode,
      entryFee: entryFee,
      prizePool: prizePool,
      maxPlayers: maxPlayers,
      currentPlayers: 0,
      startTime: startTime,
      hostUserId: hostUserId,
      isOfficial: false,      // repository tournaments = normal host by default
      isBigTournament: isBig,
      streamUrl: streamUrl,
      winner: null,
      prizeDelivered: false,
    );


    _tournaments.add(tournament);
  }

  void joinTournament(String id) {
    final index = _tournaments.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final t = _tournaments[index];
    if (t.currentPlayers >= t.maxPlayers) return;

    _tournaments[index] = t.copyWith(
      currentPlayers: t.currentPlayers + 1,
    );
  }
}
