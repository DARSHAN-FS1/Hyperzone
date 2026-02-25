package com.example.demo.admin.dto;

public class AdminTournamentDto {

    private Long id;
    private String name;
    private String game;
    private String status;
    private String createdBy;
    private String date;
    private int slots;
    private double prizePool;
    private boolean official;
    private int entryFee;
    private String streamUrl;

    public AdminTournamentDto() {
    }

    public AdminTournamentDto(Long id,
                              String name,
                              String game,
                              String status,
                              String createdBy,
                              String date,
                              int slots,
                              double prizePool,
                              boolean official,
                              int entryFee,
                              String streamUrl) {
        this.id = id;
        this.name = name;
        this.game = game;
        this.status = status;
        this.createdBy = createdBy;
        this.date = date;
        this.slots = slots;
        this.prizePool = prizePool;
        this.official = official;
        this.entryFee = entryFee;
        this.streamUrl = streamUrl;
    }

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

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public int getSlots() { return slots; }
    public void setSlots(int slots) { this.slots = slots; }

    public double getPrizePool() { return prizePool; }
    public void setPrizePool(double prizePool) { this.prizePool = prizePool; }

    public boolean isOfficial() { return official; }
    public void setOfficial(boolean official) { this.official = official; }

    public int getEntryFee() { return entryFee; }
    public void setEntryFee(int entryFee) { this.entryFee = entryFee; }

    public String getStreamUrl() { return streamUrl; }
    public void setStreamUrl(String streamUrl) { this.streamUrl = streamUrl; }
}
