#!/usr/bin/env python
"""Script que j'ai créé pour initialiser les tables de la base order-service.
   Ce fichier n'existait pas dans le projet original - je l'ai ajouté pour résoudre
   le problème des tables manquantes après un rebuild Docker."""

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
