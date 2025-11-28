package com.GlowUp.Dressing.contollers;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.GlowUp.Dressing.entities.Notification;
import com.GlowUp.Dressing.services.NotificationService;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/utilisateur/{userId}")
    public List<Notification> getNotificationsByUser(@PathVariable int userId) {
        return notificationService.findByDestinataire(userId);
    }

    @GetMapping("/{id}")
    public Notification getNotificationById(@PathVariable int id) {
        return notificationService.findById(id).orElse(null);
    }

    @PostMapping
    public Notification envoyerNotification(@RequestBody Notification notification) {
        return notificationService.envoyerNotification(notification.getDestinataire(), notification.getMessage());
    }

    @PutMapping("/{id}/lue")
    public void marquerCommeLue(@PathVariable int id) {
        notificationService.messageLue(id);
    }
    @PutMapping("/utilisateur/{userId}/lues")
    public ResponseEntity<Void> marquerToutesCommeLues(@PathVariable int userId) {
        notificationService.messageLue(userId);
        return ResponseEntity.ok().build();
    }
}
