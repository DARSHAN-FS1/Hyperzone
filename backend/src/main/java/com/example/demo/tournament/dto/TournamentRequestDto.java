package com.example.demo.tournament.dto;

public class TournamentRequestDto {

    private String name;
    private String game;
    private String createdBy;
    private String date;
    private Integer slots;
    private Double prizePool;
    private String streamUrl;
    private Integer entryFee;


    public TournamentRequestDto() {
    }

    public TournamentRequestDto(String name,
                                String game,
                                String createdBy,
                                String date,
                                Integer slots,
                                Double prizePool,
                                String streamUrl) {
        this.name = name;
        this.game = game;
        this.createdBy = createdBy;
        this.date = date;
        this.slots = slots;
        this.prizePool = prizePool;
        this.streamUrl = streamUrl;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getGame() { return game; }
    public void setGame(String game) { this.game = game; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public Integer getSlots() { return slots; }
    public void setSlots(Integer slots) { this.slots = slots; }

    public Double getPrizePool() { return prizePool; }
    public void setPrizePool(Double prizePool) { this.prizePool = prizePool; }

    public String getStreamUrl() { return streamUrl; }
    public void setStreamUrl(String streamUrl) { this.streamUrl = streamUrl; }

    public Integer getEntryFee() { return entryFee; }
    public void setEntryFee(Integer entryFee) { this.entryFee = entryFee; }

}
