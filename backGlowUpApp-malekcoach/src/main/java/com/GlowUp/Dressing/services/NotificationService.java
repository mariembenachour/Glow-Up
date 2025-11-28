package com.GlowUp.Dressing.services;

import com.GlowUp.Dressing.entities.Notification;
import com.GlowUp.Dressing.entities.Utilisateur;
import com.GlowUp.Dressing.repositories.NotificationRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    public Notification envoyerNotification(Utilisateur destinataire, String message) {
        Notification notification = new Notification();
        notification.setMessage(message);
        notification.setEtat("distribuee");
        notification.setDestinataire(destinataire);
        return notificationRepository.save(notification);
    }

    public List<Notification> findByDestinataire(int userId) {
        return notificationRepository.findByDestinataireId(userId);
    }

    public Optional<Notification> findById(int id) {
        return notificationRepository.findById(id);
    }
    public void messageLue(int id) {
        notificationRepository.findById(id).ifPresent(notification -> {
            notification.setEtat("Lue");
            notificationRepository.save(notification);
        });
    }
 
}
