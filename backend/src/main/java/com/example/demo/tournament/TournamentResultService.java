package com.example.demo.tournament;

import com.example.demo.admin.repo.TournamentRepository;
import com.example.demo.tournament.dto.TournamentResultDto;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class TournamentResultService {

    private final TournamentRepository tournamentRepository;
    private final TournamentResultRepository resultRepository;

    public TournamentResultService(TournamentRepository tournamentRepository,
                                   TournamentResultRepository resultRepository) {
        this.tournamentRepository = tournamentRepository;
        this.resultRepository = resultRepository;
    }

    public TournamentResultDto getResultForTournament(Long tournamentId) {
        TournamentResult result = resultRepository
                .findByTournamentId(tournamentId)
                .orElse(null);

        if (result == null) {
            return null;
        }

        return new TournamentResultDto(
                result.getTournament().getId(),
                result.getFirstPlace(),
                result.getSecondPlace(),
                result.getThirdPlace(),
                result.getExtraInfo()
        );
    }

    public TournamentResultDto saveOrUpdateResult(Long tournamentId, TournamentResultDto dto) {
        var tournament = tournamentRepository.findById(tournamentId)
                .orElseThrow(() -> new IllegalArgumentException("Tournament not found: " + tournamentId));

        TournamentResult result = resultRepository
                .findByTournamentId(tournamentId)
                .orElseGet(TournamentResult::new);

        result.setTournament(tournament);
        result.setFirstPlace(dto.getFirstPlace());
        result.setSecondPlace(dto.getSecondPlace());
        result.setThirdPlace(dto.getThirdPlace());
        result.setExtraInfo(dto.getExtraInfo());

        TournamentResult saved = resultRepository.save(result);

        return new TournamentResultDto(
                saved.getTournament().getId(),
                saved.getFirstPlace(),
                saved.getSecondPlace(),
                saved.getThirdPlace(),
                saved.getExtraInfo()
        );
    }
}
