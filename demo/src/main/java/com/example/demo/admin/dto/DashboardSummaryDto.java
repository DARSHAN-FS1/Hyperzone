package com.example.demo.admin.dto;

public class DashboardSummaryDto {

    private long totalUsers;
    private long activeUsers;
    private long totalTournaments;
    private long activeTournaments;
    private long pendingTournaments;
    private double totalPrizePool;
    private long pendingComplaints;

    public DashboardSummaryDto() {
    }

    public DashboardSummaryDto(long totalUsers,
                               long activeUsers,
                               long totalTournaments,
                               long activeTournaments,
                               long pendingTournaments,
                               double totalPrizePool,
                               long pendingComplaints) {
        this.totalUsers = totalUsers;
        this.activeUsers = activeUsers;
        this.totalTournaments = totalTournaments;
        this.activeTournaments = activeTournaments;
        this.pendingTournaments = pendingTournaments;
        this.totalPrizePool = totalPrizePool;
        this.pendingComplaints = pendingComplaints;
    }

    public long getTotalUsers() { return totalUsers; }
    public void setTotalUsers(long totalUsers) { this.totalUsers = totalUsers; }

    public long getActiveUsers() { return activeUsers; }
    public void setActiveUsers(long activeUsers) { this.activeUsers = activeUsers; }

    public long getTotalTournaments() { return totalTournaments; }
    public void setTotalTournaments(long totalTournaments) { this.totalTournaments = totalTournaments; }

    public long getActiveTournaments() { return activeTournaments; }
    public void setActiveTournaments(long activeTournaments) { this.activeTournaments = activeTournaments; }

    public long getPendingTournaments() { return pendingTournaments; }
    public void setPendingTournaments(long pendingTournaments) { this.pendingTournaments = pendingTournaments; }

    public double getTotalPrizePool() { return totalPrizePool; }
    public void setTotalPrizePool(double totalPrizePool) { this.totalPrizePool = totalPrizePool; }

    public long getPendingComplaints() { return pendingComplaints; }
    public void setPendingComplaints(long pendingComplaints) { this.pendingComplaints = pendingComplaints; }
}
