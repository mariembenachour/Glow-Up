package com.GlowUp.Dressing.utils;

import java.util.Date;
import java.security.Key;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import com.GlowUp.Dressing.entities.Utilisateur;

public class JwtUtils {

    private static final Key SECRET_KEY = Keys.hmacShaKeyFor("GlowUpSecretKeyGlowUpSecretKeyGlowUpSecretKey".getBytes());
    private static final long EXPIRATION_MS = 24 * 60 * 60 * 1000; // 24h

    public static String generateToken(Utilisateur user) {
        return Jwts.builder()
                .setSubject(user.getEmail())
                .claim("id", user.getIdUser())
                .claim("nom", user.getNom())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_MS))
                .signWith(SECRET_KEY, SignatureAlgorithm.HS256)
                .compact();
    }

    public static boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(SECRET_KEY).build().parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static String getEmailFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(SECRET_KEY)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }
}
