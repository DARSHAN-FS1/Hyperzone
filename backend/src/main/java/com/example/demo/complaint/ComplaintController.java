package com.example.demo.complaint;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.net.URI;

@RestController
@RequestMapping("/api/complaints")
@CrossOrigin(origins = "*")
public class ComplaintController {

    private final ComplaintRepository complaintRepository;

    public ComplaintController(ComplaintRepository complaintRepository) {
        this.complaintRepository = complaintRepository;
    }

    @PostMapping
    public ResponseEntity<Void> createComplaint(@RequestBody ComplaintRequest request) {
        Complaint c = new Complaint(
                request.getUser(),
                request.getEmail(),
                request.getType(),
                request.getMessage(),
                "OPEN",
                LocalDateTime.now()
        );
        Complaint saved = complaintRepository.save(c);
        return ResponseEntity.created(URI.create("/api/complaints/" + saved.getId())).build();
    }
}
