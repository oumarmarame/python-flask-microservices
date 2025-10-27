#!/bin/bash
# Script pour générer des traces et vérifier qu'elles apparaissent dans Jaeger

echo "============================================"
echo "  TEST TRACES OPENTELEMETRY"
echo "============================================"
echo ""

echo "1. Génération de 10 requêtes vers l'application..."
for i in {1..10}; do
    curl -s http://localhost:5000 > /dev/null
    echo "  - Requête $i envoyée"
    sleep 0.5
done

echo ""
echo "2. Attente de 15 secondes pour que les traces soient exportées..."
sleep 15

echo ""
echo "3. Vérification des traces dans Jaeger..."
SERVICES=$(curl -s http://localhost:16686/api/services | python -m json.tool)
echo "$SERVICES"

echo ""
echo "4. Si vous voyez des services ci-dessus, les traces fonctionnent!"
echo "   Sinon, vérifiez:"
echo "   - http://localhost:16686 (Jaeger UI)"
echo "   - docker compose logs otel-collector | grep -i error"
echo "   - docker compose logs jaeger | grep -i error"
echo ""
