package com.example.demo.tournament.dto;

public class HostedTournamentDto {

    private Long id;
    private String name;
    private String game;
    // PENDING / SCHEDULED / LIVE / COMPLETED / REJECTED
    private String status;
    private String createdBy;
    private int slots;
    private int joinedCount;
    private double prizePool;
    private String scheduledText;
    private boolean official;

    // winner info
    private String winner;
    private boolean prizeDelivered;

    // ✅ NEW → stream live link
    private String streamUrl;

    public HostedTournamentDto() {
    }

    public HostedTournamentDto(
            Long id,
            String name,
            String game,
            String status,
            String createdBy,
            int slots,
            int joinedCount,
            double prizePool,
            String scheduledText,
            boolean official,
            String winner,
            boolean prizeDelivered,
            String streamUrl
    ) {
        this.id = id;
        this.name = name;
        this.game = game;
        this.status = status;
        this.createdBy = createdBy;
        this.slots = slots;
        this.joinedCount = joinedCount;
        this.prizePool = prizePool;
        this.scheduledText = scheduledText;
        this.official = official;
        this.winner = winner;
        this.prizeDelivered = prizeDelivered;
        this.streamUrl = streamUrl;
    }

    // ---------- getters & setters ----------

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

    public String getScheduledText() { return scheduledText; }
    public void setScheduledText(String scheduledText) { this.scheduledText = scheduledText; }

    public boolean isOfficial() { return official; }
    public void setOfficial(boolean official) { this.official = official; }

    public String getWinner() { return winner; }
    public void setWinner(String winner) { this.winner = winner; }

    public boolean isPrizeDelivered() { return prizeDelivered; }
    public void setPrizeDelivered(boolean prizeDelivered) { this.prizeDelivered = prizeDelivered; }

    public String getStreamUrl() { return streamUrl; }
    public void setStreamUrl(String streamUrl) { this.streamUrl = streamUrl; }
}
