package com.example.demo.tournament;

import jakarta.persistence.*;

@Entity
@Table(name = "tournaments")
public class Tournament {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String game;

    // PENDING / APPROVED / LIVE / COMPLETED / REJECTED
    @Column(nullable = false)
    private String status;

    // "Admin" for official, or host username
    private String createdBy;

    private int slots;            // max participants
    private int joinedCount;      // joined users
    private double prizePool;     // ₹


    @Column(name = "stream_url")
    private String streamUrl;


    @Column(name = "is_official")
    private boolean isOfficial;

    private String scheduledText; // pretty date text

    private Long hostUserId;      // FK to users table

    
    private String roomId;
    private String roomPassword;

    // true if prizePool >= 100000 (for UI grouping)
    private boolean bigPrizePool;

    // ===== NEW FIELDS =====

    // Winner name / team, e.g. "Team Omega"
    private String winner;

    // true when prizePool has been paid out
    private boolean prizeDelivered = false;

    private int entryFee = 0;


    // ---------- Getters & Setters ----------

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getGame() { return game; }
    public void setGame(String game) { this.game = game; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public int getSlots() { return slots; }
    public void setSlots(int slots) { this.slots = slots; }

    public int getJoinedCount() { return joinedCount; }
    public void setJoinedCount(int joinedCount) { this.joinedCount = joinedCount; }

    public double getPrizePool() { return prizePool; }
    public void setPrizePool(double prizePool) { this.prizePool = prizePool; }

    public boolean isOfficial() { return isOfficial; }
    public void setOfficial(boolean official) { isOfficial = official; }

    public String getScheduledText() { return scheduledText; }
    public void setScheduledText(String scheduledText) { this.scheduledText = scheduledText; }

    public Long getHostUserId() { return hostUserId; }
    public void setHostUserId(Long hostUserId) { this.hostUserId = hostUserId; }

    public String getRoomId() { return roomId; }
    public void setRoomId(String roomId) { this.roomId = roomId; }

    public String getRoomPassword() { return roomPassword; }
    public void setRoomPassword(String roomPassword) { this.roomPassword = roomPassword; }

    public boolean isBigPrizePool() { return bigPrizePool; }
    public void setBigPrizePool(boolean bigPrizePool) { this.bigPrizePool = bigPrizePool; }

    public String getWinner() { return winner; }
    public void setWinner(String winner) { this.winner = winner; }

    public boolean isPrizeDelivered() { return prizeDelivered; }
    public void setPrizeDelivered(boolean prizeDelivered) { this.prizeDelivered = prizeDelivered; }

    public String getStreamUrl() {
    return streamUrl;
}

    public void setStreamUrl(String streamUrl) {
        this.streamUrl = streamUrl;
    }

    public int getEntryFee() {
    return entryFee;
    }

    public void setEntryFee(int entryFee) {
        this.entryFee = entryFee;
    }


}
