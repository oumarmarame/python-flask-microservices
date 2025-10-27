"""
Script de population de la base de données Product (modifié pour ajouter db.create_all()).
Crée automatiquement les tables si elles n'existent pas, puis insère 10 produits
dans le catalogue (Laptop Pro, Smartphone X, Headphones, etc.).

@author: Oumar Marame Ndione
Courriel: oumar-marame.ndione.1@ens.etsmtl.ca
Code Permanent: Private

Cours: MGL870 - Automne 2025
Enseignant: Fabio Petrillo
Projet 1: Mise en Œuvre d'un Pipeline de Journalisation, Traçage et Métriques avec OpenTelemetry
École de technologie supérieure (ÉTS)
@version: 2025-10-26
"""

import sys
from application import create_app, db
from application.models import Product

def populate_db():
    app = create_app()
    with app.app_context():
        # J'ai ajouté cette ligne pour créer les tables si elles n'existent pas
        # Essentiel après un rebuild complet avec suppression des volumes
        db.create_all()
        
        # Je supprime les produits existants pour repartir à zéro
        print("🗑️  Suppression des produits existants...")
        Product.query.delete()
        db.session.commit()

        print("📦 Création du catalogue de 10 produits...")
        
        # J'ai défini ce catalogue de produits pour l'e-commerce
        products_to_add = [
            Product(name='Laptop Pro', slug='laptop-pro', price=1200, image='laptop.jpg'),
            Product(name='Smartphone X', slug='smartphone-x', price=800, image='smartphone.jpg'),
            Product(name='Casque Sans Fil', slug='wireless-headphones', price=150, image='headphones.jpg'),
            Product(name='Souris Gaming', slug='gaming-mouse', price=75, image='mouse.jpg'),
            Product(name='Clavier Mécanique', slug='mechanical-keyboard', price=120, image='keyboard.jpg'),
            Product(name='Écran 4K', slug='4k-monitor', price=450, image='monitor.jpg'),
            Product(name='Webcam HD', slug='webcam-hd', price=90, image='webcam.jpg'),
            Product(name='Hub USB-C', slug='usb-c-hub', price=45, image='hub.jpg'),
            Product(name='Chargeur Sans Fil', slug='wireless-charger', price=35, image='charger.jpg'),
            Product(name='SSD Externe 1TB', slug='external-ssd', price=150, image='ssd.jpg')
        ]

        db.session.bulk_save_objects(products_to_add)
        db.session.commit()
        print("Sample products have been added to the database.")

if __name__ == '__main__':
    populate_db()
