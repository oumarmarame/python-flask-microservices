#!/bin/bash

# Script pour générer du trafic et préparer les captures d'écran

echo "🚀 Génération de trafic pour l'observabilité..."
echo ""

# Fonction pour faire une requête
make_request() {
    url=$1
    echo "📡 Requête: $url"
    curl -s "$url" > /dev/null
}

# Frontend - Page d'accueil
echo "1️⃣ Page d'accueil (3x)"
for i in {1..3}; do
    make_request "http://localhost:5000/"
    sleep 0.5
done

# Frontend - Produits
echo ""
echo "2️⃣ Pages produits (5x)"
products=("laptop-pro" "smartphone-x" "wireless-headphones" "gaming-mouse" "mechanical-keyboard")
for product in "${products[@]}"; do
    make_request "http://localhost:5000/product/$product"
    sleep 0.5
done

# Backend - API Produits
echo ""
echo "3️⃣ API Produits (3x)"
for i in {1..3}; do
    make_request "http://localhost:5001/api/product"
    sleep 0.5
done

# Backend - API Users
echo ""
echo "4️⃣ API Users (3x)"
for i in {1..3}; do
    make_request "http://localhost:5002/api/user"
    sleep 0.5
done

# Métriques
echo ""
echo "5️⃣ Collecte des métriques"
make_request "http://localhost:8889/metrics"

echo ""
echo "✅ Génération de trafic terminée !"
echo ""
echo "📸 Vous pouvez maintenant prendre vos captures d'écran :"
echo "   - Jaeger: http://localhost:16686"
echo "   - Prometheus: http://localhost:9090"
echo "   - Grafana: http://localhost:3000"
echo ""
