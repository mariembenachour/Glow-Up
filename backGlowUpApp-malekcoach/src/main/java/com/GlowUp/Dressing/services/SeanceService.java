package com.GlowUp.Dressing.services;

import com.GlowUp.Dressing.entities.Seance;
import com.GlowUp.Dressing.entities.ProgrammeSportif;
import com.GlowUp.Dressing.repositories.SeanceRepository;
import com.GlowUp.Dressing.repositories.ProgrammeSportifRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class SeanceService {

    private final SeanceRepository seanceRepository;
    private final ProgrammeSportifRepository programmeSportifRepository;

    public SeanceService(SeanceRepository seanceRepository,
                         ProgrammeSportifRepository programmeSportifRepository) {
        this.seanceRepository = seanceRepository;
        this.programmeSportifRepository = programmeSportifRepository;
    }

    @Transactional
    public Seance creerSeanceAvecImages(Integer programmeId,
                                        String description,
                                        LocalDateTime heureDebut,
                                        LocalDateTime heureFin,
                                        String createur,
                                        List<MultipartFile> images) throws IOException {

        ProgrammeSportif programme = programmeSportifRepository.findById(programmeId)
                .orElseThrow(() -> new EntityNotFoundException("Programme non trouvé"));

        Seance seance = new Seance();
        seance.setDescription(description);
        seance.setHeureDebut(heureDebut);
        seance.setHeureFin(heureFin);
        seance.setProgrammeSportif(programme);
        seance.setEstComplete(false);
        seance.setCreateur(createur);

        // SAVER LA SÉANCE AVANT D'AJOUTER LES IMAGES
        seance = seanceRepository.save(seance);

        if (images != null && !images.isEmpty()) {

            Path uploadDir = Paths.get("uploads/seances/");
            if (!Files.exists(uploadDir)) Files.createDirectories(uploadDir);

            for (MultipartFile file : images) {
                if (file.isEmpty()) continue;

                String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "file";
                String filename = UUID.randomUUID() + "" + originalName.replace("\\", "").replace("/", "_");
                Path filePath = uploadDir.resolve(filename);
                Files.copy(file.getInputStream(), filePath);

                // URL relative correcte
                String url = "/uploads/seances/" + filename;
                seance.getImages().add(url);
            }

            // OBLIGATOIRE : Hibernate ne sauvegarde pas sinon
            seance = seanceRepository.save(seance);
        }
        System.out.println("Images en mémoire : " + seance.getImages());
        return seance;
    }



    @Transactional
    public void ajouterImage(Integer seanceId, MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) return;

        if (file.getContentType() == null || !file.getContentType().startsWith("image")) return;

        Seance seance = seanceRepository.findById(seanceId)
                .orElseThrow(() -> new EntityNotFoundException("Séance non trouvée"));

        Path uploadDir = Paths.get("uploads/seances/").toAbsolutePath();
        if (!Files.exists(uploadDir)) Files.createDirectories(uploadDir);

        String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "file";
        String filename = UUID.randomUUID() + "" + originalName.replace("\\", "").replace("/", "_");
        Path filePath = uploadDir.resolve(filename);
        Files.copy(file.getInputStream(), filePath);

        if (seance.getImages() == null) seance.setImages(new ArrayList<>());
        seance.getImages().add("uploads/seances/" + filename);

        seanceRepository.save(seance);
    }

    @Transactional
    public Seance marquerSeanceComplete(Integer idSeance) {
        Seance seance = seanceRepository.findById(idSeance)
                .orElseThrow(() -> new EntityNotFoundException("Séance non trouvée avec l'ID: " + idSeance));
        seance.setEstComplete(true);
        return seanceRepository.save(seance);
    }

    @Transactional
    public Seance planifierSeance(Integer idSeance, LocalDateTime heureDeb, LocalDateTime heureFin) {
        Seance seance = seanceRepository.findById(idSeance)
                .orElseThrow(() -> new EntityNotFoundException("Séance non trouvée avec l'ID: " + idSeance));
        if (heureDeb != null) seance.setHeureDebut(heureDeb);
        if (heureFin != null) seance.setHeureFin(heureFin);
        return seanceRepository.save(seance);
    }

    public List<Seance> getSeancesByProgrammeId(int programmeId) {
        return seanceRepository.findByProgrammeSportif_IdProgramme(programmeId);
    }

    public List<Seance> getSeancesByClientId(Integer clientId) {
        return seanceRepository.findByProgrammeSportif_Client_IdUser(clientId);
    }

    public Seance getSeanceById(Integer id) {
        return seanceRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Séance non trouvée avec l'ID: " + id));
    }

    @Transactional
    public Seance modifierSeance(Integer id, String description, LocalDateTime debut, LocalDateTime fin) {
        Seance seance = seanceRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Séance non trouvée avec l'ID: " + id));

        if (description != null) seance.setDescription(description);
        if (debut != null) seance.setHeureDebut(debut);
        if (fin != null) seance.setHeureFin(fin);

        return seanceRepository.save(seance);
    }

    @Transactional
    public void supprimerSeance(Integer id) {
        Seance seance = seanceRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Séance non trouvée avec l'ID: " + id));
        seanceRepository.delete(seance);
    }
}