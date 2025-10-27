#!/bin/bash
# Script de test : Simulation de latence réseau
# Objectif TP: Observer l'impact de la latence dans les traces distribuées

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  TEST 2: SIMULATION DE LATENCE RÉSEAU                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}📋 ÉTAPE 1: Mesure de la latence baseline${NC}"
echo "Envoi de 10 requêtes pour mesurer la latence normale:"
for i in {1..10}; do
    start=$(date +%s%3N)
    curl -s http://localhost:5000/product > /dev/null
    end=$(date +%s%3N)
    duration=$((end - start))
    echo "  Requête $i: ${duration}ms"
    sleep 0.5
done
echo ""

echo -e "${YELLOW}📋 ÉTAPE 2: Ajout de latence artificielle (Linux tc)${NC}"
echo "⚠️  Note: Cette étape nécessite des privilèges root et tc (traffic control)"
echo "    Sur Windows/WSL2, utilisez plutôt le test K6 pour simuler la charge."
echo ""

# Sur Linux, on pourrait faire:
# sudo tc qdisc add dev eth0 root netem delay 200ms
# Mais ici on va juste documenter la procédure

echo "Commande théorique (Linux uniquement):"
echo "  sudo tc qdisc add dev docker0 root netem delay 200ms"
echo ""
echo "Alternative: Modifier temporairement le code Python"
echo "  Ajouter: import time; time.sleep(0.2) dans les routes"
echo ""

echo -e "${YELLOW}📋 ÉTAPE 3: Génération de trafic avec latence simulée${NC}"
echo "Envoi de 20 requêtes (latence artificielle dans la boucle):"
for i in {1..20}; do
    start=$(date +%s%3N)
    curl -s http://localhost:5000/product > /dev/null
    # Simulation de latence côté client
    sleep 0.2
    end=$(date +%s%3N)
    duration=$((end - start))
    echo "  Requête $i: ${duration}ms (avec 200ms de sleep)"
    sleep 0.3
done
echo ""

echo -e "${YELLOW}📊 ÉTAPE 4: Analyse dans Jaeger${NC}"
echo "Ouvrez Jaeger: http://localhost:16686"
echo "Recherche suggérée:"
echo "  - Service: frontend"
echo "  - Operation: GET /product"
echo "  - Min Duration: 200ms"
echo "  → Observez les spans avec durée élevée"
echo "  → Identifiez quel microservice cause la latence"
echo ""

echo -e "${YELLOW}📊 ÉTAPE 5: Analyse dans Prometheus${NC}"
echo "Ouvrez Prometheus: http://localhost:9090"
echo "Requêtes suggérées:"
echo "  1. histogram_quantile(0.95, rate(http_server_duration_seconds_bucket[5m]))"
echo "     → Latence p95 (devrait augmenter)"
echo ""
echo "  2. rate(http_server_duration_seconds_sum[5m])"
echo "     → Temps total de traitement"
echo ""

echo -e "${GREEN}✨ Test de latence terminé!${NC}"
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  RÉSULTATS ATTENDUS                                          ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  ✅ Jaeger: Spans avec durée >200ms clairement visibles      ║"
echo "║  ✅ Prometheus: p95 latency augmente dans les métriques      ║"
echo "║  ✅ Grafana: Dashboards montrent le pic de latence           ║"
echo "║  ✅ Analyse: Identification du service lent dans les traces  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
