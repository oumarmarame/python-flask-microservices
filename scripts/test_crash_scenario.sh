#!/bin/bash
# Script de test : Simulation de crash d'un service
# Objectif TP: Observer la résilience et les traces d'erreur dans Jaeger/Prometheus

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  TEST 1: SIMULATION DE CRASH DU PRODUCT-SERVICE             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📋 ÉTAPE 1: État initial du système${NC}"
echo "Services actifs:"
docker compose ps --format "table {{.Service}}\t{{.Status}}" | grep -E "frontend|product-service|order-service"
echo ""

echo -e "${YELLOW}📋 ÉTAPE 2: Test de connectivité (baseline)${NC}"
echo "Requête à product-service (devrait fonctionner):"
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5002/api/products)
if [ "$response" -eq 200 ]; then
    echo -e "${GREEN}✅ Product-service répond correctement (HTTP $response)${NC}"
else
    echo -e "${RED}❌ Erreur: HTTP $response${NC}"
fi
echo ""

echo -e "${YELLOW}📋 ÉTAPE 3: Génération de trafic normal (10 requêtes)${NC}"
for i in {1..10}; do
    curl -s http://localhost:5000/ > /dev/null
    echo "  Requête $i/10 envoyée"
    sleep 0.5
done
echo -e "${GREEN}✅ Trafic baseline généré${NC}"
echo ""

echo -e "${RED}💥 ÉTAPE 4: CRASH DU SERVICE (arrêt brutal)${NC}"
docker compose stop product-service
echo -e "${RED}❌ Product-service arrêté${NC}"
sleep 2
echo ""

echo -e "${YELLOW}📋 ÉTAPE 5: Test pendant la panne${NC}"
echo "Tentative d'accès aux produits (devrait échouer):"
for i in {1..5}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/product 2>/dev/null || echo "000")
    if [ "$response" -eq 200 ]; then
        echo -e "  Requête $i: ${GREEN}HTTP $response${NC} (cache ou fallback?)"
    else
        echo -e "  Requête $i: ${RED}HTTP $response (ERREUR)${NC}"
    fi
    sleep 1
done
echo ""

echo -e "${YELLOW}📊 ÉTAPE 6: Analyse dans Jaeger${NC}"
echo "Ouvrez Jaeger: http://localhost:16686"
echo "Recherche suggérée:"
echo "  - Service: frontend"
echo "  - Operation: GET /product"
echo "  - Tags: error=true"
echo "  → Vous devriez voir des traces avec status ERROR"
echo ""

echo -e "${YELLOW}📊 ÉTAPE 7: Analyse dans Prometheus${NC}"
echo "Ouvrez Prometheus: http://localhost:9090"
echo "Requête suggérée:"
echo "  up{job=\"otel-collector\"}"
echo "  → Vérifiez que le collecteur reste UP malgré la panne"
echo ""

echo -e "${YELLOW}📋 ÉTAPE 8: Attente avant redémarrage (15s pour observer)${NC}"
echo "Consultez Jaeger et Prometheus maintenant..."
sleep 15
echo ""

echo -e "${GREEN}🔄 ÉTAPE 9: REDÉMARRAGE DU SERVICE${NC}"
docker compose start product-service
sleep 5
echo -e "${GREEN}✅ Product-service redémarré${NC}"
echo ""

echo -e "${YELLOW}📋 ÉTAPE 10: Vérification du retour à la normale${NC}"
for i in {1..5}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5002/api/products)
    if [ "$response" -eq 200 ]; then
        echo -e "  Requête $i: ${GREEN}HTTP $response (SERVICE RÉTABLI)${NC}"
    else
        echo -e "  Requête $i: ${RED}HTTP $response${NC}"
    fi
    sleep 1
done
echo ""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  RÉSULTATS ATTENDUS                                          ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  ✅ Jaeger: Traces avec erreurs pendant la panne             ║"
echo "║  ✅ Prometheus: Métriques montrant la baisse de disponibilité║"
echo "║  ✅ Logs: Messages d'erreur de connexion                     ║"
echo "║  ✅ Système: Retour à la normale après redémarrage           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✨ Test terminé! Capturez des screenshots pour le rapport.${NC}"
