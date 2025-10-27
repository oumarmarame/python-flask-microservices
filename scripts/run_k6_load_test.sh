#!/bin/bash
#
# Script d'exécution des tests de charge K6.
# Génère ~400 requêtes HTTP avec 10% d'erreurs simulées pour valider
# le comportement sous charge et déclencher les alertes Prometheus.
#
# @author: Oumar Marame Ndione
# Courriel: oumar-marame.ndione.1@ens.etsmtl.ca
# Code Permanent: Private
#
# Cours: MGL870 - Automne 2025
# Enseignant: Fabio Petrillo
# Projet 1: Mise en Œuvre d'un Pipeline de Journalisation, Traçage et Métriques avec OpenTelemetry
# École de technologie supérieure (ÉTS)
# @version: 2025-10-26
#

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  TEST 3: TEST DE CHARGE AVEC K6                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Vérifier si K6 est installé
if ! command -v k6 &> /dev/null; then
    echo -e "${RED}❌ K6 n'est pas installé${NC}"
    echo ""
    echo "Installation:"
    echo "  Windows: choco install k6"
    echo "  Linux: sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69"
    echo "           echo \"deb https://dl.k6.io/deb stable main\" | sudo tee /etc/apt/sources.list.d/k6.list"
    echo "           sudo apt-get update && sudo apt-get install k6"
    echo "  macOS: brew install k6"
    echo ""
    echo "Ou utilisez Docker:"
    echo "  docker run --rm -i --network=host grafana/k6 run - <k6/scenario.js"
    exit 1
fi

echo -e "${YELLOW}📋 ÉTAPE 1: Vérification des services${NC}"
if ! curl -s http://localhost:5000 > /dev/null; then
    echo -e "${RED}❌ Le frontend n'est pas accessible${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Frontend accessible${NC}"
echo ""

echo -e "${YELLOW}📋 ÉTAPE 2: Préparation des données de test${NC}"
echo "Création de l'utilisateur de test (si nécessaire):"
curl -s -X POST http://localhost:5001/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"test123"}' \
  > /dev/null 2>&1 || echo "  (Utilisateur existe déjà)"

echo "Vérification des produits:"
product_count=$(curl -s http://localhost:5002/api/products | grep -o "id" | wc -l)
echo "  Produits disponibles: $product_count"
if [ "$product_count" -eq 0 ]; then
    echo -e "${YELLOW}  ⚠️  Aucun produit. Exécutez: docker compose exec product-service python populate_products.py${NC}"
fi
echo ""

echo -e "${YELLOW}📋 ÉTAPE 3: Configuration du test K6${NC}"
echo "Scénario de test (k6/scenario.js):"
echo "  - Montée en charge: 0 → 10 VUs (30s)"
echo "  - Charge stable: 10 VUs (1 min)"
echo "  - Pic de charge: 10 → 20 VUs (30s) → Alerte attendue!"
echo "  - Descente: 20 → 0 VUs (30s)"
echo ""
echo "Seuils configurés:"
echo "  - Erreurs 5xx < 5% (déclenche l'alerte HighErrorRate)"
echo "  - p95 latency < 800ms (déclenche l'alerte HighLatency)"
echo ""

echo -e "${YELLOW}📊 ÉTAPE 4: Ouvrez les outils d'observabilité MAINTENANT${NC}"
echo "  🔍 Jaeger:     http://localhost:16686"
echo "  📊 Prometheus: http://localhost:9090/alerts (onglet Alerts)"
echo "  📈 Grafana:    http://localhost:3000"
echo ""
echo -e "${YELLOW}Appuyez sur ENTRÉE pour lancer le test (durée: 2m30s)...${NC}"
read

echo -e "${GREEN}🚀 ÉTAPE 5: LANCEMENT DU TEST K6${NC}"
echo ""
k6 run k6/scenario.js

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  TEST K6 TERMINÉ - ANALYSE DES RÉSULTATS                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${YELLOW}📊 Vérification des alertes Prometheus${NC}"
echo "Ouvrez: http://localhost:9090/alerts"
echo ""
echo "Alertes attendues:"
echo "  - HighErrorRate: CRITICAL (si >5% erreurs 5xx)"
echo "  - HighLatency:   WARNING  (si p95 >500ms)"
echo ""

echo -e "${YELLOW}📊 Analyse dans Jaeger${NC}"
echo "Filtres suggérés:"
echo "  - Service: frontend"
echo "  - Limit: 100"
echo "  → Observez la densité des traces pendant le pic"
echo "  → Identifiez les traces lentes (>500ms)"
echo "  → Cherchez les erreurs (status ERROR)"
echo ""

echo -e "${YELLOW}📊 Analyse dans Grafana${NC}"
echo "Panels à observer:"
echo "  - HTTP Request Rate: Devrait montrer le pic à 2m30s"
echo "  - Latency p95: Devrait augmenter pendant le pic"
echo "  - Error Rate: ~10% (erreurs simulées dans K6)"
echo ""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  RÉSULTATS ATTENDUS (pour le rapport)                        ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  ✅ K6 a généré ~300-400 requêtes HTTP                       ║"
echo "║  ✅ 10% d'erreurs 5xx (simulées volontairement)              ║"
echo "║  ✅ Alerte HighErrorRate déclenchée dans Prometheus          ║"
echo "║  ✅ Traces visibles dans Jaeger (frontend + services)        ║"
echo "║  ✅ Métriques de charge visibles dans Grafana                ║"
echo "║  ✅ Système reste fonctionnel malgré la charge               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✨ Prenez des screenshots pour le rapport!${NC}"
echo ""
echo "Screenshots à capturer:"
echo "  1. K6 output (ce terminal)"
echo "  2. Jaeger: traces avec errors"
echo "  3. Prometheus: alertes actives"
echo "  4. Grafana: dashboards pendant le pic"
