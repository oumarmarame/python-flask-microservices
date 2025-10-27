#!/usr/bin/env python
"""
Script d'initialisation de la base de données Order.
Ce fichier n'existait pas dans le projet original - il a été ajouté pour résoudre
le problème des tables manquantes après un rebuild Docker.

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
from application.models import Order, OrderItem

app = create_app()

with app.app_context():
    # Je crée toutes les tables du modèle (order et order_item)
    print("📋 Création des tables order et order_item...")
    db.create_all()
    print("✅ Tables de commandes créées avec succès!")
    print("   - order (id, user_id, order_date, delivered, subtotal, shipping_cost, total)")
    print("   - order_item (id, order_id, product_id, quantity, unit_price)")
