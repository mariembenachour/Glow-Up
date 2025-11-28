package com.GlowUp.Dressing.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Look;
@Repository
public interface LookRepository extends JpaRepository<Look, Integer> {
   public List<Look> findByCategorie(String categorie);
   public List<Look> findByFavorisTrue();
   List<Look> findByClient_IdUser(int idUser);

}