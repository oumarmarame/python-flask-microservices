#!/usr/bin/env python
# Script que j'ai modifié pour créer un utilisateur admin par défaut
# Utilisé lors de l'initialisation de la base de données user-service

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
