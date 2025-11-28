package com.GlowUp.Dressing.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Notification;
@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer> {
	@Query("SELECT n FROM Notification n WHERE n.destinataire.idUser = :id")
	List<Notification> findByDestinataireId(@Param("id") int id);
}
