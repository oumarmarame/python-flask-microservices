#!/bin/bash
# Script pour créer un dashboard Grafana avec données

echo "📊 Configuration du Dashboard Grafana..."
echo ""

# Attendre que Grafana soit prêt
echo "⏳ Attente du démarrage de Grafana..."
until curl -s http://localhost:3000/api/health > /dev/null 2>&1; do
    echo "  Grafana pas encore prêt, attente..."
    sleep 2
done
echo "✅ Grafana est prêt!"
echo ""

# Créer le dashboard via API
echo "📊 Création du dashboard 'TP OpenTelemetry - Monitoring'..."

curl -X POST \
  -H "Content-Type: application/json" \
  -u admin:admin \
  -d @grafana/dashboards/monitoring.json \
  http://localhost:3000/api/dashboards/db

echo ""
echo ""
echo "✅ Dashboard créé!"
echo ""
echo "🌐 Accédez à Grafana:"
echo "   URL: http://localhost:3000"
echo "   User: admin"
echo "   Pass: admin"
echo ""
echo "📊 Le dashboard 'TP OpenTelemetry - Monitoring' devrait maintenant afficher des données!"
