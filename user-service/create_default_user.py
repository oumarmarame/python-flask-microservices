#!/usr/bin/env python
# create_default_user.py - Crée un utilisateur par défaut pour tester

from application import create_app, db
from application.models import User

def create_default_user():
    app = create_app()
    
    with app.app_context():
        # Create all tables first
        db.create_all()
        
        # Vérifier si l'utilisateur existe déjà
        existing_user = User.query.filter_by(username='admin').first()
        
        if existing_user:
            print(f"L'utilisateur 'admin' existe déjà.")
            print(f"Email: {existing_user.email}")
            return
        
        # Créer un nouvel utilisateur
        user = User(
            username='admin',
            email='admin@example.com',
            first_name='Admin',
            last_name='User',
            password='admin123',  # Sera hashé par encode_password()
            is_admin=True
        )
        
        # Hasher le mot de passe
        user.encode_password()
        user.encode_api_key()
        
        # Ajouter à la base de données
        db.session.add(user)
        db.session.commit()
        
        print("✓ Utilisateur par défaut créé avec succès!")
        print("  Username: admin")
        print("  Password: admin123")
        print("  Email: admin@example.com")

if __name__ == '__main__':
    create_default_user()
