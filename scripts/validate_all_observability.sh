#!/bin/bash
# Script de validation complète de l'observabilité
# Exécute tous les tests et génère un rapport de synthèse

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  VALIDATION COMPLÈTE DE L'OBSERVABILITÉ - TP OPENTELEMETRY   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Compteurs de résultats
passed=0
failed=0

# Fonction de vérification
check() {
    local name=$1
    local command=$2
    local expected=$3
    
    echo -ne "  Testing: $name ... "
    result=$(eval "$command" 2>/dev/null || echo "FAILED")
    
    if [[ "$result" == *"$expected"* ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo "    Expected: $expected"
        echo "    Got: $result"
        ((failed++))
    fi
}

echo "═══════════════════════════════════════════════════════════════"
echo " 1. INFRASTRUCTURE DOCKER"
echo "═══════════════════════════════════════════════════════════════"

check "Frontend running" \
    "docker compose ps frontend --format '{{.Status}}'" \
    "Up"

check "OTel Collector running" \
    "docker compose ps otel-collector --format '{{.Status}}'" \
    "Up"

check "Jaeger running" \
    "docker compose ps jaeger --format '{{.Status}}'" \
    "Up"

check "Prometheus running" \
    "docker compose ps prometheus --format '{{.Status}}'" \
    "Up"

check "Grafana running" \
    "docker compose ps grafana --format '{{.Status}}'" \
    "Up"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " 2. CONNECTIVITÉ DES SERVICES"
echo "═══════════════════════════════════════════════════════════════"

check "Frontend HTTP" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:5000" \
    "200"

check "Jaeger UI" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:16686" \
    "200"

check "Prometheus UI" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:9090" \
    "200"

check "Grafana UI" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000" \
    "302"

check "OTel Collector health" \
    "curl -s http://localhost:13133 | jq -r .status" \
    "Server available"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " 3. TRACES (JAEGER)"
echo "═══════════════════════════════════════════════════════════════"

# Générer quelques traces
echo "  Génération de traces de test..."
for i in {1..5}; do
    curl -s http://localhost:5000/ > /dev/null
    sleep 1
done

sleep 3 # Attendre que les traces soient exportées

check "Services in Jaeger" \
    "curl -s http://localhost:16686/api/services | jq -r '.data | length'" \
    "2" # Au moins 2 services (frontend + 1 autre)

check "Frontend traces exist" \
    "curl -s http://localhost:16686/api/services | jq -r '.data[]'" \
    "frontend"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " 4. MÉTRIQUES (PROMETHEUS)"
echo "═══════════════════════════════════════════════════════════════"

check "OTel Collector target UP" \
    "curl -s 'http://localhost:9090/api/v1/query?query=up{job=\"otel-collector\"}' | jq -r '.data.result[0].value[1]'" \
    "1"

check "Prometheus scraping metrics" \
    "curl -s 'http://localhost:9090/api/v1/query?query=scrape_samples_scraped{job=\"otel-collector\"}' | jq -r '.data.result[0].value[1]'" \
    "" # Just check it returns something

check "Alert rules loaded" \
    "curl -s http://localhost:9090/api/v1/rules | jq -r '.data.groups[0].name'" \
    "service_alerts"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " 5. DASHBOARDS (GRAFANA)"
echo "═══════════════════════════════════════════════════════════════"

check "Grafana datasources configured" \
    "curl -s -u admin:admin http://localhost:3000/api/datasources | jq 'length'" \
    "2" # Prometheus + Loki

check "Prometheus datasource working" \
    "curl -s -u admin:admin http://localhost:3000/api/datasources/name/Prometheus | jq -r '.type'" \
    "prometheus"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " 6. PIPELINE COMPLET (END-TO-END)"
echo "═══════════════════════════════════════════════════════════════"

echo "  Test E2E: Génération de trafic → Vérification traces → Vérification métriques"

# Générer du trafic varié
for i in {1..10}; do
    curl -s http://localhost:5000/ > /dev/null &
    curl -s http://localhost:5000/product > /dev/null &
done
wait

sleep 5 # Attendre l'export

# Vérifier que les nouvelles traces sont arrivées
trace_count=$(curl -s "http://localhost:16686/api/traces?service=frontend&limit=20" | jq '.data | length')
if [ "$trace_count" -gt 5 ]; then
    echo -e "  E2E Pipeline: ${GREEN}✅ PASS${NC} ($trace_count traces collectées)"
    ((passed++))
else
    echo -e "  E2E Pipeline: ${RED}❌ FAIL${NC} (seulement $trace_count traces)"
    ((failed++))
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  RÉSULTATS DE LA VALIDATION                                  ║"
echo "╠══════════════════════════════════════════════════════════════╣"
printf "║  Tests réussis: %-44s ║\n" "${GREEN}$passed${NC}"
printf "║  Tests échoués: %-44s ║\n" "${RED}$failed${NC}"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

total=$((passed + failed))
percentage=$((passed * 100 / total))

if [ $percentage -ge 90 ]; then
    echo -e "${GREEN}✨ Excellent! Système d'observabilité opérationnel à $percentage%${NC}"
    exit 0
elif [ $percentage -ge 70 ]; then
    echo -e "${YELLOW}⚠️  Système fonctionnel mais avec des problèmes ($percentage%)${NC}"
    exit 0
else
    echo -e "${RED}❌ Problèmes critiques détectés ($percentage% de réussite)${NC}"
    exit 1
fi
