#!/usr/bin/env python
"""
Script de création de l'utilisateur admin par défaut (modifié pour ajouter db.create_all()).
Crée automatiquement les tables si elles n'existent pas, puis insère le compte admin
avec les identifiants admin/admin123 pour faciliter les tests.

@author: Oumar Marame Ndione
Courriel: oumar-marame.ndione.1@ens.etsmtl.ca
Code Permanent: Private

Cours: MGL870 - Automne 2025
Enseignant: Fabio Petrillo
Projet 1: Mise en Œuvre d'un Pipeline de Journalisation, Traçage et Métriques avec OpenTelemetry
École de technologie supérieure (ÉTS)
@version: 2025-10-26
"""

from application import create_app, db
from application.models import User

def create_default_user():
    app = create_app()
    
    with app.app_context():
        # J'ai ajouté cette ligne pour créer les tables si elles n'existent pas encore
        # Important après un rebuild complet (docker compose down -v)
        db.create_all()
        
        # Je vérifie si l'utilisateur admin existe déjà pour éviter les doublons
        existing_user = User.query.filter_by(username='admin').first()
        
        if existing_user:
            print(f"✓ L'utilisateur 'admin' existe déjà.")
            print(f"  Email: {existing_user.email}")
            return
        
        # Je crée l'utilisateur admin avec les identifiants que j'ai définis
        user = User(
            username='admin',
            email='admin@example.com',
            first_name='Admin',
            last_name='User',
            password='admin123',  # Sera automatiquement hashé par encode_password()
            is_admin=True
        )
        
        # Je hashe le mot de passe pour la sécurité
        user.encode_password()
        user.encode_api_key()
        
        # J'ajoute l'utilisateur dans la base de données
        db.session.add(user)
        db.session.commit()
        
        print("✅ Utilisateur admin créé avec succès!")
        print("  Username: admin")
        print("  Password: admin123")
        print("  Email: admin@example.com")

if __name__ == '__main__':
    create_default_user()
