package com.GlowUp.Dressing.contollers;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.GlowUp.Dressing.entities.Utilisateur;
import com.GlowUp.Dressing.services.UtilisateurService;
import com.GlowUp.Dressing.utils.JwtUtils;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UtilisateurService utilisateurService;

    // Inscription
    @PostMapping("/register")
    public Utilisateur register(@RequestBody Utilisateur utilisateur) {
        return utilisateurService.inscrire(utilisateur);
    }

    // Login
    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String mdp = credentials.get("mdp");
        Utilisateur user = utilisateurService.login(email, mdp); // implémente login dans UtilisateurService
        if (user == null) {
            throw new RuntimeException("Email ou mot de passe incorrect");
        }
        String token = JwtUtils.generateToken(user); // tu peux créer une classe simple pour générer JWT
        return Map.of("token", token, "user", user);
    }
}
