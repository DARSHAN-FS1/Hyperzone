package com.example.demo.tournament;

import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/tournaments")
@CrossOrigin(origins = "*")
public class TournamentParticipantController {

    private final TournamentParticipantRepository participantRepository;

    public TournamentParticipantController(TournamentParticipantRepository participantRepository) {
        this.participantRepository = participantRepository;
    }

    
    @GetMapping("/{id}/participants")
    public List<TournamentParticipant> getParticipants(@PathVariable Long id) {
        return participantRepository.findByTournamentId(id);
    }
}
