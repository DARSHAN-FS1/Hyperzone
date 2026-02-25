package com.example.demo.admin.controller;

import com.example.demo.admin.dto.AdminTournamentDto;
import com.example.demo.admin.dto.ComplaintDto;
import com.example.demo.admin.dto.DashboardSummaryDto;
import com.example.demo.admin.service.AdminDashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;

    public AdminDashboardController(AdminDashboardService adminDashboardService) {
        this.adminDashboardService = adminDashboardService;
    }

    @GetMapping("/dashboard-summary")
    public ResponseEntity<DashboardSummaryDto> getDashboardSummary() {
        DashboardSummaryDto summary = adminDashboardService.getSummary();
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/pending-tournaments")
    public ResponseEntity<List<AdminTournamentDto>> getPendingTournaments() {
        return ResponseEntity.ok(adminDashboardService.getPendingTournaments());
    }

    @PostMapping("/pending-tournaments/{id}/approve")
    public ResponseEntity<Void> approve(@PathVariable Long id) {
        adminDashboardService.approveTournament(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/pending-tournaments/{id}/reject")
    public ResponseEntity<Void> reject(@PathVariable Long id) {
        adminDashboardService.rejectTournament(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/admin-tournaments")
    public ResponseEntity<List<AdminTournamentDto>> getAdminTournaments() {
        return ResponseEntity.ok(adminDashboardService.getAdminTournaments());
    }

    @PostMapping("/admin-tournaments")
    public ResponseEntity<AdminTournamentDto> createOfficial(@RequestBody AdminTournamentDto dto) {
        AdminTournamentDto created = adminDashboardService.createOfficialTournament(dto);
        return ResponseEntity
                .created(URI.create("/api/admin/admin-tournaments/" + created.getId()))
                .body(created);
    }

    @GetMapping("/complaints/pending")
    public ResponseEntity<List<ComplaintDto>> getPendingComplaints() {
        return ResponseEntity.ok(adminDashboardService.getPendingComplaints());
    }

    @PostMapping("/complaints/{id}/resolve")
    public ResponseEntity<Void> resolveComplaint(@PathVariable Long id) {
        adminDashboardService.resolveComplaint(id);
        return ResponseEntity.ok().build();
    }
}
