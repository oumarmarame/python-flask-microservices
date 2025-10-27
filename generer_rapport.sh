#!/bin/bash
# Script de collecte d'informations pour le rapport TP

echo "======================================"
echo "  RAPPORT TP OPENTELEMETRY - Collecte"
echo "======================================"
echo ""

echo "1. ARCHITECTURE - Services déployés:"
echo "-------------------------------------"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "2. TRACES - Services dans Jaeger:"
echo "-----------------------------------"
curl -s http://localhost:16686/api/services | python -m json.tool
echo ""

echo "3. MÉTRIQUES - Targets Prometheus:"
echo "------------------------------------"
curl -s http://localhost:9090/api/v1/targets | python -m json.tool | grep -A 10 "activeTargets"
echo ""

echo "4. LOGS - Dernières lignes par service:"
echo "-----------------------------------------"
for service in frontend user-service product-service order-service; do
    echo "=== $service ==="
    docker compose logs --tail=5 $service
    echo ""
done

echo "5. SANTÉ DES CONTENEURS:"
echo "-------------------------"
docker compose ps --format "{{.Name}}: {{.Status}}"
echo ""

echo "======================================"
echo "  Rapport généré avec succès!"
echo "======================================"
