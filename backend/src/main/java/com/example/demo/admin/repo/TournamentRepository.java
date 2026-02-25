package com.example.demo.admin.repo;

import com.example.demo.tournament.Tournament;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface TournamentRepository extends JpaRepository<Tournament, Long> {

    long countByStatus(String status);

    @Query("SELECT COALESCE(SUM(t.prizePool), 0) FROM Tournament t WHERE t.status = 'LIVE'")
    double sumPrizePoolOfLive();

    List<Tournament> findByStatus(String status);

    List<Tournament> findByIsOfficialTrue();

    List<Tournament> findByCreatedByOrderByIdDesc(String createdBy);

    // ⭐ Needed for Home + Join page listings
    List<Tournament> findByStatusOrderByIdDesc(String status);
}
