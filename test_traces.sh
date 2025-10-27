#!/bin/bash
# Script pour générer des traces et vérifier qu'elles apparaissent dans Jaeger

echo "============================================"
echo "  TEST TRACES OPENTELEMETRY"
echo "============================================"
echo ""

echo "1. Génération de 100 requêtes vers différents endpoints..."
echo "   (Homepage, produits, connexion - pour simuler un usage réel)"
for i in {1..100}; do
    # Varie les requêtes pour avoir des traces différentes
    case $((i % 3)) in
        0) curl -s http://localhost:5000/ > /dev/null ;;           # Homepage
        1) curl -s http://localhost:5000/login > /dev/null ;;       # Page login
        2) curl -s http://localhost:5000/register > /dev/null ;;    # Page register
    esac
    
    # Affiche la progression tous les 10 requêtes pour ne pas spam le terminal
    if [ $((i % 10)) -eq 0 ]; then
        echo "  - $i/100 requêtes envoyées..."
    fi
    
    sleep 0.1  # 100ms entre chaque requête = ~10 requêtes/sec (safe)
done

echo ""
echo "2. Attente de 20 secondes pour que les traces soient exportées..."
sleep 20

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
