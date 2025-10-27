#!/bin/bash

echo "=================================================="
echo "  Démarrage du projet Flask Microservices"
echo "=================================================="
echo ""

# Arrêter les conteneurs existants
echo "🛑 Arrêt des conteneurs existants..."
docker compose down

echo ""
echo "🏗️  Construction des images Docker..."
docker compose build --no-cache

echo ""
echo "🚀 Démarrage de tous les services..."
docker compose up -d

echo ""
echo "⏳ Attente du démarrage des bases de données (30 secondes)..."
sleep 30

echo ""
echo "📊 Initialisation de la base de données des produits..."
docker compose exec product-service python populate_products.py

echo ""
echo "👤 Création de l'utilisateur admin par défaut..."
docker compose exec user-service python create_default_user.py

echo ""
echo "📦 Initialisation de la base de données des commandes..."
docker compose exec order-service python init_order_db.py

echo ""
echo "=================================================="
echo "  ✅ Projet démarré avec succès !"
echo "=================================================="
echo ""
echo "🌐 URLs disponibles :"
echo "   - Frontend:    http://localhost:5000"
echo "   - Jaeger:      http://localhost:16686"
echo "   - Prometheus:  http://localhost:9090"
echo "   - Grafana:     http://localhost:3000"
echo ""
echo "👤 Compte par défaut :"
echo "   - Username: admin"
echo "   - Password: admin123"
echo ""
echo "📋 Commandes utiles :"
echo "   - Voir les logs:       docker compose logs -f"
echo "   - Arrêter le projet:   docker compose down"
echo "   - Redémarrer:          docker compose restart"
echo ""
echo "=================================================="
