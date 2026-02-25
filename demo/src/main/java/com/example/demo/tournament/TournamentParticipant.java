package com.example.demo.tournament;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "tournament_participants")
public class TournamentParticipant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // just store tournament id (simple mapping)
    @Column(name = "tournament_id", nullable = false)
    private Long tournamentId;

    private String username;
    private String userId;
    private String email;

    private LocalDateTime joinedAt;

    public TournamentParticipant() {
    }

    public TournamentParticipant(Long tournamentId, String username, String userId, String email, LocalDateTime joinedAt) {
        this.tournamentId = tournamentId;
        this.username = username;
        this.userId = userId;
        this.email = email;
        this.joinedAt = joinedAt;
    }

    // ===== getters & setters =====
    public Long getId() {
        return id;
    }

    public Long getTournamentId() {
        return tournamentId;
    }

    public void setTournamentId(Long tournamentId) {
        this.tournamentId = tournamentId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDateTime getJoinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(LocalDateTime joinedAt) {
        this.joinedAt = joinedAt;
    }
}
