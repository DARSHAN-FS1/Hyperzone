package com.example.demo.tournament;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TournamentParticipantRepository extends JpaRepository<TournamentParticipant, Long> {
    
    List<TournamentParticipant> findByTournamentId(Long tournamentId);
}
