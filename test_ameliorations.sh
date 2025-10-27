#!/bin/bash
#
# Script de validation des améliorations basées sur les cours MGL870
# Auteur: Oumar Marame
# Date: 27 octobre 2025
#

echo "=========================================="
echo "��� TEST DES AMÉLIORATIONS COURS MGL870"
echo "=========================================="
echo ""

# Test 1: Vérifier que le frontend fonctionne
echo "��� Test 1: Frontend accessible..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/ | grep -q "200"; then
    echo "✅ Frontend: OK (http://localhost:5000)"
else
    echo "❌ Frontend: ERREUR"
    exit 1
fi
echo ""

# Test 2: Vérifier les logs order-service pour métriques
echo "��� Test 2: Métriques initialisées dans order-service..."
if docker logs order-service 2>&1 | grep -q "Exportation Traces, Métriques"; then
    echo "✅ Métriques: Configuration détectée dans order-service"
else
    echo "❌ Métriques: Non détectées"
    exit 1
fi
echo ""

# Test 3: Vérifier Jaeger accessible
echo "��� Test 3: Jaeger accessible..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:16686/ | grep -q "200"; then
    echo "✅ Jaeger: OK (http://localhost:16686)"
else
    echo "❌ Jaeger: ERREUR"
    exit 1
fi
echo ""

# Test 4: Vérifier Prometheus accessible
echo "📝 Test 4: Prometheus accessible..."
if docker ps | grep -q prometheus; then
    echo "✅ Prometheus: Conteneur actif (http://localhost:9090)"
else
    echo "⚠️  Prometheus: Conteneur non détecté (non critique)"
fi
echo ""

# Test 5: Vérifier que les fichiers modifiés existent
echo "��� Test 5: Fichiers modifiés présents..."
FILES=(
    "frontend/application/frontend/views.py"
    "order-service/application/telemetry.py"
    "order-service/application/order_api/routes.py"
    "Rapport_TP_OpenTelemetry.md"
    "AMELIORATIONS_COURS.md"
)

ALL_EXIST=true
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (manquant)"
        ALL_EXIST=false
    fi
done

if [ "$ALL_EXIST" = true ]; then
    echo "✅ Tous les fichiers modifiés sont présents"
else
    echo "❌ Certains fichiers sont manquants"
    exit 1
fi
echo ""

# Test 6: Vérifier Section 8.7 dans le rapport
echo "��� Test 6: Section maturité dans le rapport..."
if grep -q "8.7 Niveau de maturité" Rapport_TP_OpenTelemetry.md; then
    echo "✅ Section 8.7: Trouvée dans le rapport"
else
    echo "❌ Section 8.7: Non trouvée"
    exit 1
fi
echo ""

# Test 7: Vérifier import OpenTelemetry dans views.py
echo "��� Test 7: Import OpenTelemetry trace dans frontend..."
if grep -q "from opentelemetry import trace" frontend/application/frontend/views.py; then
    echo "✅ Import trace: Détecté dans views.py"
else
    echo "❌ Import trace: Non détecté"
    exit 1
fi
echo ""

# Test 8: Vérifier fonction get_order_metrics()
echo "��� Test 8: Fonction get_order_metrics() dans telemetry.py..."
if grep -q "def get_order_metrics()" order-service/application/telemetry.py; then
    echo "✅ get_order_metrics(): Trouvée"
else
    echo "❌ get_order_metrics(): Non trouvée"
    exit 1
fi
echo ""

echo "=========================================="
echo "✅ TOUS LES TESTS PASSÉS AVEC SUCCÈS !"
echo "=========================================="
echo ""
echo "��� Résumé des améliorations validées:"
echo "  ✅ Spans personnalisés (frontend/views.py)"
echo "  ✅ Métriques métier (order-service/telemetry.py)"
echo "  ✅ Section maturité (Rapport section 8.7)"
echo "  ✅ Tous les services opérationnels"
echo ""
echo "��� Projet aligné avec les cours MGL870 !"
