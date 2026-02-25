package com.example.demo.tournament.dto;

public class TournamentResultDto {

    private Long tournamentId;
    private String firstPlace;
    private String secondPlace;
    private String thirdPlace;
    private String extraInfo;

    public TournamentResultDto() {
    }

    public TournamentResultDto(Long tournamentId, String firstPlace, String secondPlace,
                               String thirdPlace, String extraInfo) {
        this.tournamentId = tournamentId;
        this.firstPlace = firstPlace;
        this.secondPlace = secondPlace;
        this.thirdPlace = thirdPlace;
        this.extraInfo = extraInfo;
    }

    public Long getTournamentId() {
        return tournamentId;
    }

    public void setTournamentId(Long tournamentId) {
        this.tournamentId = tournamentId;
    }

    public String getFirstPlace() {
        return firstPlace;
    }

    public void setFirstPlace(String firstPlace) {
        this.firstPlace = firstPlace;
    }

    public String getSecondPlace() {
        return secondPlace;
    }

    public void setSecondPlace(String secondPlace) {
        this.secondPlace = secondPlace;
    }

    public String getThirdPlace() {
        return thirdPlace;
    }

    public void setThirdPlace(String thirdPlace) {
        this.thirdPlace = thirdPlace;
    }

    public String getExtraInfo() {
        return extraInfo;
    }

    public void setExtraInfo(String extraInfo) {
        this.extraInfo = extraInfo;
    }
}
