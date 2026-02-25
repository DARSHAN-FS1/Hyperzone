package com.example.demo.admin.service;

import com.example.demo.admin.dto.AdminTournamentDto;
import com.example.demo.admin.dto.ComplaintDto;
import com.example.demo.admin.dto.DashboardSummaryDto;
import com.example.demo.admin.repo.TournamentRepository;
import com.example.demo.complaint.Complaint;
import com.example.demo.complaint.ComplaintRepository;
import com.example.demo.tournament.Tournament;
import com.example.demo.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class AdminDashboardService {

    private final UserRepository userRepository;
    private final TournamentRepository tournamentRepository;
    private final ComplaintRepository complaintRepository;

    private final DateTimeFormatter complaintDateFormatter =
            DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public AdminDashboardService(UserRepository userRepository,
                                 TournamentRepository tournamentRepository,
                                 ComplaintRepository complaintRepository) {
        this.userRepository = userRepository;
        this.tournamentRepository = tournamentRepository;
        this.complaintRepository = complaintRepository;
    }

    public DashboardSummaryDto getSummary() {
        long totalUsers = userRepository.count();
        long activeUsers = userRepository.countActiveUsers();
        long totalTournaments = tournamentRepository.count();
        long liveTournaments = tournamentRepository.countByStatus("LIVE");
        long pendingTournaments = tournamentRepository.countByStatus("PENDING");
        double totalPrizePool = tournamentRepository.sumPrizePoolOfLive();
        long pendingComplaints = complaintRepository.countByStatus("OPEN");

        return new DashboardSummaryDto(
                totalUsers,
                activeUsers,
                totalTournaments,
                liveTournaments,
                pendingTournaments,
                totalPrizePool,
                pendingComplaints
        );
    }

    public List<AdminTournamentDto> getPendingTournaments() {
        return tournamentRepository.findByStatus("PENDING")
                .stream()
                .map(this::mapTournamentToDto)
                .collect(Collectors.toList());
    }

    public List<AdminTournamentDto> getAdminTournaments() {
        return tournamentRepository.findByIsOfficialTrue()
                .stream()
                .map(this::mapTournamentToDto)
                .collect(Collectors.toList());
    }

    public void approveTournament(Long id) {
        Tournament t = tournamentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Tournament not found"));
        t.setStatus("SCHEDULED");
        tournamentRepository.save(t);
    }

    public void rejectTournament(Long id) {
        Tournament t = tournamentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Tournament not found"));
        t.setStatus("REJECTED");
        tournamentRepository.save(t);
    }

    public AdminTournamentDto createOfficialTournament(AdminTournamentDto dto) {
        Tournament t = new Tournament();
        t.setName(dto.getName());
        t.setGame(dto.getGame());
        t.setPrizePool(dto.getPrizePool());
        t.setSlots(dto.getSlots());
        t.setOfficial(true);
        t.setStatus("SCHEDULED");
        t.setCreatedBy("Admin");
        t.setScheduledText(dto.getDate());
        t.setStreamUrl(dto.getStreamUrl());

        Tournament saved = tournamentRepository.save(t);
        return mapTournamentToDto(saved);
    }

    public List<ComplaintDto> getPendingComplaints() {
        return complaintRepository.findByStatus("OPEN")
                .stream()
                .map(this::mapComplaintToDto)
                .collect(Collectors.toList());
    }

    public void resolveComplaint(Long id) {
        Complaint c = complaintRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Complaint not found"));
        c.setStatus("RESOLVED");
        complaintRepository.save(c);
    }

    private AdminTournamentDto mapTournamentToDto(Tournament t) {
        String dateText = t.getScheduledText() != null ? t.getScheduledText() : "";

        AdminTournamentDto dto = new AdminTournamentDto();
        dto.setId(t.getId());
        dto.setName(t.getName());
        dto.setGame(t.getGame());
        dto.setStatus(t.getStatus());
        dto.setCreatedBy(t.getCreatedBy());
        dto.setDate(dateText);
        dto.setSlots(t.getSlots());
        dto.setPrizePool(t.getPrizePool());
        dto.setOfficial(t.isOfficial());
        dto.setStreamUrl(t.getStreamUrl());

        return dto;
    }

    private ComplaintDto mapComplaintToDto(Complaint c) {
        String date = "";
        if (c.getCreatedAt() != null) {
            date = c.getCreatedAt().format(complaintDateFormatter);
        }
        return new ComplaintDto(
                c.getId(),
                c.getUserName(),
                c.getType(),
                c.getStatus(),
                date
        );
    }
}
