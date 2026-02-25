package com.example.demo.tournament;

import com.example.demo.admin.repo.TournamentRepository;
import com.example.demo.tournament.dto.HostedTournamentDto;
import com.example.demo.tournament.dto.TournamentRequestDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.Objects;
import java.time.LocalDateTime;


@RestController
@RequestMapping("/api/tournaments")
@CrossOrigin(origins = "*")
public class TournamentController {

    private final TournamentRepository tournamentRepository;
    private final TournamentParticipantRepository participantRepository;

    public TournamentController(
            TournamentRepository tournamentRepository,
            TournamentParticipantRepository participantRepository
    ) {
        this.tournamentRepository = tournamentRepository;
        this.participantRepository = participantRepository;
    }


    @PostMapping("/request")
    public ResponseEntity<Tournament> createTournamentRequest(
            @RequestBody TournamentRequestDto dto
    ) {
        if (dto.getName() == null || dto.getName().isBlank()
                || dto.getGame() == null || dto.getGame().isBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        Tournament t = new Tournament();
        t.setName(dto.getName());
        t.setGame(dto.getGame());
        t.setCreatedBy(
                dto.getCreatedBy() != null && !dto.getCreatedBy().isBlank()
                        ? dto.getCreatedBy()
                        : "Host"
        );
        t.setSlots(dto.getSlots() != null ? dto.getSlots() : 0);

        double prize = dto.getPrizePool() != null ? dto.getPrizePool() : 0.0;
        t.setPrizePool(prize);
        t.setScheduledText(dto.getDate() != null ? dto.getDate() : "");
        t.setStatus("PENDING");
        t.setStreamUrl(dto.getStreamUrl());
        t.setOfficial(false);
        t.setJoinedCount(0);
        t.setBigPrizePool(prize >= 100000);
        t.setEntryFee(dto.getEntryFee() != null ? dto.getEntryFee() : 0);


        Tournament saved = tournamentRepository.save(t);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping("/by-status/{status}")
    public ResponseEntity<List<Tournament>> getByStatus(@PathVariable String status) {
        String normalized = status.toUpperCase();
        List<Tournament> list = tournamentRepository.findByStatus(normalized);
        return ResponseEntity.ok(list);
    }

    @GetMapping("/live")
    public ResponseEntity<List<Tournament>> getLiveTournaments() {
        List<Tournament> list = tournamentRepository.findByStatus("LIVE");
        return ResponseEntity.ok(list);
    }

    @GetMapping("/upcoming")
    public ResponseEntity<List<Tournament>> getUpcomingTournaments() {
        List<Tournament> list = tournamentRepository.findByStatus("SCHEDULED");
        return ResponseEntity.ok(list);
    }

    @GetMapping("/hosted/{username}")
    public ResponseEntity<List<HostedTournamentDto>> getHostedByUser(
            @PathVariable String username
    ) {
        List<Tournament> list =
                tournamentRepository.findByCreatedByOrderByIdDesc(username);

        List<HostedTournamentDto> dtoList = list.stream()
                .map(this::toHostedDto)
                .toList();

        return ResponseEntity.ok(dtoList);
    }

    @GetMapping("/public")
    public ResponseEntity<List<HostedTournamentDto>> getPublicTournaments() {
        List<Tournament> scheduled = tournamentRepository.findByStatus("SCHEDULED");
        List<Tournament> live = tournamentRepository.findByStatus("LIVE");
        List<Tournament> completed = tournamentRepository.findByStatus("COMPLETED");

        List<Tournament> all = new ArrayList<>();
        all.addAll(live);
        all.addAll(scheduled);
        all.addAll(completed);

        all.sort(Comparator.comparing(Tournament::getId).reversed());

        List<HostedTournamentDto> dtoList = all.stream()
                .map(this::toHostedDto)
                .toList();

        return ResponseEntity.ok(dtoList);
    }

    private HostedTournamentDto toHostedDto(Tournament t) {
        return new HostedTournamentDto(
                t.getId(),
                t.getName(),
                t.getGame(),
                t.getStatus(),
                t.getCreatedBy(),
                t.getSlots(),
                t.getJoinedCount(),
                t.getPrizePool(),
                t.getScheduledText(),
                t.isOfficial(),
                t.getWinner(),
                t.isPrizeDelivered(),
                t.getStreamUrl()
        );
    }

    @PutMapping("/{id}/start")
    public ResponseEntity<Tournament> startTournament(@PathVariable Long id) {
        Optional<Tournament> opt = tournamentRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Tournament t = opt.get();
        if (!"SCHEDULED".equalsIgnoreCase(t.getStatus())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        t.setStatus("LIVE");
        Tournament saved = tournamentRepository.save(t);
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/{id}/complete")
    public ResponseEntity<Tournament> completeTournament(
            @PathVariable Long id,
            @RequestParam(value = "winner", required = false) String winner,
            @RequestParam(
                    value = "prizeDelivered",
                    required = false,
                    defaultValue = "false"
            ) boolean prizeDelivered
    ) {
        Optional<Tournament> opt = tournamentRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Tournament t = opt.get();
        if (!"LIVE".equalsIgnoreCase(t.getStatus())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        t.setStatus("COMPLETED");

        if (winner != null && !winner.isBlank()) {
            t.setWinner(winner);
        }
        if (prizeDelivered) {
            t.setPrizeDelivered(true);
        }

        Tournament saved = tournamentRepository.save(t);
        return ResponseEntity.ok(saved);
    }

@PostMapping("/{id}/join")
public ResponseEntity<?> joinTournament(
        @PathVariable Long id,
        @RequestBody(required = false) Map<String, Object> payload
) {
    System.out.println("👉 JOIN API HIT for tournament id = " + id);

    Tournament tournament = tournamentRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Tournament not found"));

    Integer slots = tournament.getSlots();
    Integer joined = tournament.getJoinedCount();

    if (slots == null) slots = 0;
    if (joined == null) joined = 0;

    if (slots > 0 && joined >= slots) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", "Tournament is already full"));
    }

    // ====== read user info from JSON body ======
    String username = null;
    String userId = null;
    String email = null;

    if (payload != null) {
        Object uName = payload.get("username");
        Object uId = payload.get("userId");
        Object mail = payload.get("email");

        username = uName != null ? uName.toString() : null;
        userId = uId != null ? uId.toString() : null;
        email = mail != null ? mail.toString() : null;
    }

    if (username == null || username.isBlank()) {
        username = "Player";
    }

    // ====== update joined count ======
    joined = joined + 1;
    tournament.setJoinedCount(joined);
    tournamentRepository.save(tournament);

    // ====== save participant row ======
    TournamentParticipant participant = new TournamentParticipant();
    participant.setTournamentId(tournament.getId());
    participant.setUsername(username);
    participant.setUserId(userId);
    participant.setEmail(email);
    participant.setJoinedAt(LocalDateTime.now());

    participantRepository.save(participant);

    return ResponseEntity.ok(Map.of(
            "id", tournament.getId(),
            "joinedCount", joined
    ));
}


    



}
