package com.example.demo.tournament;

import com.example.demo.tournament.dto.TournamentResultDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Handles winners for a tournament.
 *
 * Base path: /api/results
 *  - GET  /api/results/{tournamentId}  -> get winners
 *  - POST /api/results/{tournamentId}  -> create / update winners
 */
@RestController
@RequestMapping("/api/results")
@CrossOrigin(origins = "*")
public class TournamentResultController {

    private final TournamentResultService resultService;

    public TournamentResultController(TournamentResultService resultService) {
        this.resultService = resultService;
    }

    /**
     * Get winners for one tournament.
     * Used when you open the "Add / View Winners" dialog
     * and we pre-fill existing values.
     */
    @GetMapping("/{tournamentId}")
    public ResponseEntity<TournamentResultDto> getResult(
            @PathVariable Long tournamentId
    ) {
        TournamentResultDto dto = resultService.getResultForTournament(tournamentId);
        if (dto == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(dto);
    }

    /**
     * Save or update winners for one tournament.
     * Called from Flutter when you press "Save winners".
     */
    @PostMapping("/{tournamentId}")
    public ResponseEntity<TournamentResultDto> saveOrUpdateResult(
            @PathVariable Long tournamentId,
            @RequestBody TournamentResultDto dto
    ) {
        TournamentResultDto saved = resultService.saveOrUpdateResult(tournamentId, dto);
        return ResponseEntity.ok(saved);
    }
}
