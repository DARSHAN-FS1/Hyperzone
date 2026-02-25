package com.example.demo.tournament;

import org.springframework.data.jpa.repository.JpaRepository;


import java.util.Optional;

public interface TournamentResultRepository extends JpaRepository<TournamentResult, Long> {

    Optional<TournamentResult> findByTournamentId(Long tournamentId);
}
