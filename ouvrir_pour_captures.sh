#!/bin/bash

echo "=========================================="
echo "  OUVERTURE DES URLs POUR CAPTURES"
echo "=========================================="
echo ""

# Fonction pour ouvrir une URL
open_url() {
    local url=$1
    local desc=$2
    echo "📸 $desc"
    echo "   → $url"
    cmd.exe /c start "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null || open "$url" 2>/dev/null
    sleep 2
}

echo "Vérification de la stack..."
if ! docker compose ps | grep -q "Up"; then
    echo "⚠️  La stack n'est pas démarrée!"
    echo "Démarrage avec : docker compose up -d"
    docker compose up -d
    echo "Attente de 30 secondes pour le démarrage complet..."
    sleep 30
fi

echo ""
echo "Génération de trafic pour avoir des données..."
./test_traces.sh > /dev/null 2>&1 &
echo ""

echo "Ouverture des URLs dans votre navigateur..."
echo ""

# 1. Jaeger
open_url "http://localhost:16686" "JAEGER - Traces distribuées"

# 2. Prometheus Targets
open_url "http://localhost:9090/targets" "PROMETHEUS - Targets"

# 3. Prometheus Graph
open_url "http://localhost:9090/graph" "PROMETHEUS - Métriques"

# 4. Prometheus Alerts
open_url "http://localhost:9090/alerts" "PROMETHEUS - Alertes"

# 5. Grafana
open_url "http://localhost:3000" "GRAFANA - Dashboards (admin/admin)"

# 6. Frontend (optionnel)
open_url "http://localhost:5000" "FRONTEND - Application e-commerce"

echo ""
echo "=========================================="
echo "✅ Toutes les URLs sont ouvertes!"
echo "=========================================="
echo ""
echo "📋 CHECKLIST DES CAPTURES:"
echo ""
echo "1️⃣  Jaeger (http://localhost:16686)"
echo "   → Sélectionner 'frontend' > Find Traces"
echo "   📸 Capturer la liste des traces"
echo "   → Cliquer sur une trace"
echo "   📸 Capturer le détail de la trace"
echo ""
echo "2️⃣  Prometheus Targets (http://localhost:9090/targets)"
echo "   📸 Capturer la page (otel-collector doit être UP/vert)"
echo ""
echo "3️⃣  Prometheus Metrics (http://localhost:9090/graph)"
echo "   → Taper: up{job=\"otel-collector\"}"
echo "   → Cliquer Execute > Onglet Graph"
echo "   📸 Capturer le graphique"
echo ""
echo "4️⃣  Prometheus Alerts (http://localhost:9090/alerts)"
echo "   📸 Capturer la liste des alertes"
echo ""
echo "5️⃣  Grafana (http://localhost:3000)"
echo "   → Login: admin/admin"
echo "   → Menu Dashboards > Ouvrir le dashboard"
echo "   📸 Capturer le dashboard complet"
echo ""
echo "6️⃣  Frontend (http://localhost:5000) - OPTIONNEL"
echo "   📸 Capturer la page d'accueil"
echo "   📸 Capturer la page produits"
echo ""
echo "💾 SAUVEGARDEZ LES CAPTURES DANS:"
echo "   d:\\Github\\python-flask-microservices\\img\\"
echo ""
echo "📖 Consultez CAPTURES_GUIDE.md pour plus de détails"
echo ""
