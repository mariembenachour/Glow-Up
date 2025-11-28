package com.GlowUp.Dressing.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.GlowUp.Dressing.entities.Produit_SkinCare;
@Repository
public interface ProduitRepository extends JpaRepository<Produit_SkinCare, Integer>{

}
