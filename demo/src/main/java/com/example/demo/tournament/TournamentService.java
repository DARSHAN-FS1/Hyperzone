package com.example.demo.tournament;

import com.example.demo.admin.repo.TournamentRepository;
import com.example.demo.user.User;
import com.example.demo.user.UserRepository;
import com.example.demo.tournament.dto.HostedTournamentDto;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.List;
import java.util.Optional;

@Service
public class TournamentService {

    private final TournamentRepository tournamentRepository;
    private final UserRepository userRepository;
    private final SecureRandom random = new SecureRandom();

    public TournamentService(TournamentRepository tournamentRepository,
                             UserRepository userRepository) {
        this.tournamentRepository = tournamentRepository;
        this.userRepository = userRepository;
    }

    // PUBLIC: approved tournaments for home/join screen
    public List<Tournament> getApprovedTournaments() {
        return tournamentRepository.findByStatusOrderByIdDesc("APPROVED");
    }

    // MY HOSTED: tournaments for a single host
    public List<HostedTournamentDto> getHostedByUser(String username) {
        List<Tournament> list =
                tournamentRepository.findByCreatedByOrderByIdDesc(username);

        return list.stream()
                .map(t -> new HostedTournamentDto(
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
                        t.getStreamUrl()      // <-- added
                ))
                .toList();
    }

    // JOIN TOURNAMENT WITH WALLET DEDUCTION
    @Transactional
public String joinTournament(Long tournamentId, Long userId) throws Exception {

    Optional<Tournament> optT = tournamentRepository.findById(tournamentId);
    Optional<User> optU = userRepository.findById(userId);

    if (optT.isEmpty()) throw new Exception("Tournament not found");
    if (optU.isEmpty()) throw new Exception("User not found");

    Tournament t = optT.get();
    User u = optU.get();

    if (!"APPROVED".equals(t.getStatus())) {
        throw new Exception("Tournament not open for registration!");
    }

    if (t.getJoinedCount() >= t.getSlots()) {
        throw new Exception("Tournament is full");
    }

    int entryFee = t.getEntryFee();
    if (!u.deductMoney(entryFee)) {
        throw new Exception("Not enough wallet balance");
    }

    String hostUsername = t.getCreatedBy();
    if (hostUsername != null && !hostUsername.isBlank()) {
        Optional<User> optHost = userRepository.findByUsername(hostUsername);
        if (optHost.isPresent()) {
            User host = optHost.get();
            if (!host.getId().equals(u.getId())) {
                host.addMoney(entryFee);
                userRepository.save(host);
            }
        }
    }

    t.setJoinedCount(t.getJoinedCount() + 1);

    if (t.getRoomId() == null) {
        t.setRoomId(generateRoomId());
        t.setRoomPassword(generatePassword());
    }

    tournamentRepository.save(t);
    userRepository.save(u);

    return "Joined successfully. " +
            "Room ID: " + t.getRoomId() +
            " | Pass: " + t.getRoomPassword();
}


    // ADMIN START TOURNAMENT — LIVE
    @Transactional
    public void startTournament(Long id) throws Exception {
        Tournament t = tournamentRepository.findById(id)
                .orElseThrow(() -> new Exception("Not found"));
        t.setStatus("LIVE");
        tournamentRepository.save(t);
    }

    // ADMIN COMPLETE TOURNAMENT — COMPLETED
    @Transactional
    public void completeTournament(Long id) throws Exception {
        Tournament t = tournamentRepository.findById(id)
                .orElseThrow(() -> new Exception("Not found"));
        t.setStatus("COMPLETED");
        tournamentRepository.save(t);
    }

    // ROOM ID / PASSWORD GENERATOR
    private String generateRoomId() {
        return "RM" + (100000 + random.nextInt(900000));
    }

    private String generatePassword() {
        return "PW" + (1000 + random.nextInt(9000));
    }
}
